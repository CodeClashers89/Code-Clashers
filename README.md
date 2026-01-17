# Digital Public Infrastructure (DPI) Platform

## Project Overview
The **Digital Public Infrastructure (DPI)** platform is a unified government service portal designed to provide citizens with seamless access to essential services like Healthcare, Agriculture, and City Management. Built with a modular architecture, it features a robust Django backend and a modern Flutter mobile application, enabling secure data exchange and real-time service tracking for citizens, service providers, and government administrators.


## Key Features
- **Multi-role Ecosystem**: Specialized dashboards for Citizens, Doctors, City Staff, Agricultural Officers, and Government Admins.
- **Unified Healthcare**: Appointment booking, digital medical records, and patient history tracking.
- **Smart City Services**: Civic complaint reporting with location tracking and resolution workflows.
- **Agri-Tech Support**: Expert queries for farmers, pest alerts, and real-time market updates.

- **Advanced Admin Analytics**: Comprehensive dashboard for system health monitoring, user distribution, and service performance metrics.
- **Secure Authentication**: JWT-based secure login and multi-role approval workflows for service providers.

## Tech Stack
### Backend
- **Framework**: Django 5.1
- **API**: Django REST Framework (DRF)
- **Security**: SimpleJWT (JWT Authentication)
- **Database**: SQLite (Development)
- **Utilities**: django-cors-headers, Pillow, python-decouple

### Mobile
- **Framework**: Flutter
- **Language**: Dart
- **Storage**: Secure Local Caching

## Local Setup Guide

### 1. Prerequisites
- Python 3.10+
- Flutter SDK (for mobile)
- pip

### 2. Backend Installation
```bash
# Clone the repository and navigate to the root
cd "AU hackathon"

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Create a superuser (if not already done)
python manage.py createsuperuser
```

### 3. Run Development Server
```bash
python manage.py runserver
```
The backend will be available at: [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

### 4. Mobile App Setup
```bash
cd mobile_app
flutter pub get
flutter run
```
*Note: See `mobile_app/QUICK_SETUP.md` for physical device testing.*

## Test Credentials

### Admin Access
- **URL**: [http://127.0.0.1:8000/admin-dashboard/](http://127.0.0.1:8000/admin-dashboard/)
- **Username**: `admin`
- **Password**: `admin123` (or as set during superuser creation)

### Demo Users (Password: `password123`)
| Role | Username | Dashboard URL |
| :--- | :--- | :--- |
| **Citizen** | `citizen1` | `/citizen/` |
| **Doctor** | `doctor1` | `/doctor/` |
| **City Staff** | `citystaff1` | `/city-staff/` |
| **Agri Officer** | `agriofficer1` | `/agri-officer/` |

---
**Built for AU Hackathon 2026** 🚀
