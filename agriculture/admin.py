from django.contrib import admin
from .models import AgriOfficer, CropCategory, FarmerQuery, AgriAdvisory, AgriUpdate

@admin.register(AgriOfficer)
class AgriOfficerAdmin(admin.ModelAdmin):
    list_display = ['user', 'department', 'specialization', 'employee_id', 'district']
    list_filter = ['district', 'specialization']
    search_fields = ['user__username', 'employee_id', 'district']

@admin.register(CropCategory)
class CropCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'season']
    list_filter = ['season']
    search_fields = ['name']

@admin.register(FarmerQuery)
class FarmerQueryAdmin(admin.ModelAdmin):
    list_display = ['query_id', 'farmer', 'crop_category', 'status', 'created_at', 'assigned_to']
    list_filter = ['status', 'crop_category']
    search_fields = ['query_id', 'title', 'farmer__username']
    date_hierarchy = 'created_at'

@admin.register(AgriAdvisory)
class AgriAdvisoryAdmin(admin.ModelAdmin):
    list_display = ['query', 'officer', 'is_validated', 'validated_by', 'created_at']
    list_filter = ['is_validated', 'created_at']
    search_fields = ['query__query_id', 'officer__user__username']
    date_hierarchy = 'created_at'

@admin.register(AgriUpdate)
class AgriUpdateAdmin(admin.ModelAdmin):
    list_display = ['title', 'update_type', 'district', 'is_urgent', 'created_at', 'officer']
    list_filter = ['update_type', 'is_urgent', 'district']
    search_fields = ['title', 'district']
    date_hierarchy = 'created_at'
