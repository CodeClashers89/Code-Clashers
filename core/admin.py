from django.contrib import admin
from .models import Service, ServiceProvider, ServiceRequest, DataExchange, SystemMetrics

@admin.register(Service)
class ServiceAdmin(admin.ModelAdmin):
    list_display = ['name', 'service_type', 'is_active', 'created_at']
    list_filter = ['service_type', 'is_active']
    search_fields = ['name', 'description']

@admin.register(ServiceProvider)
class ServiceProviderAdmin(admin.ModelAdmin):
    list_display = ['user', 'specialization', 'rating', 'total_requests_handled']
    search_fields = ['user__username', 'specialization']
    list_filter = ['rating']

@admin.register(ServiceRequest)
class ServiceRequestAdmin(admin.ModelAdmin):
    list_display = ['reference_id', 'service', 'citizen', 'status', 'priority', 'created_at']
    list_filter = ['status', 'priority', 'service']
    search_fields = ['reference_id', 'title', 'citizen__username']

@admin.register(DataExchange)
class DataExchangeAdmin(admin.ModelAdmin):
    list_display = ['source_service', 'target_service', 'data_type', 'user', 'exchanged_at']
    list_filter = ['source_service', 'target_service']
    
@admin.register(SystemMetrics)
class SystemMetricsAdmin(admin.ModelAdmin):
    list_display = ['timestamp', 'active_users', 'total_requests', 'avg_response_time']
    list_filter = ['timestamp']
