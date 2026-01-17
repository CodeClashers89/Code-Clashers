from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('doctors', views.DoctorViewSet, basename='doctor')
router.register('appointments', views.AppointmentViewSet, basename='appointment')
router.register('medical-records', views.MedicalRecordViewSet, basename='medical-record')
router.register('prescriptions', views.PrescriptionViewSet, basename='prescription')
router.register('unavailability', views.DoctorUnavailabilityViewSet, basename='unavailability')

urlpatterns = [
    path('', include(router.urls)),
]
