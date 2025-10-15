from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text
from sqlalchemy.sql import func
from database import Base
import datetime

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True)
    username = Column(String(100), unique=True, index=True)
    hashed_password = Column(String(255))
    preferred_currency = Column(String(10), default="usd")
    is_active = Column(Boolean, default=True)
    is_admin = Column(Boolean, default=False)  # New admin field
    created_at = Column(DateTime, default=func.now())

class Watchlist(Base):
    __tablename__ = "watchlists"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    coin_id = Column(String(100), index=True)
    coin_symbol = Column(String(50))
    coin_name = Column(String(100))
    created_at = Column(DateTime, default=func.now())

class Portfolio(Base):
    __tablename__ = "portfolios"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    coin_id = Column(String(100), index=True)
    amount = Column(Float)
    purchase_price = Column(Float)
    purchase_currency = Column(String(10), default="usd")
    purchase_date = Column(DateTime, default=func.now())
    notes = Column(Text, nullable=True)

class PriceAlert(Base):
    __tablename__ = "price_alerts"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    coin_id = Column(String(100), index=True)
    target_price = Column(Float)
    currency = Column(String(10), default="usd")
    is_above = Column(Boolean, default=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())