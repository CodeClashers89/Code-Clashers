from django.db import models
from accounts.models import CustomUser

class CityStaff(models.Model):
    """City staff profiles"""
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='city_staff_profile')
    department = models.CharField(max_length=200)
    designation = models.CharField(max_length=200)
    employee_id = models.CharField(max_length=100, unique=True)
    jurisdiction = models.CharField(max_length=200)  # Area of responsibility
    
    def __str__(self):
        return f"{self.user.get_full_name()} - {self.department}"
    
    class Meta:
        verbose_name_plural = "City Staff"
        ordering = ['department']


class ComplaintCategory(models.Model):
    """Categorization of complaints"""
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField()
    icon = models.CharField(max_length=50, blank=True)
    
    def __str__(self):
        return self.name
    
    class Meta:
        verbose_name_plural = "Complaint Categories"
        ordering = ['name']


class Complaint(models.Model):
    """Public complaint submissions"""
    
    STATUS_CHOICES = (
        ('submitted', 'Submitted'),
        ('under_review', 'Under Review'),
        ('in_progress', 'In Progress'),
        ('resolved', 'Resolved'),
        ('closed', 'Closed'),
    )
    
    PRIORITY_CHOICES = (
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('urgent', 'Urgent'),
    )
    
    citizen = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='complaints')
    category = models.ForeignKey(ComplaintCategory, on_delete=models.SET_NULL, null=True, related_name='complaints')
    assigned_to = models.ForeignKey(CityStaff, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_complaints')
    
    title = models.CharField(max_length=200)
    description = models.TextField()
    location = models.CharField(max_length=300)
    image = models.ImageField(upload_to='complaints/', blank=True, null=True)
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='submitted')
    priority = models.CharField(max_length=20, choices=PRIORITY_CHOICES, default='medium')
    
    complaint_id = models.CharField(max_length=50, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    resolved_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"{self.complaint_id} - {self.title}"
    
    class Meta:
        ordering = ['-created_at']


class ComplaintResponse(models.Model):
    """Staff responses to complaints"""
    complaint = models.ForeignKey(Complaint, on_delete=models.CASCADE, related_name='responses')
    staff = models.ForeignKey(CityStaff, on_delete=models.CASCADE, related_name='complaint_responses')
    message = models.TextField()
    action_taken = models.TextField(blank=True)
    image = models.ImageField(upload_to='complaint_responses/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Response to {self.complaint.complaint_id}"
    
    class Meta:
        ordering = ['-created_at']
