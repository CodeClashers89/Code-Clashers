"""
Django management command to seed the database with sample data
for demonstration purposes.
"""
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from accounts.models import CustomUser, UserProfile, ApprovalRequest
from core.models import Service, ServiceProvider, ServiceRequest
from healthcare.models import Doctor, Appointment, MedicalRecord, Prescription
from city_services.models import CityStaff, ComplaintCategory, Complaint, ComplaintResponse
from agriculture.models import AgriOfficer, CropCategory, FarmerQuery, AgriAdvisory, AgriUpdate
from datetime import datetime, timedelta
from django.utils import timezone
import random

User = get_user_model()

class Command(BaseCommand):
    help = 'Seeds the database with sample data for demonstration'

    def add_arguments(self, parser):
        parser.add_argument(
            '--clear',
            action='store_true',
            help='Clear existing sample data before seeding',
        )

    def handle(self, *args, **kwargs):
        self.stdout.write(self.style.SUCCESS('Starting database seeding...'))

        if kwargs.get('clear'):
            self.stdout.write('Clearing existing sample data...')
            # Clear sample data (keep admin user)
            Complaint.objects.all().delete()
            FarmerQuery.objects.all().delete()
            AgriUpdate.objects.all().delete()
            Appointment.objects.all().delete()
            User.objects.exclude(is_superuser=True).delete()
            Service.objects.all().delete()
            ComplaintCategory.objects.all().delete()
            CropCategory.objects.all().delete()
            
        # Create services
        self.stdout.write('Creating services...')
        healthcare_service, _ = Service.objects.get_or_create(
            name='Healthcare Services',
            defaults={
                'service_type': 'healthcare',
                'description': 'Comprehensive healthcare and telemedicine services',
                'icon': '🏥',
                'is_active': True,
                'endpoint_url': '/api/healthcare/'
            }
        )
        
        city_service, _ = Service.objects.get_or_create(
            name='City Services',
            defaults={
                'service_type': 'city',
                'description': 'Public complaint and urban service management',
                'icon': '🏙️',
                'is_active': True,
                'endpoint_url': '/api/city/'
            }
        )
        
        agri_service, _ = Service.objects.get_or_create(
            name='Agriculture Advisory',
            defaults={
                'service_type': 'agriculture',
                'description': 'Farmer support and agricultural advisory services',
                'icon': '🌾',
                'is_active': True,
                'endpoint_url': '/api/agriculture/'
            }
        )

        # Create sample citizens
        self.stdout.write('Creating sample citizens...')
        citizens = []
        for i in range(1, 6):
            user, created = User.objects.get_or_create(
                username=f'citizen{i}',
                defaults={
                    'email': f'citizen{i}@example.com',
                    'first_name': f'Citizen',
                    'last_name': f'User{i}',
                    'role': 'citizen',
                    'phone_number': f'98765432{i:02d}',
                    'is_approved': True
                }
            )
            if created:
                user.set_password('password123')
                user.save()
                UserProfile.objects.create(
                    user=user,
                    city='Mumbai',
                    state='Maharashtra',
                    pincode='400001'
                )
            citizens.append(user)

        # Create sample doctors
        self.stdout.write('Creating sample doctors...')
        doctors = []
        specializations = ['Cardiology', 'Dermatology', 'Pediatrics', 'Orthopedics', 'General Medicine']
        for i, spec in enumerate(specializations, 1):
            user, created = User.objects.get_or_create(
                username=f'doctor{i}',
                defaults={
                    'email': f'doctor{i}@example.com',
                    'first_name': f'Dr. {spec[:4]}',
                    'last_name': f'Specialist{i}',
                    'role': 'doctor',
                    'phone_number': f'91234567{i:02d}',
                    'is_approved': True
                }
            )
            if created:
                user.set_password('password123')
                user.save()
                UserProfile.objects.create(
                    user=user,
                    city='Mumbai',
                    state='Maharashtra',
                    pincode='400001'
                )
            
            doctor, _ = Doctor.objects.get_or_create(
                user=user,
                defaults={
                    'specialization': spec,
                    'qualification': 'MBBS, MD',
                    'experience_years': random.randint(5, 20),
                    'license_number': f'MH{random.randint(10000, 99999)}',
                    'consultation_fee': random.choice([500, 750, 1000, 1500]),
                    'is_available': True
                }
            )
            doctors.append(doctor)

        # Create sample appointments
        self.stdout.write('Creating sample appointments...')
        appointment_counter = 0
        for doctor in doctors:
            for day_offset in [1, 3, 5]:  # Create appointments on different days
                citizen = random.choice(citizens)
                appointment_date = timezone.now().date() + timedelta(days=day_offset)
                hour = 9 + (appointment_counter % 8)  # 9 AM to 4 PM
                
                Appointment.objects.create(
                    doctor=doctor,
                    patient=citizen,
                    appointment_date=appointment_date,
                    appointment_time=f'{hour:02d}:00:00',
                    reason=random.choice([
                        'Regular checkup',
                        'Follow-up consultation',
                        'Fever and cold',
                        'Back pain',
                        'Skin allergy'
                    ]),
                    status=random.choice(['scheduled', 'completed'])
                )
                appointment_counter += 1
                if appointment_counter >= 10:
                    break
            if appointment_counter >= 10:
                break

        # Create sample city staff
        self.stdout.write('Creating sample city staff...')
        departments = ['Roads', 'Water Supply', 'Electricity', 'Sanitation']
        city_staff_list = []
        for i, dept in enumerate(departments, 1):
            user, created = User.objects.get_or_create(
                username=f'citystaff{i}',
                defaults={
                    'email': f'citystaff{i}@example.com',
                    'first_name': f'{dept}',
                    'last_name': f'Officer{i}',
                    'role': 'city_staff',
                    'phone_number': f'92345678{i:02d}',
                    'is_approved': True
                }
            )
            if created:
                user.set_password('password123')
                user.save()
            
            staff, _ = CityStaff.objects.get_or_create(
                user=user,
                defaults={
                    'department': dept,
                    'designation': 'Senior Officer',
                    'employee_id': f'CS{random.randint(1000, 9999)}',
                    'jurisdiction': 'Zone A'
                }
            )
            city_staff_list.append(staff)

        # Create complaint categories
        self.stdout.write('Creating complaint categories...')
        categories = ['Roads', 'Water Supply', 'Electricity', 'Sanitation', 'Street Lights']
        category_objects = []
        for cat in categories:
            obj, _ = ComplaintCategory.objects.get_or_create(
                name=cat,
                defaults={'description': f'{cat} related issues'}
            )
            category_objects.append(obj)

        # Create sample complaints
        self.stdout.write('Creating sample complaints...')
        complaint_titles = [
            'Pothole on Main Street',
            'Water leakage in area',
            'Street light not working',
            'Garbage not collected',
            'Power outage issue',
            'Broken footpath',
            'Drainage problem',
            'Traffic signal malfunction'
        ]
        import uuid
        for i in range(8):
            citizen = random.choice(citizens)
            category = random.choice(category_objects)
            
            Complaint.objects.create(
                citizen=citizen,
                category=category,
                title=f'{complaint_titles[i]} - Report',
                description='This is a sample complaint description for demonstration purposes.',
                location=f'Street {random.randint(1, 50)}, Area {random.choice(["A", "B", "C"])}',
                status=random.choice(['submitted', 'in_progress', 'resolved']),
                priority=random.choice(['low', 'medium', 'high']),
                complaint_id=f"CMP-{uuid.uuid4().hex[:8].upper()}"
            )

        # Create agricultural officers
        self.stdout.write('Creating agricultural officers...')
        agri_officers = []
        for i in range(3):
            user, created = User.objects.get_or_create(
                username=f'agriofficer{i+1}',
                defaults={
                    'email': f'agriofficer{i+1}@example.com',
                    'first_name': f'Agri',
                    'last_name': f'Officer{i+1}',
                    'role': 'agri_officer',
                    'phone_number': f'93456789{i:02d}',
                    'is_approved': True
                }
            )
            if created:
                user.set_password('password123')
                user.save()
            
            officer, _ = AgriOfficer.objects.get_or_create(
                user=user,
                defaults={
                    'department': 'Agriculture Extension',
                    'specialization': random.choice(['Crop Management', 'Pest Control', 'Soil Science']),
                    'employee_id': f'AO{random.randint(1000, 9999)}',
                    'district': random.choice(['Pune', 'Nashik', 'Nagpur'])
                }
            )
            agri_officers.append(officer)

        # Create crop categories
        self.stdout.write('Creating crop categories...')
        crops = ['Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Vegetables']
        crop_objects = []
        for crop in crops:
            obj, _ = CropCategory.objects.get_or_create(
                name=crop,
                defaults={'description': f'{crop} cultivation'}
            )
            crop_objects.append(obj)

        # Create farmer queries
        self.stdout.write('Creating farmer queries...')
        query_titles = [
            'Pest control for wheat crop',
            'Best fertilizer for rice',
            'Water management tips',
            'Soil testing procedure',
            'Government subsidy information',
            'Crop rotation advice',
            'Organic farming methods'
        ]
        for i in range(7):
            citizen = random.choice(citizens)
            crop = random.choice(crop_objects)
            
            FarmerQuery.objects.create(
                farmer=citizen,
                crop_category=crop,
                title=f'{query_titles[i]} - Inquiry',
                description='This is a sample farmer query for demonstration purposes.',
                location=f'Village {random.randint(1, 20)}',
                status=random.choice(['submitted', 'in_progress', 'resolved']),
                query_id=f"AGR-{uuid.uuid4().hex[:8].upper()}"
            )

        # Create agricultural updates
        self.stdout.write('Creating agricultural updates...')
        update_types = ['weather', 'market', 'scheme', 'advisory', 'pest']
        for i in range(8):
            officer = random.choice(agri_officers)
            
            AgriUpdate.objects.get_or_create(
                officer=officer,
                title=f'Important {random.choice(update_types).title()} Update',
                defaults={
                    'content': 'This is a sample agricultural update for farmers in the region.',
                    'update_type': random.choice(update_types),
                    'crop_category': random.choice(crop_objects),
                    'district': officer.district,
                    'is_urgent': random.choice([True, False])
                }
            )

        self.stdout.write(self.style.SUCCESS('✅ Database seeding completed successfully!'))
        self.stdout.write(self.style.SUCCESS('Created:'))
        self.stdout.write(f'  - {User.objects.filter(role="citizen").count()} Citizens')
        self.stdout.write(f'  - {Doctor.objects.count()} Doctors')
        self.stdout.write(f'  - {Appointment.objects.count()} Appointments')
        self.stdout.write(f'  - {CityStaff.objects.count()} City Staff')
        self.stdout.write(f'  - {Complaint.objects.count()} Complaints')
        self.stdout.write(f'  - {AgriOfficer.objects.count()} Agricultural Officers')
        self.stdout.write(f'  - {FarmerQuery.objects.count()} Farmer Queries')
        self.stdout.write(f'  - {AgriUpdate.objects.count()} Agricultural Updates')
        self.stdout.write(self.style.SUCCESS('\nYou can now login with:'))
        self.stdout.write('  Username: citizen1, Password: password123 (Citizen)')
        self.stdout.write('  Username: doctor1, Password: password123 (Doctor)')
        self.stdout.write('  Username: citystaff1, Password: password123 (City Staff)')
        self.stdout.write('  Username: agriofficer1, Password: password123 (Agri Officer)')
