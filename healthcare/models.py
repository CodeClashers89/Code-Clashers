from django.db import models
from accounts.models import CustomUser

class Doctor(models.Model):
    """Doctor profiles with specialization"""
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='doctor_profile')
    specialization = models.CharField(max_length=200)
    qualification = models.CharField(max_length=200)
    license_number = models.CharField(max_length=100, unique=True)
    experience_years = models.IntegerField(default=0)
    consultation_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    hospital_affiliation = models.CharField(max_length=200, blank=True)
    is_available = models.BooleanField(default=True)
    
    def __str__(self):
        return f"Dr. {self.user.get_full_name()} - {self.specialization}"
    
    class Meta:
        ordering = ['user__first_name']


class Appointment(models.Model):
    """Appointment booking and scheduling"""
    
    STATUS_CHOICES = (
        ('scheduled', 'Scheduled'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
        ('no_show', 'No Show'),
    )
    
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name='appointments')
    patient = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='patient_appointments')
    appointment_date = models.DateField()
    appointment_time = models.TimeField()
    reason = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='scheduled')
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.patient.username} - Dr. {self.doctor.user.last_name} on {self.appointment_date}"
    
    class Meta:
        ordering = ['-appointment_date', '-appointment_time']
        unique_together = ['doctor', 'appointment_date', 'appointment_time']


class MedicalRecord(models.Model):
    """Patient medical history and records"""
    patient = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='medical_records')
    doctor = models.ForeignKey(Doctor, on_delete=models.SET_NULL, null=True, related_name='created_records')
    appointment = models.ForeignKey(Appointment, on_delete=models.SET_NULL, null=True, blank=True, related_name='medical_record')
    
    diagnosis = models.TextField()
    symptoms = models.TextField()
    vital_signs = models.JSONField(default=dict)  # BP, temperature, pulse, etc.
    test_results = models.TextField(blank=True)
    treatment_plan = models.TextField()
    notes = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Medical Record - {self.patient.username} on {self.created_at.date()}"
    
    class Meta:
        ordering = ['-created_at']


class Prescription(models.Model):
    """Medication prescriptions"""
    medical_record = models.ForeignKey(MedicalRecord, on_delete=models.CASCADE, related_name='prescriptions')
    medication_name = models.CharField(max_length=200)
    dosage = models.CharField(max_length=100)
    frequency = models.CharField(max_length=100)
    duration = models.CharField(max_length=100)
    instructions = models.TextField(blank=True)
    
    def __str__(self):
        return f"{self.medication_name} - {self.dosage}"
    
    class Meta:
        ordering = ['medication_name']


class FollowUp(models.Model):
    """Follow-up appointment tracking"""
    original_appointment = models.ForeignKey(Appointment, on_delete=models.CASCADE, related_name='follow_ups')
    follow_up_appointment = models.ForeignKey(Appointment, on_delete=models.CASCADE, related_name='original_appointment')
    reason = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Follow-up for {self.original_appointment}"
    
    class Meta:
        ordering = ['-created_at']


class DoctorUnavailability(models.Model):
    """Doctor availability management"""
    RECURRENCE_CHOICES = (
        ('none', 'None'),
        ('daily', 'Daily'),
        ('weekly', 'Weekly'),
    )
    
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name='unavailability_periods')
    start_date = models.DateField()
    end_date = models.DateField()
    start_time = models.TimeField(null=True, blank=True)
    end_time = models.TimeField(null=True, blank=True)
    is_recurring = models.BooleanField(default=False)
    recurrence_pattern = models.CharField(max_length=20, choices=RECURRENCE_CHOICES, default='none')
    reason = models.CharField(max_length=200)
    
    def __str__(self):
        return f"Dr. {self.doctor.user.last_name} unavailable: {self.start_date} to {self.end_date}"
    
    class Meta:
        ordering = ['-start_date']
