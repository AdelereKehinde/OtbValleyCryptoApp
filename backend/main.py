from fastapi import FastAPI, Depends, HTTPException, Query, status, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
import requests
import smtplib
from email.message import EmailMessage
import os
from typing import List, Optional
import time
import json
from datetime import datetime, timedelta

from database import get_db, engine
import models as db_models

# Create tables
db_models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="CheeseBall Crypto API", version="1.0.0")

# Security configurations
SECRET_KEY = "your-secret-key-here"  # Change in production
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# CoinGecko API base URL
COINGECKO_BASE_URL = "https://api.coingecko.com/api/v3"
CACHE = {}
CACHE_DURATION = 60  # seconds

# Utility functions
def get_cached_data(key: str):
    """Simple in-memory cache implementation"""
    if key in CACHE:
        data, timestamp = CACHE[key]
        if time.time() - timestamp < CACHE_DURATION:
            return data
    return None

def set_cached_data(key: str, data):
    CACHE[key] = (data, time.time())

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = db.query(db_models.User).filter(db_models.User.username == username).first()
    if user is None:
        raise credentials_exception
    return user

async def get_current_admin_user(current_user: db_models.User = Depends(get_current_user)):
    if not current_user.is_admin:  # Now using proper admin field
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )
    return current_user

# Authentication routes
@app.post("/auth/register")
async def register(
    username: str,
    email: str,
    password: str,
    preferred_currency: str = "usd",
    db: Session = Depends(get_db)
):
    # Check if user already exists
    existing_user = db.query(db_models.User).filter(
        (db_models.User.username == username) | (db_models.User.email == email)
    ).first()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username or email already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(password)
    user = db_models.User(
        username=username,
        email=email,
        hashed_password=hashed_password,
        preferred_currency=preferred_currency
    )
    
    db.add(user)
    db.commit()
    db.refresh(user)
    
    return {"message": "User created successfully", "user_id": user.id}

@app.post("/auth/login")
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    user = db.query(db_models.User).filter(db_models.User.username == form_data.username).first()
    
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password"
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "preferred_currency": user.preferred_currency
        }
    }

# Admin Routes
@app.get("/admin/users")
async def get_all_users(
    current_user: db_models.User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    users = db.query(db_models.User).all()
    return [
        {
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "is_active": user.is_active,
            "created_at": user.created_at
        }
        for user in users
    ]

@app.get("/admin/statistics")
async def get_admin_statistics(
    current_user: db_models.User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    total_users = db.query(db_models.User).count()
    total_watchlists = db.query(db_models.Watchlist).count()
    total_portfolios = db.query(db_models.Portfolio).count()
    total_alerts = db.query(db_models.PriceAlert).count()
    
    return {
        "total_users": total_users,
        "total_watchlists": total_watchlists,
        "total_portfolios": total_portfolios,
        "total_alerts": total_alerts,
        "server_time": datetime.utcnow()
    }

@app.post("/admin/users/{user_id}/deactivate")
async def deactivate_user(
    user_id: int,
    current_user: db_models.User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    user = db.query(db_models.User).filter(db_models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.is_active = False
    db.commit()
    
    return {"message": f"User {user.username} deactivated"}

@app.post("/admin/users/{user_id}/activate")
async def activate_user(
    user_id: int,
    current_user: db_models.User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    user = db.query(db_models.User).filter(db_models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.is_active = True
    db.commit()
    
    return {"message": f"User {user.username} activated"}

# CoinGecko API Proxy Routes (Protected)
@app.get("/coins/list")
async def coins_list(
    include_platform: bool = False,
    current_user: db_models.User = Depends(get_current_user)
):
    cache_key = f"coins_list_{include_platform}"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/coins/list", params={"include_platform": include_platform})
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/simple/supported_vs_currencies")
async def supported_currencies(current_user: db_models.User = Depends(get_current_user)):
    cache_key = "supported_currencies"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/simple/supported_vs_currencies")
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/search/trending")
async def trending_coins(current_user: db_models.User = Depends(get_current_user)):
    cache_key = "trending_coins"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/search/trending")
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/coins/categories/list")
async def categories_list(current_user: db_models.User = Depends(get_current_user)):
    cache_key = "categories_list"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/coins/categories/list")
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/simple/price")
async def simple_price(
    ids: str,
    vs_currencies: str,
    current_user: db_models.User = Depends(get_current_user)
):
    cache_key = f"simple_price_{ids}_{vs_currencies}"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/simple/price", 
                           params={"ids": ids, "vs_currencies": vs_currencies})
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/simple/token_price/{platform_id}")
async def token_price(
    platform_id: str,
    contract_addresses: str,
    vs_currencies: str,
    current_user: db_models.User = Depends(get_current_user)
):
    cache_key = f"token_price_{platform_id}_{contract_addresses}_{vs_currencies}"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/simple/token_price/{platform_id}",
                           params={"contract_addresses": contract_addresses, "vs_currencies": vs_currencies})
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/coins/markets")
async def coins_markets(
    vs_currency: str = "usd",
    ids: Optional[str] = None,
    category: Optional[str] = None,
    order: str = "market_cap_desc",
    per_page: int = 100,
    page: int = 1,
    sparkline: bool = False,
    price_change_percentage: str = "24h",
    current_user: db_models.User = Depends(get_current_user)
):
    cache_key = f"coins_markets_{vs_currency}_{ids}_{category}_{order}_{per_page}_{page}_{sparkline}_{price_change_percentage}"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    params = {
        "vs_currency": vs_currency,
        "order": order,
        "per_page": per_page,
        "page": page,
        "sparkline": sparkline,
        "price_change_percentage": price_change_percentage
    }
    if ids:
        params["ids"] = ids
    if category:
        params["category"] = category
    
    response = requests.get(f"{COINGECKO_BASE_URL}/coins/markets", params=params)
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/coins/{coin_id}")
async def coin_detail(
    coin_id: str,
    localization: bool = False,
    market_data: bool = True,
    current_user: db_models.User = Depends(get_current_user)
):
    cache_key = f"coin_detail_{coin_id}_{localization}_{market_data}"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/coins/{coin_id}",
                           params={"localization": localization, "market_data": market_data})
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/coins/{coin_id}/tickers")
async def coin_tickers(
    coin_id: str,
    page: int = 1,
    current_user: db_models.User = Depends(get_current_user)
):
    cache_key = f"coin_tickers_{coin_id}_{page}"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/coins/{coin_id}/tickers", params={"page": page})
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/coins/{coin_id}/market_chart")
async def market_chart(
    coin_id: str,
    vs_currency: str = "usd",
    days: int = 7,
    interval: str = "daily",
    current_user: db_models.User = Depends(get_current_user)
):
    cache_key = f"market_chart_{coin_id}_{vs_currency}_{days}_{interval}"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/coins/{coin_id}/market_chart",
                           params={"vs_currency": vs_currency, "days": days, "interval": interval})
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/coins/{coin_id}/market_chart/range")
async def market_chart_range(
    coin_id: str,
    vs_currency: str = "usd",
    from_timestamp: int = None,
    to_timestamp: int = None,
    current_user: db_models.User = Depends(get_current_user)
):
    if not from_timestamp:
        from_timestamp = int((datetime.now() - timedelta(days=30)).timestamp())
    if not to_timestamp:
        to_timestamp = int(datetime.now().timestamp())
    
    cache_key = f"market_chart_range_{coin_id}_{vs_currency}_{from_timestamp}_{to_timestamp}"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/coins/{coin_id}/market_chart/range",
                           params={"vs_currency": vs_currency, "from": from_timestamp, "to": to_timestamp})
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/coins/{coin_id}/ohlc")
async def coin_ohlc(
    coin_id: str,
    vs_currency: str = "usd",
    days: int = 7,
    current_user: db_models.User = Depends(get_current_user)
):
    cache_key = f"coin_ohlc_{coin_id}_{vs_currency}_{days}"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/coins/{coin_id}/ohlc",
                           params={"vs_currency": vs_currency, "days": days})
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/coins/{platform_id}/contract/{contract_address}/market_chart")
async def token_market_chart(
    platform_id: str,
    contract_address: str,
    vs_currency: str = "usd",
    days: int = 7,
    current_user: db_models.User = Depends(get_current_user)
):
    cache_key = f"token_market_chart_{platform_id}_{contract_address}_{vs_currency}_{days}"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/coins/{platform_id}/contract/{contract_address}/market_chart",
                           params={"vs_currency": vs_currency, "days": days})
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/onchain/simple/token_price/{platform_id}")
async def onchain_token_price(
    platform_id: str,
    contract_addresses: str,
    vs_currencies: str,
    current_user: db_models.User = Depends(get_current_user)
):
    cache_key = f"onchain_token_price_{platform_id}_{contract_addresses}_{vs_currencies}"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/onchain/simple/token_price/{platform_id}",
                           params={"contract_addresses": contract_addresses, "vs_currencies": vs_currencies})
    data = response.json()
    set_cached_data(cache_key, data)
    return data

@app.get("/global")
async def global_market_data(current_user: db_models.User = Depends(get_current_user)):
    cache_key = "global_market_data"
    cached = get_cached_data(cache_key)
    if cached:
        return cached
    
    response = requests.get(f"{COINGECKO_BASE_URL}/global")
    data = response.json()
    set_cached_data(cache_key, data)
    return data

# Custom app routes
@app.get("/user/watchlist")
async def get_user_watchlist(
    current_user: db_models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    watchlist = db.query(db_models.Watchlist).filter(db_models.Watchlist.user_id == current_user.id).all()
    return [
        {
            "id": item.id,
            "coin_id": item.coin_id,
            "coin_symbol": item.coin_symbol,
            "coin_name": item.coin_name,
            "created_at": item.created_at
        }
        for item in watchlist
    ]

@app.post("/user/watchlist")
async def add_to_watchlist(
    coin_id: str,
    coin_symbol: str,
    coin_name: str,
    current_user: db_models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Check if already in watchlist
    existing = db.query(db_models.Watchlist).filter(
        db_models.Watchlist.user_id == current_user.id,
        db_models.Watchlist.coin_id == coin_id
    ).first()
    
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Coin already in watchlist"
        )
    
    watchlist_item = db_models.Watchlist(
        user_id=current_user.id,
        coin_id=coin_id,
        coin_symbol=coin_symbol,
        coin_name=coin_name
    )
    db.add(watchlist_item)
    db.commit()
    db.refresh(watchlist_item)
    
    return {
        "message": "Added to watchlist",
        "watchlist_item": {
            "id": watchlist_item.id,
            "coin_id": watchlist_item.coin_id,
            "coin_symbol": watchlist_item.coin_symbol,
            "coin_name": watchlist_item.coin_name
        }
    }

@app.delete("/user/watchlist/{coin_id}")
async def remove_from_watchlist(
    coin_id: str,
    current_user: db_models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    watchlist_item = db.query(db_models.Watchlist).filter(
        db_models.Watchlist.user_id == current_user.id,
        db_models.Watchlist.coin_id == coin_id
    ).first()
    
    if not watchlist_item:
        raise HTTPException(status_code=404, detail="Coin not found in watchlist")
    
    db.delete(watchlist_item)
    db.commit()
    
    return {"message": "Removed from watchlist"}

@app.get("/user/portfolio")
async def get_user_portfolio(
    current_user: db_models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    portfolio = db.query(db_models.Portfolio).filter(db_models.Portfolio.user_id == current_user.id).all()
    return [
        {
            "id": item.id,
            "coin_id": item.coin_id,
            "amount": item.amount,
            "purchase_price": item.purchase_price,
            "purchase_currency": item.purchase_currency,
            "purchase_date": item.purchase_date,
            "notes": item.notes
        }
        for item in portfolio
    ]

@app.post("/user/portfolio")
async def add_to_portfolio(
    coin_id: str,
    amount: float,
    purchase_price: float,
    purchase_currency: str = "usd",
    notes: Optional[str] = None,
    current_user: db_models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    portfolio_item = db_models.Portfolio(
        user_id=current_user.id,
        coin_id=coin_id,
        amount=amount,
        purchase_price=purchase_price,
        purchase_currency=purchase_currency,
        notes=notes
    )
    db.add(portfolio_item)
    db.commit()
    db.refresh(portfolio_item)
    
    return {
        "message": "Added to portfolio",
        "portfolio_item": {
            "id": portfolio_item.id,
            "coin_id": portfolio_item.coin_id,
            "amount": portfolio_item.amount,
            "purchase_price": portfolio_item.purchase_price
        }
    }

@app.get("/user/alerts")
async def get_user_alerts(
    current_user: db_models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    alerts = db.query(db_models.PriceAlert).filter(db_models.PriceAlert.user_id == current_user.id).all()
    return [
        {
            "id": alert.id,
            "coin_id": alert.coin_id,
            "target_price": alert.target_price,
            "currency": alert.currency,
            "is_above": alert.is_above,
            "is_active": alert.is_active,
            "created_at": alert.created_at
        }
        for alert in alerts
    ]

@app.post("/user/alerts")
async def create_price_alert(
    coin_id: str,
    target_price: float,
    is_above: bool = True,
    currency: str = "usd",
    current_user: db_models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    alert = db_models.PriceAlert(
        user_id=current_user.id,
        coin_id=coin_id,
        target_price=target_price,
        is_above=is_above,
        currency=currency
    )
    db.add(alert)
    db.commit()
    db.refresh(alert)
    
    return {
        "message": "Price alert created",
        "alert": {
            "id": alert.id,
            "coin_id": alert.coin_id,
            "target_price": alert.target_price,
            "is_above": alert.is_above
        }
    }
    
# Send OTP
def send_otp_email(receiver_email: str, otp_code: str):
    sender_email = "youremail@gmail.com"
    sender_password = "your_app_password"  # use Gmail App Password (not your real password)

    msg = EmailMessage()
    msg["Subject"] = "Your CheeseBall Password Reset OTP"
    msg["From"] = sender_email
    msg["To"] = receiver_email
    msg.set_content(f"Your OTP code is: {otp_code}\n\nUse this to reset your password in the app.")

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as smtp:
            smtp.login(sender_email, sender_password)
            smtp.send_message(msg)
    except Exception as e:
        print("Error sending email:", e)
        raise HTTPException(status_code=500, detail="Could not send OTP email")


@app.post("/auth/forgot-password")
async def forgot_password(email: str = Form(...)):
    # Check if user exists
    if email not in users_db:
        raise HTTPException(status_code=404, detail="Email not found")

    otp = str(random.randint(100000, 999999))
    users_db[email]["otp"] = otp
    send_otp_email(email, otp)
    return {"message": "OTP sent successfully"}


@app.post("/auth/verify-otp")
async def verify_otp(email: str = Form(...), otp: str = Form(...)):
    user = users_db.get(email)
    if not user or user.get("otp") != otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")
    return {"message": "OTP verified"}


@app.post("/auth/reset-password")
async def reset_password(email: str = Form(...), new_password: str = Form(...)):
    if email not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    hashed_pw = pwd_context.hash(new_password)
    users_db[email]["password"] = hashed_pw
    users_db[email].pop("otp", None)
    return {"message": "Password reset successfully"}    

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)