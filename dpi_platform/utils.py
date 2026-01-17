import joblib
import numpy as np
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Load Patient Models
diabetes_model = joblib.load(os.path.join(BASE_DIR, "ml/diabetes_model.pkl"))
heart_model = joblib.load(os.path.join(BASE_DIR, "ml/heart_model.pkl"))
cancer_model = joblib.load(os.path.join(BASE_DIR, "ml/cancer_model.pkl"))
scaler = joblib.load(os.path.join(BASE_DIR, "ml/scaler.pkl"))

# Load Agriculture Models
crop_model = joblib.load(os.path.join(BASE_DIR, "ml/crop_model.pkl"))
yield_model = joblib.load(os.path.join(BASE_DIR, "ml/yield_model.pkl"))
encoders = joblib.load(os.path.join(BASE_DIR, "ml/agri_encoders.pkl"))