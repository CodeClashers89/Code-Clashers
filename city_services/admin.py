from django.contrib import admin
from .models import CityStaff, ComplaintCategory, Complaint, ComplaintResponse

@admin.register(CityStaff)
class CityStaffAdmin(admin.ModelAdmin):
    list_display = ['user', 'department', 'designation', 'employee_id', 'jurisdiction']
    list_filter = ['department']
    search_fields = ['user__username', 'employee_id', 'department']

@admin.register(ComplaintCategory)
class ComplaintCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'description']
    search_fields = ['name']

@admin.register(Complaint)
class ComplaintAdmin(admin.ModelAdmin):
    list_display = ['complaint_id', 'citizen', 'category', 'status', 'priority', 'created_at', 'assigned_to']
    list_filter = ['status', 'priority', 'category']
    search_fields = ['complaint_id', 'title', 'citizen__username']
    date_hierarchy = 'created_at'

@admin.register(ComplaintResponse)
class ComplaintResponseAdmin(admin.ModelAdmin):
    list_display = ['complaint', 'staff', 'created_at']
    list_filter = ['created_at']
    search_fields = ['complaint__complaint_id', 'staff__user__username']
    date_hierarchy = 'created_at'
