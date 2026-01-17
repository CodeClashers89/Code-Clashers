from django import forms

DISTRICT_CHOICES = [
    ("Ahmedabad", "Ahmedabad"),
    ("Rajkot", "Rajkot"),
    ("Surat", "Surat"),
    ("Vadodara", "Vadodara"),
    ("Pune", "Pune"),
    ("Nagpur", "Nagpur"),
    ("Nashik", "Nashik"),
    ("Aurangabad", "Aurangabad"),
    ("Ludhiana", "Ludhiana"),
    ("Amritsar", "Amritsar"),
    ("Jalandhar", "Jalandhar"),
    ("Gurgaon", "Gurgaon"),
    ("Lucknow", "Lucknow"),
    ("Kanpur Nagar", "Kanpur Nagar"),
    ("Varanasi", "Varanasi"),
    ("Patna", "Patna"),
    ("Gaya", "Gaya"),
    ("Chennai", "Chennai"),
    ("Coimbatore", "Coimbatore"),
    ("Madurai", "Madurai"),
    ("Guntur", "Guntur"),
    ("Warangal", "Warangal"),
    ("Kolkata", "Kolkata"),
    ("Nadia", "Nadia"),
    ("Howrah", "Howrah"),
    ("Jaipur", "Jaipur"),
    ("Jodhpur", "Jodhpur"),
    ("Bikaner", "Bikaner"),
]

class PatientForm(forms.Form):
    age = forms.IntegerField(widget=forms.NumberInput(attrs={'class': 'form-input'}))
    gender = forms.ChoiceField(
        choices=[("M", "Male"), ("F", "Female")],
        widget=forms.Select(attrs={'class': 'form-select'})
    )
    bmi = forms.FloatField(widget=forms.NumberInput(attrs={'class': 'form-input', 'step': '0.1'}))

    smoking = forms.ChoiceField(
        choices=[("low", "Low"), ("moderate", "Moderate"), ("high", "High")],
        widget=forms.Select(attrs={'class': 'form-select'})
    )
    alcohol = forms.ChoiceField(
        choices=[("low", "Low"), ("moderate", "Moderate"), ("high", "High")],
        widget=forms.Select(attrs={'class': 'form-select'})
    )
    activity = forms.ChoiceField(
        choices=[("low", "Low"), ("moderate", "Moderate"), ("high", "High")],
        widget=forms.Select(attrs={'class': 'form-select'})
    )

    family_diabetes = forms.BooleanField(required=False)
    family_heart = forms.BooleanField(required=False)
    family_cancer = forms.BooleanField(required=False)

class FarmerForm(forms.Form):
    location = forms.ChoiceField(
        choices=DISTRICT_CHOICES,
        label="District",
        widget=forms.Select(attrs={'class': 'form-select'})
    )

    season = forms.ChoiceField(
        choices=[
            ("Kharif", "Kharif"),
            ("Rabi", "Rabi")
        ],
        widget=forms.Select(attrs={'class': 'form-select'})
    )

    soil_type = forms.ChoiceField(
        choices=[
            ("Black", "Black"),
            ("Loamy", "Loamy"),
            ("Clay", "Clay"),
            ("Sandy", "Sandy"),
            ("Red", "Red"),
            ("Alluvial", "Alluvial"),
        ],
        widget=forms.Select(attrs={'class': 'form-select'})
    )

    irrigation = forms.ChoiceField(
        choices=[
            ("Yes", "Yes"),
            ("No", "No")
        ],
        widget=forms.Select(attrs={'class': 'form-select'})
    )

    rainfall = forms.ChoiceField(
        choices=[
            ("Low", "Low"),
            ("Medium", "Medium"),
            ("High", "High")
        ],
        widget=forms.Select(attrs={'class': 'form-select'})
    )

    land_size = forms.FloatField(
        label="Land Size (acres)",
        widget=forms.NumberInput(attrs={'class': 'form-input', 'step': '0.1'})
    )