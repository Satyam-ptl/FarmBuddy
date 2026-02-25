# 🌾 Farm Buddy - Django REST API Backend

**Farm Buddy** is a comprehensive Multi-Crop Growth Assistant backend built with Django and Django REST Framework. It provides RESTful APIs for managing crops, farmers, tasks, and weather information for agricultural applications.

![Python](https://img.shields.io/badge/Python-3.14.3-blue)
![Django](https://img.shields.io/badge/Django-6.0.2-green)
![DRF](https://img.shields.io/badge/DRF-Latest-red)
![SQLite](https://img.shields.io/badge/Database-SQLite3-lightgrey)

---

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [API Documentation](#-api-documentation)
- [Project Structure](#-project-structure)
- [Database Models](#-database-models)
- [Configuration](#-configuration)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Contributing](#-contributing)

---

## ✨ Features

### 🌱 Crops Management
- Complete crop database with growing requirements
- Crop guides with detailed planting instructions
- Growth stage tracking (germination, vegetative, flowering, etc.)
- Care task scheduling by Days After Planting (DAP)
- Crop recommendations by season and soil type

### 👨‍🌾 Farmers Management
- Farmer profile management with contact preferences
- Multi-language support (Hindi, Marathi, English)
- Land area and soil type tracking
- Experience level classification
- Crop allocation and tracking per farmer
- Inventory management (seeds, fertilizers, tools)

### ✅ Task Management
- Farming task creation and assignment
- Status tracking (Pending, In Progress, Completed, Overdue)
- Priority and importance levels
- SMS/WhatsApp reminder scheduling
- Task activity logging
- Automated overdue detection

### 🌦️ Weather & Alerts
- Real-time weather data integration
- Farmer-specific weather alerts
- Severity-based warnings (Low, Medium, High, Critical)
- Alert types: Rain, Frost, Heat, Wind, Disease, Pest
- 7-day weather forecasts
- Location-based weather data

### 🔌 RESTful API
- 41 API endpoints with full CRUD operations
- Automatic pagination (20 items/page)
- Filtering and search capabilities
- Custom actions for complex queries
- CORS enabled for mobile/web frontend
- Comprehensive error handling

### 🛠️ Admin Panel
- Django admin interface for all models
- Custom list displays and filters
- Inline editing for related models
- Search functionality
- Bulk actions support

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│         Client Applications                         │
│  (Flutter App, React Web, Mobile Apps, etc.)       │
└───────────────────┬─────────────────────────────────┘
                    │
                    │ HTTP Requests (JSON)
                    │ GET, POST, PUT, PATCH, DELETE
                    │
┌───────────────────▼─────────────────────────────────┐
│           Django REST API Backend                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │  Crops   │  │ Farmers  │  │  Tasks   │  ┌─────┐ │
│  │ ViewSets │  │ ViewSets │  │ ViewSets │  │Admin│ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └─────┘ │
│       │             │              │                 │
│  ┌────▼─────────────▼──────────────▼────┐           │
│  │        Django ORM (Models)            │           │
│  └───────────────┬───────────────────────┘           │
└──────────────────┼─────────────────────────────────┘
                   │
                   │ SQL Queries
                   │
┌──────────────────▼─────────────────────────────────┐
│              SQLite3 Database                       │
│  (Can switch to MySQL/PostgreSQL)                  │
└─────────────────────────────────────────────────────┘
```

**Key Components:**
- **Models**: Define database schema (14 models total)
- **Serializers**: Convert data between JSON and Python objects (23 serializers)
- **ViewSets**: Handle API logic and routing (14 viewsets)
- **URLs**: Route API endpoints (41 endpoints)
- **Admin**: Web interface for data management

---

## 💻 Installation

### Prerequisites

- **Python**: 3.10 or higher
- **pip**: Latest version
- **Git**: For version control

### Step 1: Clone Repository

```bash
git clone https://github.com/Satyam-ptl/FarmBuddy.git
cd FarmBuddy
```

### Step 2: Create Virtual Environment (Recommended)

**Windows:**
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

**macOS/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

### Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

**Required packages:**
- `django==6.0.2` - Web framework
- `djangorestframework` - REST API toolkit
- `django-cors-headers` - CORS support for frontend
- `mysqlclient` - MySQL database driver (optional)
- `pillow` - Image processing

### Step 4: Database Setup

```bash
# Run migrations to create database tables
python manage.py migrate

# Create superuser for admin access
python manage.py createsuperuser
```

Follow prompts to create admin account.

### Step 5: Run Development Server

```bash
python manage.py runserver 0.0.0.0:8000
```

**Server will start at:** `http://localhost:8000`

✅ **Backend is now running!**

---

## 🚀 Quick Start

### 1. Access Admin Panel

1. Go to: `http://localhost:8000/admin/`
2. Login with superuser credentials
3. Add sample data:
   - Create crops (Rice, Wheat, Cotton, etc.)
   - Create farmers
   - Create tasks

### 2. Access API Endpoints

**Browse API in browser:**
- Crops: `http://localhost:8000/api/crops/`
- Farmers: `http://localhost:8000/api/farmers/`
- Tasks: `http://localhost:8000/api/tasks/`
- Weather: `http://localhost:8000/api/weather-data/`

**API Root:** `http://localhost:8000/api/`

### 3. Test with cURL

```bash
# Get all crops
curl http://localhost:8000/api/crops/

# Get specific crop
curl http://localhost:8000/api/crops/1/

# Filter crops by season
curl http://localhost:8000/api/crops/?season=Kharif

# Create new farmer (POST)
curl -X POST http://localhost:8000/api/farmers/ \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Ramesh",
    "last_name": "Patil",
    "email": "ramesh@example.com",
    "phone_number": "9876543210",
    "city": "Pune",
    "state": "Maharashtra",
    "land_area_hectares": 5.0,
    "soil_type": "Loamy",
    "experience_level": "Intermediate",
    "preferred_language": "Marathi",
    "contact_method": "WhatsApp"
  }'
```

### 4. Connect Frontend

**For Flutter App:**
```dart
// Update baseUrl in lib/services/api_service.dart
static const String baseUrl = 'http://10.0.2.2:8000/api';  // Android emulator
```

**For React/Web:**
```javascript
const API_BASE_URL = 'http://localhost:8000/api';
```

---

## 📚 API Documentation

### Base URL: `/api/`

### 🌱 Crops Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/crops/` | List all crops (paginated) |
| GET | `/api/crops/{id}/` | Get specific crop details |
| POST | `/api/crops/` | Create new crop |
| PUT | `/api/crops/{id}/` | Update crop |
| DELETE | `/api/crops/{id}/` | Delete crop |
| GET | `/api/crops/by_season/?season=Kharif` | Filter crops by season |
| GET | `/api/crops/recommendations/?season=Kharif` | Get recommended crops |
| GET | `/api/crop-guides/` | List crop guides |
| GET | `/api/crop-guides/for_crop/?crop_id=1` | Get guide for specific crop |
| GET | `/api/growth-stages/` | List growth stages |
| GET | `/api/care-tasks/` | List care tasks |
| GET | `/api/recommendations/` | List crop recommendations |

### 👨‍🌾 Farmers Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/farmers/` | List all farmers |
| GET | `/api/farmers/{id}/` | Get farmer details |
| POST | `/api/farmers/` | Create new farmer |
| PUT | `/api/farmers/{id}/` | Update farmer |
| DELETE | `/api/farmers/{id}/` | Delete farmer |
| GET | `/api/farmers/by_experience/?level=Expert` | Filter by experience |
| GET | `/api/farmers/by_soil/?soil=Loamy` | Filter by soil type |
| GET | `/api/farmers/by_city/?city=Pune` | Filter by city |
| GET | `/api/farmer-crops/` | List farmer crops |
| GET | `/api/farmer-crops/current/?farmer_id=1` | Get current crops |
| GET | `/api/inventory/` | List inventory items |
| GET | `/api/inventory/expired/` | Get expired items |

### ✅ Tasks Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/tasks/` | List all tasks |
| GET | `/api/tasks/{id}/` | Get task details |
| POST | `/api/tasks/` | Create new task |
| PUT | `/api/tasks/{id}/` | Update task |
| PATCH | `/api/tasks/{id}/` | Partial update (e.g., status) |
| DELETE | `/api/tasks/{id}/` | Delete task |
| GET | `/api/task-reminders/` | List reminders |
| GET | `/api/task-logs/` | List task activity logs |

### 🌦️ Weather Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/weather-data/` | List weather data |
| GET | `/api/weather-data/?location=Pune` | Filter by location |
| GET | `/api/weather-alerts/` | List weather alerts |
| GET | `/api/weather-alerts/?farmer=1` | Alerts for specific farmer |
| GET | `/api/weather-forecast/` | List forecasts |

### Query Parameters

All list endpoints support:
- `?page=2` - Pagination (20 items/page)
- `?page_size=50` - Custom page size (max 100)
- `?search=keyword` - Search functionality
- `?ordering=field_name` - Sort results

### Response Format

**Success (200 OK):**
```json
{
  "count": 50,
  "next": "http://localhost:8000/api/crops/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "Rice",
      "season": "Kharif",
      "soil_type": "Loamy",
      ...
    }
  ]
}
```

**Error (400 Bad Request):**
```json
{
  "field_name": [
    "This field is required."
  ]
}
```

---

## 📁 Project Structure

```
FarmBuddy/
├── manage.py                          # Django management script
├── db.sqlite3                         # SQLite database
├── requirements.txt                   # Python dependencies
├── README.md                          # This file
│
└── FarmBuddy_Backend/                 # Main project directory
    ├── __init__.py
    ├── settings.py                    # Django settings & configuration
    ├── urls.py                        # URL routing
    ├── wsgi.py                        # WSGI configuration
    │
    ├── crops/                         # Crops app
    │   ├── models.py                  # 5 models (Crop, CropGuide, etc.)
    │   ├── serializers.py             # 6 serializers
    │   ├── views.py                   # 5 viewsets
    │   ├── admin.py                   # Admin configuration
    │   ├── apps.py
    │   └── migrations/                # Database migrations
    │
    ├── farmers/                       # Farmers app
    │   ├── models.py                  # 3 models (Farmer, FarmerCrop, etc.)
    │   ├── serializers.py             # 5 serializers
    │   ├── views.py                   # 3 viewsets
    │   ├── admin.py
    │   └── migrations/
    │
    ├── weather/                       # Weather app
    │   ├── models.py                  # 3 models (WeatherData, etc.)
    │   ├── serializers.py             # 5 serializers
    │   ├── views.py                   # 3 viewsets
    │   ├── admin.py
    │   └── migrations/
    │
    └── tasks/                         # Tasks app
        ├── models.py                  # 3 models (FarmerTask, etc.)
        ├── serializers.py             # 7 serializers
        ├── views.py                   # 3 viewsets
        ├── admin.py
        └── migrations/
```

---

## 🗄️ Database Models

### Crops Module (5 Models)

**1. Crop**
- Basic crop information
- Growing requirements (temperature, humidity, water)
- Expected yield per hectare
- Season classification (Kharif, Rabi, Summer)

**2. CropGuide**
- Step-by-step planting instructions
- Watering and fertilizer schedules
- Disease and pest management
- Harvesting guidelines

**3. CropGrowthStage**
- Growth stages (Germination, Vegetative, Flowering, etc.)
- Duration and conditions for each stage
- Care instructions per stage

**4. CropCareTask**
- Tasks by Days After Planting (DAP)
- Frequency and timing
- Detailed instructions

**5. CropRecommendation**
- Season-based recommendations
- Priority scoring
- Suitability for different regions

### Farmers Module (3 Models)

**1. Farmer**
- Personal information (name, contact)
- Location (city, state, address)
- Land details (area, soil type)
- Experience level (Beginner, Intermediate, Expert)
- Language preference (Hindi, Marathi, English)
- Contact method (WhatsApp, SMS)

**2. FarmerCrop**
- Tracks which crops each farmer is growing
- Planting and harvest dates
- Status (Planned, Growing, Harvested, Completed)
- Area allocated and expected yield
- Calculated: days_since_planting, days_until_harvest

**3. FarmerInventory**
- Seeds, fertilizers, tools tracking
- Quantity and unit of measurement
- Purchase and expiry dates
- Automatic expiry detection

### Tasks Module (3 Models)

**1. FarmerTask**
- Task assignment to farmers
- Status tracking (Pending, In Progress, Completed, Overdue)
- Priority (1-10) and importance (Low to Critical)
- Due dates and completion tracking
- Calculated: days_remaining, is_overdue

**2. TaskReminder**
- Multi-channel reminders (SMS, WhatsApp, App, Email)
- Scheduled reminder dates
- Delivery status tracking
- Custom messages

**3. TaskLog**
- Activity history for tasks
- Action types (Created, Started, Completed, etc.)
- Timestamps and descriptions
- Metadata in JSON format

### Weather Module (3 Models)

**1. WeatherData**
- Current weather information
- Temperature, humidity, rainfall
- Wind speed and conditions
- Location-based data

**2. FarmersWeatherAlert**
- Farmer-specific alerts
- Severity levels (Low, Medium, High, Critical)
- Alert types (Rain, Frost, Heat, Wind, Disease, Pest)
- Issue and expiry dates
- Action tracking

**3. WeatherForecast**
- 7-day weather predictions
- Min/max temperatures
- Rainfall probability
- Location-based forecasts

---

## ⚙️ Configuration

### settings.py Key Settings

**Database:**
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# For MySQL:
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.mysql',
#         'NAME': 'farmbuddy',
#         'USER': 'root',
#         'PASSWORD': 'password',
#         'HOST': 'localhost',
#         'PORT': '3306',
#     }
# }
```

**CORS (for frontend connections):**
```python
INSTALLED_APPS = [
    ...
    'corsheaders',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    ...
]

# Development:
CORS_ALLOW_ALL_ORIGINS = True

# Production:
# CORS_ALLOWED_ORIGINS = [
#     'https://your-frontend-domain.com',
# ]
```

**REST Framework:**
```python
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # Change in production
    ],
}
```

### Environment Variables (Production)

Create `.env` file:
```bash
SECRET_KEY=your-secret-key-here
DEBUG=False
ALLOWED_HOSTS=your-domain.com,www.your-domain.com
DATABASE_URL=mysql://user:password@localhost/dbname
```

---

## 🧪 Testing

### Run Tests

```bash
# Run all tests
python manage.py test

# Run specific app tests
python manage.py test crops
python manage.py test farmers

# Run with coverage
pip install coverage
coverage run --source='.' manage.py test
coverage report
```

### Manual API Testing

**Using Django shell:**
```bash
python manage.py shell
```

```python
from crops.models import Crop
from farmers.models import Farmer

# Create a crop
crop = Crop.objects.create(
    name="Tomato",
    season="Summer",
    soil_type="Loamy",
    growth_duration_days=90,
    ...
)

# Query data
all_crops = Crop.objects.all()
kharif_crops = Crop.objects.filter(season="Kharif")
```

**Using Postman:**
1. Import API endpoints
2. Test GET, POST, PUT, DELETE operations
3. Verify response formats

---

## 🚀 Deployment

### Production Checklist

- [ ] Set `DEBUG = False`
- [ ] Configure `ALLOWED_HOSTS`
- [ ] Use environment variables for secrets
- [ ] Switch to production database (PostgreSQL/MySQL)
- [ ] Configure static files (`collectstatic`)
- [ ] Set up HTTPS/SSL
- [ ] Enable specific CORS origins
- [ ] Add authentication (Token/JWT)
- [ ] Set up logging
- [ ] Enable rate limiting
- [ ] Configure backups

### Deploy to Heroku

```bash
# Install Heroku CLI
heroku login

# Create app
heroku create farmbuddy-api

# Add PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Deploy
git push heroku main

# Run migrations
heroku run python manage.py migrate

# Create superuser
heroku run python manage.py createsuperuser
```

### Deploy to AWS/DigitalOcean

1. Set up server (Ubuntu)
2. Install Python, pip, PostgreSQL
3. Clone repository
4. Configure Nginx + Gunicorn
5. Set up SSL with Let's Encrypt
6. Configure environment variables
7. Run migrations and collect static files

---

## 🛠️ Development

### Create New App

```bash
python manage.py startapp appname
```

### Create Migrations

```bash
# After model changes
python manage.py makemigrations

# Apply migrations
python manage.py migrate
```

### Create Superuser

```bash
python manage.py createsuperuser
```

### Django Shell

```bash
python manage.py shell
```

### Database Shell

```bash
python manage.py dbshell
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Add tests** for new features
5. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
6. **Push to branch**
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request**

### Code Style

- Follow PEP 8 guidelines
- Add docstrings to functions and classes
- Write meaningful commit messages
- Add inline comments for complex logic

---

## 📝 Documentation Files

- **README.md** (this file) - Main documentation
- **FLUTTER_DJANGO_INTEGRATION.md** - Flutter integration guide
- **PROJECT_SUMMARY.md** - Complete project overview

---

## 📊 Statistics

- **Total Models:** 14
- **Total Serializers:** 23
- **Total ViewSets:** 14
- **API Endpoints:** 41+
- **Lines of Code:** ~3,600 (backend only)
- **Documentation:** 2,500+ lines

---

## 🔒 Security

**Current (Development):**
- ⚠️ CORS allows all origins
- ⚠️ No authentication required
- ⚠️ DEBUG mode enabled

**Production Setup:**
```python
# settings.py
DEBUG = False
ALLOWED_HOSTS = ['your-domain.com']

CORS_ALLOWED_ORIGINS = [
    'https://your-frontend.com',
]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}
```

---

## 🐛 Troubleshooting

### Port already in use
```bash
# Find process using port 8000
netstat -ano | findstr :8000

# Kill process (Windows)
taskkill /PID <process_id> /F
```

### Migration conflicts
```bash
python manage.py migrate --fake
python manage.py migrate
```

### CORS errors
- Verify `corsheaders` in INSTALLED_APPS
- Check middleware order
- Confirm CORS_ALLOW_ALL_ORIGINS or CORS_ALLOWED_ORIGINS

---

## 📞 Support

**Developer:** Satryam Patel  
**Email:** (your email)  
**GitHub:** https://github.com/Satyam-ptl/FarmBuddy  
**College:** CSE(DS) - Second Year  

---

## 📄 License

This project is for educational purposes as part of CSE(DS) coursework.

---

## 🙏 Acknowledgments

- Django Documentation
- Django REST Framework Documentation
- Stack Overflow Community
- College Faculty and Mentors

---

## 🔗 Related Projects

- **Flutter Frontend:** `farm_buddy_app/` - Mobile application
- **React Frontend:** (Coming soon)
- **Admin Dashboard:** (Coming soon)

---

## 📅 Changelog

### Version 1.0.0 (February 2026)
- ✅ Initial release
- ✅ 4 Django apps (crops, farmers, tasks, weather)
- ✅ 41 API endpoints
- ✅ Complete admin panel
- ✅ CORS configuration
- ✅ Comprehensive documentation

---

**Built with ❤️ for farmers using Django**

**Status:** ✅ Production Ready

---

**Quick Links:**
- [Installation](#-installation)
- [API Documentation](#-api-documentation)
- [Deployment](#-deployment)
- [Contributing](#-contributing)