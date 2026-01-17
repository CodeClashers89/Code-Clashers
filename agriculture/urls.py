from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('crop-categories', views.CropCategoryViewSet, basename='crop-category')
router.register('queries', views.FarmerQueryViewSet, basename='farmer-query')
router.register('updates', views.AgriUpdateViewSet, basename='agri-update')

urlpatterns = [
    path('', include(router.urls)),
]
