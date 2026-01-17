from django.db import models
from accounts.models import CustomUser

class Service(models.Model):
    """Registry of all available government services"""
    
    SERVICE_TYPES = (
        ('healthcare', 'Healthcare'),
        ('city', 'City Services'),
        ('agriculture', 'Agriculture'),
        ('education', 'Education'),
        ('welfare', 'Welfare'),
        ('other', 'Other'),
    )
    
    name = models.CharField(max_length=200)
    service_type = models.CharField(max_length=50, choices=SERVICE_TYPES)
    description = models.TextField()
    icon = models.CharField(max_length=50, blank=True)  # Icon class name
    is_active = models.BooleanField(default=True)
    endpoint_url = models.CharField(max_length=200, blank=True)  # API endpoint
    created_by = models.ForeignKey(CustomUser, on_delete=models.SET_NULL, null=True, related_name='created_services')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name
    
    class Meta:
        ordering = ['name']


class ServiceProvider(models.Model):
    """Registered service providers across all services"""
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='service_provider')
    services = models.ManyToManyField(Service, related_name='providers')
    specialization = models.CharField(max_length=200, blank=True)
    license_number = models.CharField(max_length=100, blank=True)
    years_of_experience = models.IntegerField(default=0)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.0)
    total_requests_handled = models.IntegerField(default=0)
    
    def __str__(self):
        return f"{self.user.username} - Service Provider"
    
    class Meta:
        ordering = ['-rating']


class ServiceRequest(models.Model):
    """Unified request tracking across all services"""
    
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    )
    
    PRIORITY_CHOICES = (
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('urgent', 'Urgent'),
    )
    
    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name='requests')
    citizen = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='service_requests')
    provider = models.ForeignKey(ServiceProvider, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_requests')
    
    title = models.CharField(max_length=200)
    description = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    priority = models.CharField(max_length=20, choices=PRIORITY_CHOICES, default='medium')
    
    # Metadata
    reference_id = models.CharField(max_length=50, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"{self.reference_id} - {self.title}"
    
    class Meta:
        ordering = ['-created_at']


class DataExchange(models.Model):
    """Inter-service data sharing mechanism"""
    source_service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name='data_sent')
    target_service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name='data_received')
    data_type = models.CharField(max_length=100)
    data_payload = models.JSONField()
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='data_exchanges')
    exchanged_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.source_service.name} → {self.target_service.name}"
    
    class Meta:
        ordering = ['-exchanged_at']


class SystemMetrics(models.Model):
    """System health and performance metrics"""
    timestamp = models.DateTimeField(auto_now_add=True)
    active_users = models.IntegerField(default=0)
    total_requests = models.IntegerField(default=0)
    avg_response_time = models.FloatField(default=0.0)  # in seconds
    cpu_usage = models.FloatField(default=0.0)
    memory_usage = models.FloatField(default=0.0)
    service_uptime = models.JSONField(default=dict)  # Service-wise uptime
    
    def __str__(self):
        return f"Metrics at {self.timestamp}"
    
    class Meta:
        ordering = ['-timestamp']
