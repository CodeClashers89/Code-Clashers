from django.db import models
from accounts.models import CustomUser

class AgriOfficer(models.Model):
    """Agricultural officer profiles"""
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='agri_officer_profile')
    department = models.CharField(max_length=200)
    specialization = models.CharField(max_length=200)  # Crop science, soil, pest management, etc.
    employee_id = models.CharField(max_length=100, unique=True)
    district = models.CharField(max_length=100)
    
    def __str__(self):
        return f"{self.user.get_full_name()} - {self.specialization}"
    
    class Meta:
        ordering = ['district']


class CropCategory(models.Model):
    """Crop categorization"""
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField()
    season = models.CharField(max_length=50, blank=True)  # Kharif, Rabi, Zaid
    
    def __str__(self):
        return self.name
    
    class Meta:
        verbose_name_plural = "Crop Categories"
        ordering = ['name']


class FarmerQuery(models.Model):
    """Farmer questions and issues"""
    
    STATUS_CHOICES = (
        ('submitted', 'Submitted'),
        ('under_review', 'Under Review'),
        ('answered', 'Answered'),
        ('closed', 'Closed'),
    )
    
    farmer = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='farmer_queries')
    crop_category = models.ForeignKey(CropCategory, on_delete=models.SET_NULL, null=True, blank=True, related_name='queries')
    assigned_to = models.ForeignKey(AgriOfficer, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_queries')
    
    title = models.CharField(max_length=200)
    description = models.TextField()
    location = models.CharField(max_length=200, blank=True)
    image = models.ImageField(upload_to='farmer_queries/', blank=True, null=True)
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='submitted')
    query_id = models.CharField(max_length=50, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.query_id} - {self.title}"
    
    class Meta:
        verbose_name_plural = "Farmer Queries"
        ordering = ['-created_at']


class AgriAdvisory(models.Model):
    """Expert advice and responses"""
    query = models.ForeignKey(FarmerQuery, on_delete=models.CASCADE, related_name='advisories')
    officer = models.ForeignKey(AgriOfficer, on_delete=models.CASCADE, related_name='advisories_given')
    advice = models.TextField()
    is_validated = models.BooleanField(default=False)  # Validated by senior officer
    validated_by = models.ForeignKey(AgriOfficer, on_delete=models.SET_NULL, null=True, blank=True, related_name='validated_advisories')
    attachments = models.FileField(upload_to='agri_advisories/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Advisory for {self.query.query_id}"
    
    class Meta:
        verbose_name_plural = "Agricultural Advisories"
        ordering = ['-created_at']


class AgriUpdate(models.Model):
    """Agricultural news and updates"""
    
    UPDATE_TYPES = (
        ('weather', 'Weather Alert'),
        ('market', 'Market Price'),
        ('scheme', 'Government Scheme'),
        ('advisory', 'General Advisory'),
        ('pest', 'Pest Alert'),
    )
    
    officer = models.ForeignKey(AgriOfficer, on_delete=models.CASCADE, related_name='updates_posted')
    title = models.CharField(max_length=200)
    content = models.TextField()
    update_type = models.CharField(max_length=20, choices=UPDATE_TYPES)
    crop_category = models.ForeignKey(CropCategory, on_delete=models.SET_NULL, null=True, blank=True, related_name='updates')
    district = models.CharField(max_length=100, blank=True)  # Target district
    image = models.ImageField(upload_to='agri_updates/', blank=True, null=True)
    is_urgent = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.title} - {self.get_update_type_display()}"
    
    class Meta:
        ordering = ['-created_at']
