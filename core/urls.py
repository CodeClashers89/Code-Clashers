from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('services', views.ServiceViewSet, basename='service')
router.register('requests', views.ServiceRequestViewSet, basename='service-request')

urlpatterns = [
    path('dashboard/stats/', views.dashboard_stats, name='dashboard-stats'),
    path('', include(router.urls)),
]
