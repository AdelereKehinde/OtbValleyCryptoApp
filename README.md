Advanced Real-Time Cryptocurrency Tracking App (FastAPI + Flutter + CoinGecko)

Otbvalley Crypto Tracker is a next-generation digital asset monitoring app built with Flutter (frontend) and FastAPI (backend). Powered by the CoinGecko API, it delivers real-time price data, global market stats, watchlists, and portfolio insights — all in a beautiful, blazing-fast interface.

🧠 Overview

This project bridges the gap between backend performance and mobile experience, offering users instant market updates, dynamic price charts, and deep insights into thousands of cryptocurrencies.

✨ Key Features

📊 Real-Time Market Data: Stream live cryptocurrency prices, charts, and market caps using the CoinGecko API.

🧩 FastAPI Backend: Ultra-fast RESTful API for data aggregation, caching, and business logic.

📱 Flutter Frontend: Cross-platform mobile UI with elegant animations and lightning performance.

🔔 Live Alerts & Watchlist: Add coins to a personalized watchlist with real-time notifications.

🌍 Global Market Overview: View market trends, dominance, and volume in one dashboard.

💾 Local & Remote Storage: User preferences and coin data are synced for seamless experience.

⚙️ Modular Codebase: Clean architecture for easy scalability and maintenance.

🏗️ Tech Stack
Layer	Technology	Description
Frontend	Flutter	Cross-platform UI framework for Android, iOS, and Web
Backend	FastAPI	Modern Python framework for high-performance APIs
Data Source	CoinGecko API	Free crypto data provider with live market updates
Database	SQLite / PostgreSQL	Persistent storage for user and coin data
Realtime Updates	WebSocket (FastAPI)	Instant market refresh without reload
⚡ Installation & Setup
🖥️ Backend (FastAPI)

Clone the repository

git clone https://github.com/your-username/otbvalley-crypto-tracker.git
cd otbvalley-crypto-tracker/backend


Create a virtual environment

python -m venv venv
source venv/bin/activate      # for macOS/Linux
venv\Scripts\activate         # for Windows


Install dependencies

pip install -r requirements.txt


Run the FastAPI server

uvicorn main:app --reload


Visit the API docs
👉 http://127.0.0.1:8000/docs

📱 Frontend (Flutter)

Navigate to the Flutter directory

cd ../frontend


Install Flutter dependencies

flutter pub get


Configure your API endpoint
Open lib/constants/api.dart and update the backend URL:

const String BASE_URL = "http://127.0.0.1:8000";


Run the app

flutter run

🧪 API Endpoints
Endpoint	Method	Description
/coins	GET	Fetch all crypto market data
/coin/{id}	GET	Get detailed info of a single coin
/trending	GET	Retrieve trending cryptocurrencies
/watchlist	POST / GET	Manage user’s favorite coins
/alerts	POST	Set price alerts for selected coins
📸 Screenshots

(Add images here)

Dashboard with top coins

Coin details view

Real-time chart view

Personalized watchlist

🧰 Contribution Guide

Fork the repo and create a new branch:

git checkout -b feature-name


Make your changes and commit:

git commit -m "Add feature-name"


Push and open a Pull Request.

🧑‍💻 Author

Otbvalley Technologies
Advanced Blockchain, AI, and Software Innovation Hub
📧 contact@otbvalley.com

🌐 www.otbvalley.com

🛡️ License

This project is licensed under the MIT License — you’re free to use and modify it for personal or commercial projects with proper attribution.
