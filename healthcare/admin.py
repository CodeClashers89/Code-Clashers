from django.contrib import admin
from .models import Doctor, Appointment, MedicalRecord, Prescription, FollowUp, DoctorUnavailability

@admin.register(Doctor)
class DoctorAdmin(admin.ModelAdmin):
    list_display = ['user', 'specialization', 'license_number', 'experience_years', 'is_available']
    list_filter = ['specialization', 'is_available']
    search_fields = ['user__username', 'user__first_name', 'user__last_name', 'license_number']

@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display = ['patient', 'doctor', 'appointment_date', 'appointment_time', 'status']
    list_filter = ['status', 'appointment_date']
    search_fields = ['patient__username', 'doctor__user__username']
    date_hierarchy = 'appointment_date'

@admin.register(MedicalRecord)
class MedicalRecordAdmin(admin.ModelAdmin):
    list_display = ['patient', 'doctor', 'created_at']
    list_filter = ['created_at']
    search_fields = ['patient__username', 'diagnosis']
    date_hierarchy = 'created_at'

@admin.register(Prescription)
class PrescriptionAdmin(admin.ModelAdmin):
    list_display = ['medication_name', 'dosage', 'frequency', 'duration']
    search_fields = ['medication_name']

@admin.register(FollowUp)
class FollowUpAdmin(admin.ModelAdmin):
    list_display = ['original_appointment', 'follow_up_appointment', 'created_at']
    date_hierarchy = 'created_at'

@admin.register(DoctorUnavailability)
class DoctorUnavailabilityAdmin(admin.ModelAdmin):
    list_display = ['doctor', 'start_date', 'end_date', 'reason']
    list_filter = ['start_date', 'end_date']
    search_fields = ['doctor__user__username', 'reason']
