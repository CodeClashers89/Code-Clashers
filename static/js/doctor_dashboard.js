// Doctor Dashboard JavaScript

// API Base URL
const API_BASE = '/api/healthcare';

// State
let currentSection = 'dashboard';
let appointments = [];
let activeAppointmentId = null;
let patients = [];
let records = [];
let unavailabilityPeriods = [];
let doctorProfile = null;

// Initialize
document.addEventListener('DOMContentLoaded', function () {
    initializeSidebarNavigation();
    loadDoctorProfile();
    loadDashboardData();
    setupEventListeners();
});

// Sidebar Navigation
function initializeSidebarNavigation() {
    const sidebarLinks = document.querySelectorAll('.sidebar-link');
    sidebarLinks.forEach(link => {
        link.addEventListener('click', function (e) {
            e.preventDefault();
            const section = this.getAttribute('data-section');
            if (section) {
                switchSection(section);
            }
        });
    });
}

function switchSection(section) {
    // Update active link
    document.querySelectorAll('.sidebar-link').forEach(link => {
        link.classList.remove('active');
    });
    document.querySelector(`[data-section="${section}"]`).classList.add('active');

    // Update active section
    document.querySelectorAll('.section-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(`${section}-section`).classList.add('active');

    currentSection = section;

    // Load section data
    loadSectionData(section);
}

function loadSectionData(section) {
    switch (section) {
        case 'dashboard':
            loadDashboardData();
            break;
        case 'appointments':
            loadAllAppointments();
            break;
        case 'patients':
            loadPatients();
            break;
        case 'records':
            loadMedicalRecords();
            break;
        case 'unavailability':
            loadUnavailability();
            break;
        case 'profile':
            displayProfile();
            break;
    }
}

// Load Doctor Profile
async function loadDoctorProfile() {
    try {
        const response = await fetch(`${API_BASE}/doctors/`, {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
            }
        });

        if (response.ok) {
            const data = await response.json();
            const doctors = data.results || data;
            // Find current doctor's profile
            doctorProfile = doctors.find(d => d.user.id === getCurrentUserId()) || doctors[0];
            updateProfileDisplay();
        }
    } catch (error) {
        console.error('Error loading doctor profile:', error);
    }
}

function updateProfileDisplay() {
    if (!doctorProfile) return;

    const initials = (doctorProfile.user.first_name[0] + doctorProfile.user.last_name[0]).toUpperCase();
    document.getElementById('profile-avatar').textContent = initials;
    document.getElementById('profile-full-name').textContent = `${doctorProfile.user.first_name} ${doctorProfile.user.last_name}`;
    document.getElementById('profile-specialization').textContent = doctorProfile.specialization;
    document.getElementById('profile-email').textContent = doctorProfile.user.email;
    document.getElementById('profile-phone').textContent = doctorProfile.user.phone_number || 'N/A';
    document.getElementById('profile-license').textContent = doctorProfile.license_number;
    document.getElementById('profile-qualification').textContent = doctorProfile.qualification;
    document.getElementById('profile-experience').textContent = doctorProfile.experience_years;
    document.getElementById('profile-fee').textContent = doctorProfile.consultation_fee;
    document.getElementById('profile-hospital').textContent = doctorProfile.hospital_affiliation || 'N/A';

    const availBadge = document.getElementById('profile-availability');
    if (doctorProfile.is_available) {
        availBadge.textContent = 'Available';
        availBadge.className = 'badge badge-success';
    } else {
        availBadge.textContent = 'Unavailable';
        availBadge.className = 'badge badge-danger';
    }
}

function displayProfile() {
    updateProfileDisplay();
}

// Dashboard Data
async function loadDashboardData() {
    try {
        await loadAllAppointments();
        updateDashboardStats();
        displayTodaySchedule();
    } catch (error) {
        console.error('Error loading dashboard:', error);
    }
}

function updateDashboardStats() {
    const today = new Date().toISOString().split('T')[0];

    const todayAppointments = appointments.filter(apt =>
        apt.appointment_date === today
    );

    const pendingAppointments = appointments.filter(apt =>
        apt.status === 'scheduled'
    );

    const completedToday = appointments.filter(apt =>
        apt.appointment_date === today && apt.status === 'completed'
    );

    // Get unique patients
    const uniquePatients = new Set(appointments.map(apt => apt.patient.id));

    document.getElementById('today-appointments').textContent = todayAppointments.length;
    document.getElementById('total-patients').textContent = uniquePatients.size;
    document.getElementById('pending-appointments').textContent = pendingAppointments.length;
    document.getElementById('completed-today').textContent = completedToday.length;
}

function displayTodaySchedule() {
    const today = new Date().toISOString().split('T')[0];
    const todayAppointments = appointments.filter(apt =>
        apt.appointment_date === today
    ).sort((a, b) => a.appointment_time.localeCompare(b.appointment_time));

    const tbody = document.getElementById('today-schedule');

    if (todayAppointments.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="5" class="text-center">
                    <div class="empty-state">
                        <div class="empty-state-icon">📅</div>
                        <p>No appointments scheduled for today</p>
                    </div>
                </td>
            </tr>
        `;
        return;
    }

    tbody.innerHTML = todayAppointments.map(apt => `
        <tr>
            <td>${formatTime(apt.appointment_time)}</td>
            <td>${apt.patient.first_name} ${apt.patient.last_name}</td>
            <td>${apt.reason}</td>
            <td>${getStatusBadge(apt.status)}</td>
            <td>
                <div class="action-buttons">
                    <button class="btn btn-sm btn-primary" onclick="viewAppointment(${apt.id})">View</button>
                    ${apt.status === 'scheduled' ? `
                        <button class="btn btn-sm btn-secondary" onclick="completeAppointment(${apt.id})">Complete</button>
                    ` : ''}
                </div>
            </td>
        </tr>
    `).join('');
}

// Appointments
async function loadAllAppointments() {
    try {
        const response = await fetch(`${API_BASE}/appointments/`, {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
            }
        });

        if (response.ok) {
            const data = await response.json();
            appointments = data.results || data;
            displayAppointments();
        }
    } catch (error) {
        console.error('Error loading appointments:', error);
        showNotification('Error loading appointments', 'error');
    }
}

function displayAppointments() {
    const tbody = document.getElementById('appointments-table');

    if (appointments.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="6" class="text-center">
                    <div class="empty-state">
                        <div class="empty-state-icon">📋</div>
                        <p>No appointments found</p>
                    </div>
                </td>
            </tr>
        `;
        return;
    }

    let filteredAppointments = [...appointments];

    // Apply filters
    const statusFilter = document.getElementById('appointment-status-filter')?.value;
    const dateFilter = document.getElementById('appointment-date-filter')?.value;
    const searchFilter = document.getElementById('appointment-search')?.value.toLowerCase();

    if (statusFilter) {
        filteredAppointments = filteredAppointments.filter(apt => apt.status === statusFilter);
    }

    if (dateFilter) {
        filteredAppointments = filteredAppointments.filter(apt => apt.appointment_date === dateFilter);
    }

    if (searchFilter) {
        filteredAppointments = filteredAppointments.filter(apt =>
            `${apt.patient.first_name} ${apt.patient.last_name}`.toLowerCase().includes(searchFilter)
        );
    }

    tbody.innerHTML = filteredAppointments.map(apt => `
        <tr>
            <td>${formatDate(apt.appointment_date)} ${formatTime(apt.appointment_time)}</td>
            <td>${apt.patient.first_name} ${apt.patient.last_name}</td>
            <td>${apt.patient.phone_number || 'N/A'}</td>
            <td>${apt.reason}</td>
            <td>${getStatusBadge(apt.status)}</td>
            <td>
                <div class="action-buttons">
                    <button class="btn btn-sm btn-primary" onclick="viewAppointment(${apt.id})">View Details</button>
                    ${apt.status === 'scheduled' ? `
                        <button class="btn btn-sm btn-secondary" onclick="completeAppointment(${apt.id})">Complete</button>
                        <button class="btn btn-sm btn-danger" onclick="cancelAppointment(${apt.id})">Cancel</button>
                    ` : ''}
                </div>
            </td>
        </tr>
    `).join('');
}

async function completeAppointment(id) {
    // Ask for confirmation before proceeding
    if (!confirm('Please complete the medical record for this appointment. Do you want to proceed?')) {
        return;
    }

    const appointment = appointments.find(a => a.id === id);
    if (!appointment) return;

    // Set high-level state so we know which appointment to complete after saving record
    activeAppointmentId = id;

    // Ensure patients array is populated from appointments if needed
    if (patients.length === 0) {
        patients = appointments
            .map(apt => apt.patient)
            .filter((patient, index, self) =>
                index === self.findIndex(p => p.id === patient.id)
            );
    }

    // Populate patient dropdown with only the appointment's patient and disable it
    const patientSelect = document.getElementById('record-patient');
    if (patientSelect) {
        // Only show the appointment's patient and make it disabled
        patientSelect.innerHTML = `<option value="${appointment.patient.id}">${appointment.patient.first_name} ${appointment.patient.last_name}</option>`;
        patientSelect.value = appointment.patient.id;
        patientSelect.disabled = true;
    }

    // Set a helper text to show we're completing an appointment
    const modalTitle = document.querySelector('#create-record-modal h3');
    if (modalTitle) {
        modalTitle.textContent = `Complete Appointment - Create Medical Record`;
    }

    // Open the modal
    document.getElementById('create-record-modal').classList.add('active');
}

async function cancelAppointment(id) {
    if (!confirm('Cancel this appointment?')) return;

    try {
        const response = await fetch(`${API_BASE}/appointments/${id}/`, {
            method: 'PATCH',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ status: 'cancelled' })
        });

        if (response.ok) {
            showNotification('Appointment cancelled', 'success');
            await loadAllAppointments();
            updateDashboardStats();
        }
    } catch (error) {
        console.error('Error cancelling appointment:', error);
        showNotification('Error cancelling appointment', 'error');
    }
}

function viewAppointment(id) {
    const appointment = appointments.find(apt => apt.id === id);
    if (!appointment) return;

    const modal = document.getElementById('appointment-modal');
    const details = document.getElementById('appointment-details');

    details.innerHTML = `
        <div>
            <h4>Patient Information</h4>
            <p><strong>Name:</strong> ${appointment.patient ? `${appointment.patient.first_name} ${appointment.patient.last_name}` : 'Unknown'}</p>
            <p><strong>Email:</strong> ${appointment.patient ? appointment.patient.email : 'N/A'}</p>
            <p><strong>Phone:</strong> ${appointment.patient && appointment.patient.phone_number ? appointment.patient.phone_number : 'N/A'}</p>
        </div>
        <hr>
        <div>
            <h4>Appointment Details</h4>
            <p><strong>Date:</strong> ${formatDate(appointment.appointment_date)}</p>
            <p><strong>Time:</strong> ${formatTime(appointment.appointment_time)}</p>
            <p><strong>Reason:</strong> ${appointment.reason}</p>
            <p><strong>Status:</strong> ${getStatusBadge(appointment.status)}</p>
            ${appointment.notes ? `<p><strong>Notes:</strong> ${appointment.notes}</p>` : ''}
            ${appointment.medical_record_id ?
            `<div style="margin-top: 1rem; padding-top: 1rem; border-top: 1px solid var(--border-color);">
                    <button class="btn btn-success" onclick="printPrescription(${appointment.medical_record_id})">
                        📄 Download Prescription PDF
                    </button>
                </div>`
            : ''}
        </div>
    `;

    modal.classList.add('active');
}

// Patients
async function loadPatients() {
    try {
        // Get unique patients from appointments
        const uniquePatientIds = [...new Set(appointments.map(apt => apt.patient.id))];
        patients = appointments
            .map(apt => apt.patient)
            .filter((patient, index, self) =>
                index === self.findIndex(p => p.id === patient.id)
            );

        displayPatients();
    } catch (error) {
        console.error('Error loading patients:', error);
    }
}

function displayPatients() {
    const container = document.getElementById('patients-list');

    if (patients.length === 0) {
        container.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">👥</div>
                <p>No patients found</p>
            </div>
        `;
        return;
    }

    let filteredPatients = [...patients];
    const searchFilter = document.getElementById('patient-search')?.value.toLowerCase();

    if (searchFilter) {
        filteredPatients = filteredPatients.filter(patient =>
            `${patient.first_name} ${patient.last_name}`.toLowerCase().includes(searchFilter) ||
            patient.email.toLowerCase().includes(searchFilter) ||
            (patient.phone_number && patient.phone_number.includes(searchFilter))
        );
    }

    container.innerHTML = filteredPatients.map(patient => {
        const patientAppointments = appointments.filter(apt => apt.patient.id === patient.id);
        return `
            <div class="patient-card">
                <div class="flex justify-between items-center">
                    <div>
                        <h4>${patient.first_name} ${patient.last_name}</h4>
                        <p style="color: var(--text-muted); font-size: 0.875rem;">
                            📧 ${patient.email} | 📞 ${patient.phone_number || 'N/A'}
                        </p>
                    </div>
                    <div>
                        <span class="badge badge-info">${patientAppointments.length} appointments</span>
                        <button class="btn btn-sm btn-primary" onclick="viewPatientHistory(${patient.id})">View History</button>
                    </div>
                </div>
            </div>
        `;
    }).join('');
}

async function viewPatientHistory(patientId) {
    try {
        const response = await fetch(`${API_BASE}/medical-records/patient_history/?patient_id=${patientId}`, {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
            }
        });

        if (response.ok) {
            const history = await response.json();
            displayPatientHistoryModal(history, patientId);
        } else {
            const errorText = await response.text();
            console.error('Patient history error:', response.status, errorText);
            showNotification(`Error loading patient history: ${response.status}`, 'error');
        }
    } catch (error) {
        console.error('Error loading patient history:', error);
        showNotification('Error loading patient history: ' + error.message, 'error');
    }
}

function displayPatientHistoryModal(history, patientId) {
    const patient = patients.find(p => p.id === patientId);
    const modal = document.getElementById('patient-history-modal');
    const content = document.getElementById('patient-history-content');

    if (!modal || !content) return;

    const patientName = patient ? `${patient.first_name} ${patient.last_name}` : 'Patient';
    document.getElementById('patient-history-name').textContent = patientName;

    if (history.length === 0) {
        content.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">📋</div>
                <p>No medical history found</p>
            </div>
        `;
    } else {
        content.innerHTML = history.map(record => `
            <div class="history-record">
                <div class="history-header">
                    <h4>${formatDate(record.created_at)}</h4>
                    ${record.doctor_name ?
                `<span class="badge badge-info">Dr. ${record.doctor_name}</span>` :
                '<span class="badge badge-secondary">Doctor info unavailable</span>'}
                </div>
                <div class="history-body">
                    <p><strong>Diagnosis:</strong> ${record.diagnosis}</p>
                    <p><strong>Symptoms:</strong> ${record.symptoms}</p>
                    <p><strong>Treatment:</strong> ${record.treatment_plan}</p>
                    ${record.prescriptions && record.prescriptions.length > 0 ? `
                        <div class="prescriptions-section">
                            <h5>Prescriptions:</h5>
                            ${record.prescriptions.map(rx => `
                                <div class="prescription-item">
                                    <strong>${rx.medication_name}</strong> - ${rx.dosage}<br>
                                    <small>${rx.frequency} for ${rx.duration}</small>
                                    ${rx.instructions ? `<br><small>Instructions: ${rx.instructions}</small>` : ''}
                                </div>
                            `).join('')}
                        </div>
                    ` : ''}
                    ${record.notes ? `<p><strong>Notes:</strong> ${record.notes}</p>` : ''}
                </div>
                <button class="btn btn-sm btn-secondary" onclick="printPrescription(${record.id})">Print Prescription</button>
            </div>
        `).join('');
    }

    modal.classList.add('active');
}

// Medical Records
async function loadMedicalRecords() {
    try {
        const response = await fetch(`${API_BASE}/medical-records/`, {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
            }
        });

        if (response.ok) {
            const data = await response.json();
            records = data.results || data;
            displayMedicalRecords();
        }
    } catch (error) {
        console.error('Error loading medical records:', error);
        showNotification('Error loading medical records', 'error');
    }
}

function displayMedicalRecords() {
    const container = document.getElementById('records-list');

    if (records.length === 0) {
        container.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">📋</div>
                <p>No medical records found</p>
            </div>
        `;
        return;
    }

    container.innerHTML = records.map(record => `
        <div class="card mb-2">
            <div class="flex justify-between items-center">
                <div>
                    <h4>${record.patient ? `${record.patient.first_name} ${record.patient.last_name}` : 'Unknown Patient'}</h4>
                    <p style="color: var(--text-muted);">${formatDate(record.created_at)}</p>
                    <p><strong>Diagnosis:</strong> ${record.diagnosis}</p>
                </div>
                <button class="btn btn-sm btn-success" onclick="printPrescription(${record.id})">
                    📄 Download Prescription PDF
                </button>
            </div>
        </div>
    `).join('');
}

function openCreateRecordModal() {
    // Reset state in case we were in a completion flow
    activeAppointmentId = null;
    const modalTitle = document.querySelector('#create-record-modal h3');
    if (modalTitle) {
        modalTitle.textContent = 'Create Medical Record';
    }

    // Populate patient dropdown and enable it
    const patientSelect = document.getElementById('record-patient');
    patientSelect.innerHTML = '<option value="">Select Patient</option>' +
        patients.map(p => `<option value="${p.id}">${p.first_name} ${p.last_name}</option>`).join('');
    patientSelect.disabled = false; // Re-enable the dropdown

    document.getElementById('create-record-modal').classList.add('active');
}



// Unavailability
async function loadUnavailability() {
    try {
        const response = await fetch(`${API_BASE}/unavailability/`, {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
            }
        });

        if (response.ok) {
            const data = await response.json();
            unavailabilityPeriods = data.results || data;
            displayUnavailability();
        }
    } catch (error) {
        console.error('Error loading unavailability:', error);
        showNotification('Error loading unavailability periods', 'error');
    }
}

function displayUnavailability() {
    const container = document.getElementById('unavailability-list');

    if (unavailabilityPeriods.length === 0) {
        container.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">⏰</div>
                <p>No unavailability periods set</p>
            </div>
        `;
        return;
    }

    container.innerHTML = unavailabilityPeriods.map(period => `
        <div class="unavailability-item">
            <div class="flex justify-between items-center">
                <div>
                    <h4>${period.reason}</h4>
                    <p>${formatDate(period.start_date)} to ${formatDate(period.end_date)}</p>
                    ${period.start_time ? `<p class="text-xs text-muted">Time: ${formatTime(period.start_time)} - ${formatTime(period.end_time)}</p>` : ''}
                    ${period.is_recurring ? `<p class="text-xs text-info">Recurring: ${period.recurrence_pattern}</p>` : ''}
                </div>
                <button class="btn btn-sm btn-danger" onclick="deleteUnavailability(${period.id})">Delete</button>
            </div>
        </div>
    `).join('');
}

function openUnavailabilityModal() {
    document.getElementById('unavailability-modal').classList.add('active');
}

async function deleteUnavailability(id) {
    if (!confirm('Delete this unavailability period?')) return;

    try {
        const response = await fetch(`${API_BASE}/unavailability/${id}/`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
            }
        });

        if (response.ok) {
            showNotification('Unavailability period deleted', 'success');
            await loadUnavailability();
        }
    } catch (error) {
        console.error('Error deleting unavailability:', error);
        showNotification('Error deleting unavailability period', 'error');
    }
}

// Event Listeners
function setupEventListeners() {
    // Appointment filters
    const appointmentStatusFilter = document.getElementById('appointment-status-filter');
    const appointmentDateFilter = document.getElementById('appointment-date-filter');
    const appointmentSearch = document.getElementById('appointment-search');

    if (appointmentStatusFilter) appointmentStatusFilter.addEventListener('change', displayAppointments);
    if (appointmentDateFilter) appointmentDateFilter.addEventListener('change', displayAppointments);
    if (appointmentSearch) appointmentSearch.addEventListener('input', displayAppointments);

    // Patient search
    const patientSearch = document.getElementById('patient-search');
    if (patientSearch) patientSearch.addEventListener('input', displayPatients);

    // Forms
    const createRecordForm = document.getElementById('create-record-form');
    if (createRecordForm) {
        createRecordForm.addEventListener('submit', async function (e) {
            e.preventDefault();
            await createMedicalRecord();
        });
    }

    const unavailabilityForm = document.getElementById('unavailability-form');
    if (unavailabilityForm) {
        unavailabilityForm.addEventListener('submit', async function (e) {
            e.preventDefault();
            await createUnavailability();
        });
    }
}

async function createMedicalRecord() {
    const data = {
        patient_id: document.getElementById('record-patient').value,
        symptoms: document.getElementById('record-symptoms').value,
        diagnosis: document.getElementById('record-diagnosis').value,
        treatment_plan: document.getElementById('record-treatment').value,
        notes: document.getElementById('record-notes').value,
        appointment: activeAppointmentId,
        prescriptions: getPrescriptions()
    };

    try {
        const response = await fetch(`${API_BASE}/medical-records/`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });

        if (response.ok) {
            // If this was part of an appointment completion, call the completion API
            if (activeAppointmentId) {
                await fetch(`${API_BASE}/appointments/${activeAppointmentId}/complete/`, {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
                        'Content-Type': 'application/json',
                    }
                });
                showNotification('Appointment completed and medical record saved', 'success');
            } else {
                showNotification('Medical record created successfully', 'success');
            }

            closeModal('create-record-modal');
            document.getElementById('create-record-form').reset();

            // Reset state
            activeAppointmentId = null;
            const modalTitle = document.querySelector('#create-record-modal h3');
            if (modalTitle) {
                modalTitle.textContent = 'Create Medical Record';
            }

            await loadMedicalRecords();
            await loadAllAppointments();
            updateDashboardStats();
        }
    } catch (error) {
        console.error('Error creating medical record:', error);
        showNotification('Error creating medical record', 'error');
    }
}

async function createUnavailability() {
    const data = {
        start_date: document.getElementById('unavail-start').value,
        end_date: document.getElementById('unavail-end').value,
        reason: document.getElementById('unavail-reason').value,
    };

    try {
        const response = await fetch(`${API_BASE}/unavailability/`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });

        if (response.ok) {
            showNotification('Unavailability period added', 'success');
            closeModal('unavailability-modal');
            document.getElementById('unavailability-form').reset();
            await loadUnavailability();
        }
    } catch (error) {
        console.error('Error creating unavailability:', error);
        showNotification('Error adding unavailability period', 'error');
    }
}

// Utility Functions
function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}

function showNotification(message, type = 'success') {
    const notification = document.getElementById('notification');
    notification.textContent = message;
    notification.className = `notification ${type} show`;

    setTimeout(() => {
        notification.classList.remove('show');
    }, 3000);
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

function formatTime(timeString) {
    const [hours, minutes] = timeString.split(':');
    const hour = parseInt(hours);
    const ampm = hour >= 12 ? 'PM' : 'AM';
    const displayHour = hour % 12 || 12;
    return `${displayHour}:${minutes} ${ampm}`;
}

function getStatusBadge(status) {
    const badges = {
        'scheduled': '<span class="badge badge-info">Scheduled</span>',
        'completed': '<span class="badge badge-success">Completed</span>',
        'cancelled': '<span class="badge badge-danger">Cancelled</span>',
        'no_show': '<span class="badge badge-warning">No Show</span>',
    };
    return badges[status] || status;
}

function getCurrentUserId() {
    return typeof CURRENT_USER_ID !== 'undefined' ? CURRENT_USER_ID : 0;
}

// Prescription Management Functions
function addMedicineRow() {
    const template = document.getElementById('medicine-row-template');
    const container = document.getElementById('prescriptions-container');
    const clone = template.content.cloneNode(true);

    // Add event listener for frequency change
    const frequencySelect = clone.querySelector('.medicine-frequency');
    frequencySelect.onchange = function () {
        updateTimingOptions(this);
    };

    container.appendChild(clone);
}

function updateTimingOptions(select) {
    const row = select.closest('.medicine-row');
    const timingsContainer = row.querySelector('.medicine-timings-container');
    const frequency = select.value;

    let count = 1;
    if (frequency === 'Twice daily') count = 2;
    else if (frequency === 'Thrice daily') count = 3;
    else if (frequency === 'Four times daily') count = 4;

    const timingOptions = `
        <option value="">Select timing</option>
        <option value="Before breakfast">Before breakfast</option>
        <option value="After breakfast">After breakfast</option>
        <option value="Before lunch">Before lunch</option>
        <option value="After lunch">After lunch</option>
        <option value="Before dinner">Before dinner</option>
        <option value="After dinner">After dinner</option>
        <option value="At bedtime">At bedtime</option>
        <option value="Empty stomach">Empty stomach</option>
        <option value="With food">With food</option>
    `;

    // specific container style
    timingsContainer.style.display = 'flex';
    timingsContainer.style.flexDirection = 'column';
    timingsContainer.style.gap = '0.5rem';

    // Store existing values
    const existingSelects = timingsContainer.querySelectorAll('select');
    const existingValues = Array.from(existingSelects).map(s => s.value);

    timingsContainer.innerHTML = '';

    for (let i = 0; i < count; i++) {
        const newSelect = document.createElement('select');
        newSelect.className = 'form-select medicine-timing';
        newSelect.innerHTML = timingOptions;
        if (existingValues[i]) {
            newSelect.value = existingValues[i];
        } else if (i === 0 && existingValues.length > 0) {
            newSelect.value = existingValues[0]; // Keep first value if decreasing count
        }
        timingsContainer.appendChild(newSelect);
    }
}

function removeMedicineRow(button) {
    button.closest('.medicine-row').remove();
}

function getPrescriptions() {
    const prescriptions = [];
    const medicineRows = document.querySelectorAll('.medicine-row');

    medicineRows.forEach(row => {
        const name = row.querySelector('.medicine-name').value.trim();
        const dosage = row.querySelector('.medicine-dosage').value.trim();
        const frequency = row.querySelector('.medicine-frequency').value;

        // Get all timing values
        const timingSelects = row.querySelectorAll('.medicine-timing');
        const timingValues = Array.from(timingSelects)
            .map(s => s.value)
            .filter(v => v);
        const timing = timingValues.join(', ');

        const durationValue = row.querySelector('.medicine-duration-value').value;
        const durationUnit = row.querySelector('.medicine-duration-unit').value;
        const instructions = row.querySelector('.medicine-instructions').value.trim();

        // Only add if medicine name is provided
        if (name) {
            const duration = durationValue ? `${durationValue} ${durationUnit}` : '';
            const fullInstructions = timing ? `${timing}. ${instructions}`.trim() : instructions;

            prescriptions.push({
                medication_name: name,
                dosage: dosage || 'As directed',
                frequency: frequency || 'As directed',
                duration: duration || 'As directed',
                instructions: fullInstructions
            });
        }
    });

    return prescriptions;
}

async function printPrescription(recordId) {
    try {
        showNotification('Generating PDF...', 'info');
        const response = await fetch(`${API_BASE}/medical-records/${recordId}/prescription_pdf/`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
            }
        });

        if (response.ok) {
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            window.open(url, '_blank');
            // Clean up the URL object after a delay
            setTimeout(() => window.URL.revokeObjectURL(url), 10000);
        } else {
            console.error('PDF generation failed:', response.status);
            showNotification('Error generating prescription PDF', 'error');
        }
    } catch (error) {
        console.error('Error printing prescription:', error);
        showNotification('Error printing prescription', 'error');
    }
}

// Logout function
async function logout() {
    if (confirm('Are you sure you want to logout?')) {
        localStorage.removeItem('authToken');
        try {
            // Attempt server-side logout but don't block
            await fetch('/logout/', { method: 'GET' });
        } catch (e) {
            console.error('Server logout failed', e);
        }
        window.location.href = '/login/';
    }
}

// Add Unavailability Logic
document.addEventListener('DOMContentLoaded', () => {
    const unavailForm = document.getElementById('unavailability-form');
    if (unavailForm) {
        unavailForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await addUnavailability();
        });
    }

    // Auto-set recurrence and end date logic
    const reasonInput = document.getElementById('unavail-reason');
    const recurrenceSelect = document.getElementById('unavail-recurrence');
    const endDateInput = document.getElementById('unavail-end');
    const startDateInput = document.getElementById('unavail-start');

    if (reasonInput) {
        reasonInput.addEventListener('input', (e) => {
            if (e.target.value.toLowerCase().includes('lunch')) {
                recurrenceSelect.value = 'daily';
                updateEndDate();
            }
        });
    }

    if (recurrenceSelect) {
        recurrenceSelect.addEventListener('change', updateEndDate);
    }

    if (startDateInput) {
        startDateInput.addEventListener('change', updateEndDate);
    }

    function updateEndDate() {
        if (recurrenceSelect.value !== 'none') {
            const start = startDateInput.value ? new Date(startDateInput.value) : new Date();
            const future = new Date(start);
            future.setFullYear(future.getFullYear() + 5); // 5 years from start
            endDateInput.value = future.toISOString().split('T')[0];
        }
    }
});

async function addUnavailability() {
    const start_date = document.getElementById('unavail-start').value;
    const end_date = document.getElementById('unavail-end').value;
    const reason = document.getElementById('unavail-reason').value;
    const start_time = document.getElementById('unavail-start-time').value || null;
    const end_time = document.getElementById('unavail-end-time').value || null;
    const recurrence = document.getElementById('unavail-recurrence').value;

    const data = {
        start_date,
        end_date,
        reason,
        start_time,
        end_time,
        is_recurring: recurrence !== 'none',
        recurrence_pattern: recurrence
    };

    try {
        const response = await fetch(`${API_BASE}/unavailability/`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });

        if (response.ok) {
            showNotification('Unavailability period added', 'success');
            document.getElementById('unavailability-modal').classList.remove('active');
            document.getElementById('unavailability-form').reset();
            await loadUnavailability();
        } else {
            const errorText = await response.text();
            console.error('Error adding unavailability:', errorText);
            showNotification('Error adding unavailability', 'error');
        }
    } catch (error) {
        console.error('Error adding unavailability:', error);
        showNotification('Error adding unavailability', 'error');
    }
}
