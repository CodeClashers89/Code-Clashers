# Digital Public Infrastructure - Setup Guide

## Prerequisites
- Python 3.10 or higher
- pip (Python package manager)
- Git (optional)

## Installation Steps

### 1. Navigate to Project Directory
```bash
cd "c:\coding\AU hackathon"
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Run Migrations (Already Done)
```bash
python manage.py migrate
```

### 4. Create Superuser (Already Done)
Superuser credentials:
- Username: `admin`
- Email: `admin@dpi.gov`
- Password: Set during creation

### 5. Start Development Server
```bash
python manage.py runserver
```

Server will start at: http://127.0.0.1:8000/

## Access Points

### Web Interface
- **Landing Page**: http://127.0.0.1:8000/
- **Citizen Portal**: http://127.0.0.1:8000/citizen/
- **Doctor Dashboard**: http://127.0.0.1:8000/doctor/
- **City Staff Dashboard**: http://127.0.0.1:8000/city-staff/
- **Agri Officer Dashboard**: http://127.0.0.1:8000/agri-officer/
- **Admin Dashboard**: http://127.0.0.1:8000/admin-dashboard/
- **Django Admin**: http://127.0.0.1:8000/admin/

### API Endpoints
- **Accounts**: http://127.0.0.1:8000/api/accounts/
- **Core**: http://127.0.0.1:8000/api/core/
- **Healthcare**: http://127.0.0.1:8000/api/healthcare/
- **City Services**: http://127.0.0.1:8000/api/city/
- **Agriculture**: http://127.0.0.1:8000/api/agriculture/

## Project Structure

```
AU hackathon/
├── dpi_platform/          # Main project settings
│   ├── settings.py        # Django configuration
│   ├── urls.py            # URL routing
│   └── wsgi.py
├── accounts/              # User authentication
│   ├── models.py          # User models
│   ├── views.py           # Auth endpoints
│   └── serializers.py
├── core/                  # Service registry
│   ├── models.py          # Core platform models
│   ├── views.py           # Service APIs
│   └── serializers.py
├── healthcare/            # Healthcare service
│   ├── models.py          # Doctor, Appointment, etc.
│   ├── views.py           # Healthcare APIs
│   └── serializers.py
├── city_services/         # City services
│   ├── models.py          # Complaint models
│   ├── views.py           # Complaint APIs
│   └── serializers.py
├── agriculture/           # Agriculture service
│   ├── models.py          # Farmer query models
│   ├── views.py           # Agriculture APIs
│   └── serializers.py
├── templates/             # HTML templates
│   ├── index.html
│   ├── citizen/
│   ├── healthcare/
│   ├── city/
│   ├── agriculture/
│   └── admin/
├── static/                # Static files
│   ├── css/
│   │   └── styles.css
│   └── js/
│       └── main.js
├── manage.py              # Django management
└── requirements.txt       # Python dependencies
```

## Testing the Platform

### 1. Create Test Users via Django Admin
1. Go to http://127.0.0.1:8000/admin/
2. Login with admin credentials
3. Create users with different roles:
   - Citizen
   - Doctor (requires approval)
   - City Staff (requires approval)
   - Agricultural Officer (requires approval)

### 2. Test API Endpoints

#### Register a Citizen
```bash
curl -X POST http://127.0.0.1:8000/api/accounts/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "citizen1",
    "email": "citizen@example.com",
    "password": "password123",
    "password_confirm": "password123",
    "first_name": "John",
    "last_name": "Doe",
    "role": "citizen",
    "phone_number": "1234567890"
  }'
```

#### Login
```bash
curl -X POST http://127.0.0.1:8000/api/accounts/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "citizen1",
    "password": "password123"
  }'
```

#### Get Dashboard Stats (with token)
```bash
curl -X GET http://127.0.0.1:8000/api/core/dashboard/stats/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 3. Test Web Interface
1. Open http://127.0.0.1:8000/
2. Navigate to different dashboards
3. Test forms and interactions

## Troubleshooting

### Server Won't Start
- Check if port 8000 is already in use
- Verify Python version: `python --version`
- Reinstall dependencies: `pip install -r requirements.txt`

### Database Errors
- Delete db.sqlite3 and run migrations again:
  ```bash
  python manage.py migrate
  python manage.py createsuperuser
  ```

### Static Files Not Loading
- Run: `python manage.py collectstatic`
- Check STATIC_URL in settings.py

### API Returns 401 Unauthorized
- Ensure you're including the JWT token in headers:
  ```
  Authorization: Bearer YOUR_ACCESS_TOKEN
  ```

## Development Tips

### Adding New Services
1. Create new Django app: `python manage.py startapp service_name`
2. Add models in `service_name/models.py`
3. Create serializers in `service_name/serializers.py`
4. Add views in `service_name/views.py`
5. Configure URLs in `service_name/urls.py`
6. Include in main `urls.py`
7. Add to INSTALLED_APPS in settings.py
8. Run migrations: `python manage.py makemigrations && python manage.py migrate`

### Database Management
- **View data**: Use Django admin at http://127.0.0.1:8000/admin/
- **Shell access**: `python manage.py shell`
- **Reset database**: Delete db.sqlite3 and run migrations

### API Testing Tools
- **Postman**: Import API collection
- **curl**: Command-line testing
- **Django REST Framework**: Built-in browsable API at http://127.0.0.1:8000/api/

## Production Deployment

### Environment Variables
Create `.env` file:
```
DEBUG=False
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=your-domain.com
DATABASE_URL=postgresql://user:pass@localhost/dbname
```

### Database Migration
1. Install PostgreSQL
2. Update DATABASES in settings.py
3. Run migrations: `python manage.py migrate`

### Static Files
```bash
python manage.py collectstatic
```

### WSGI Server
```bash
pip install gunicorn
gunicorn dpi_platform.wsgi:application
```

## Support

For issues or questions:
- Check walkthrough.md for feature documentation
- Review implementation_plan.md for architecture details
- Examine model definitions in respective apps
- Use Django admin for data management

**Built for AU Hackathon 2026** 🚀
