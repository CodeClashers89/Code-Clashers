from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('crop-categories', views.CropCategoryViewSet, basename='crop-category')
router.register('queries', views.FarmerQueryViewSet, basename='farmer-query')
router.register('advisories', views.AgriAdvisoryViewSet, basename='agri-advisory')
router.register('updates', views.AgriUpdateViewSet, basename='agri-update')

urlpatterns = [
    path('stats/', views.dashboard_stats, name='dashboard-stats'),
    path('', include(router.urls)),
]
