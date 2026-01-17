// Agricultural Officer Dashboard Logic - Rewritten
// API_BASE is defined in main.js

console.log("Agri Officer Script Loaded");

// Global State
let currentQueryId = null;

document.addEventListener('DOMContentLoaded', () => {
    console.log("DOM Loaded - Initializing Dashboard");
    checkOfficerAuth();
    loadDashboardStats();
    loadRecentQueries();

    // Attach form listeners manually just in case
    const updateForm = document.getElementById('post-update-form');
    if (updateForm) {
        updateForm.addEventListener('submit', handlePostUpdate);
    }

    // respond-form listener is handled via onsubmit in HTML for robustness
});

function checkOfficerAuth() {
    const token = localStorage.getItem('authToken');
    const role = localStorage.getItem('userRole');

    if (!token || role !== 'agri_officer') {
        window.location.href = '/login/';
    }
}

async function loadDashboardStats() {
    try {
        const stats = await apiCall('/agriculture/stats/');
        document.getElementById('stat-pending').textContent = stats.pending_queries || 0;
        document.getElementById('stat-advisories').textContent = stats.advisories_given || 0;
        document.getElementById('stat-updates').textContent = stats.updates_posted || 0;
    } catch (error) {
        console.error('Failed to load stats:', error);
    }
}

async function loadRecentQueries() {
    console.log("Loading queries...");
    try {
        const response = await apiCall('/agriculture/queries/');
        const container = document.getElementById('queries-table-body');
        const queries = response.results || response || [];

        console.log("Queries loaded:", queries.length);

        if (queries.length === 0) {
            container.innerHTML = '<tr><td colspan="5" class="text-center">No queries found.</td></tr>';
            return;
        }

        container.innerHTML = queries.map(q => {
            // Debug each row ID
            if (!q.id) console.error("Query missing ID:", q);
            return `
            <tr>
                <td>${q.query_id}</td>
                <td>${q.farmer_name || 'Farmer'}</td>
                <td>
                    <strong>${q.title}</strong><br>
                    <small>${q.crop_category_name || 'General'}</small>
                </td>
                <td><span class="badge badge-${getStatusColor(q.status)}">${q.status}</span></td>
                <td>
                    <button class="btn btn-sm btn-primary" onclick="window.viewQuery(${q.id})">View</button>
                    <button class="btn btn-sm btn-secondary" onclick="window.openRespondModal(${q.id}, '${q.query_id}')">Respond</button>
                </td>
            </tr>
            `;
        }).join('');
    } catch (error) {
        console.error('Failed to load queries:', error);
        document.getElementById('queries-table-body').innerHTML = '<tr><td colspan="5" class="text-error">Failed to load data</td></tr>';
    }
}

// Global Functions attached to window explicitly
window.viewQuery = function (id) {
    console.log("View Query Clicked:", id);
    if (!id) {
        alert("Error: Query ID is missing");
        return;
    }

    document.getElementById('view-query-content').innerHTML = '<div class="spinner"></div>';
    document.getElementById('view-modal').classList.add('active');

    apiCall(`/agriculture/queries/${id}/`).then(q => {
        document.getElementById('view-query-content').innerHTML = `
            <p><strong>ID:</strong> ${q.query_id}</p>
            <p><strong>Farmer:</strong> ${q.farmer_name}</p>
            <p><strong>Crop:</strong> ${q.crop_category_name || 'General'}</p>
            <p><strong>Subject:</strong> ${q.title}</p>
            <hr>
            <p><strong>Message:</strong><br>${q.description || q.content || 'No description provided'}</p>
            ${q.image ? `<img src="${q.image}" style="max-width: 100%; margin-top: 10px; border-radius: 4px;">` : ''}
            ${q.status === 'answered' ? `<p class="mt-2 text-success"><strong>Responded</strong></p>` : ''}
        `;
        document.getElementById('view-respond-btn').onclick = () => {
            closeViewModal();
            window.openRespondModal(id, q.query_id);
        };
    }).catch(e => {
        document.getElementById('view-query-content').innerHTML = '<p class="text-error text-center">Failed to load details.</p>';
        console.error(e);
    });
};

window.openRespondModal = function (id, queryRef) {
    console.log('Opening respond modal', id, queryRef);
    if (!id) {
        alert("Error: Invalid Query ID");
        return;
    }
    currentQueryId = id;
    document.getElementById('respond-modal-title').textContent = `Respond to Ref: ${queryRef}`;
    document.getElementById('respond-modal').classList.add('active');
};

window.closeRespondModal = function () {
    document.getElementById('respond-modal').classList.remove('active');
    currentQueryId = null;
    document.getElementById('respond-form').reset();
};

window.closeViewModal = function () {
    document.getElementById('view-modal').classList.remove('active');
};

window.handleRespond = async function (e) {
    e.preventDefault();
    console.log('Handling respond submit. ID:', currentQueryId);

    if (!currentQueryId) {
        showNotification('Error: No query selected', 'error');
        return;
    }

    const advice = document.getElementById('advisory-text').value;
    if (!advice) {
        showNotification('Please enter advice', 'warning');
        return;
    }

    try {
        showNotification('Sending response...', 'info');
        await apiCall(`/agriculture/queries/${currentQueryId}/respond/`, 'POST', { advice }, true);
        showNotification('Response sent successfully', 'success');
        window.closeRespondModal();
        loadRecentQueries();
        loadDashboardStats();
    } catch (error) {
        console.error("Respond Error:", error);
        showNotification('Failed to send response: ' + error.message, 'error');
    }
};

window.handlePostUpdate = async function (e) {
    e.preventDefault();
    const form = e.target;
    const formData = new FormData(form);

    const data = {
        update_type: formData.get('update_type'),
        title: formData.get('title'),
        content: formData.get('content'),
        district: formData.get('district') || ''
    };

    try {
        await apiCall('/agriculture/updates/', 'POST', data, true);
        showNotification('Update posted successfully', 'success');
        form.reset();
        loadDashboardStats();
        loadUpdates();
    } catch (error) {
        showNotification('Failed to post update: ' + error.message, 'error');
    }
};

window.showSection = function (sectionName) {
    document.querySelectorAll('.section-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.sidebar-link').forEach(el => el.classList.remove('active'));
    document.getElementById(`${sectionName}-section`).classList.add('active');

    const link = document.querySelector(`a[href="#${sectionName}"]`);
    if (link) link.classList.add('active');

    if (sectionName === 'advisories') loadAdvisories();
    if (sectionName === 'updates') loadUpdates();
};

// Also expose load functions just in case
window.loadAdvisories = async function () {
    try {
        const response = await apiCall('/agriculture/advisories/');
        const container = document.getElementById('advisories-table-body');
        const advisories = response.results || response || [];

        if (advisories.length === 0) {
            container.innerHTML = '<tr><td colspan="4" class="text-center">No advisories given yet.</td></tr>';
            return;
        }

        container.innerHTML = advisories.map(adv => `
            <tr>
                <td>${adv.query_ref || 'Ref#'}</td>
                <td>${adv.advice.substring(0, 50)}...</td>
                <td>${new Date(adv.created_at).toLocaleDateString()}</td>
                <td><span class="badge badge-success">Validated</span></td>
            </tr>
        `).join('');
    } catch (e) {
        console.error(e);
    }
};

window.loadUpdates = async function () {
    try {
        const response = await apiCall('/agriculture/updates/');
        const container = document.getElementById('my-updates-list');
        const updates = response.results || response || [];

        if (updates.length === 0) {
            container.innerHTML = '<p class="text-center">No updates posted yet.</p>';
            return;
        }

        container.innerHTML = updates.map(upt => `
            <div class="request-card">
                 <h4>${upt.title} <small class="badge badge-info">${upt.update_type}</small></h4>
                 <p>${upt.content}</p>
                 <small>Posted on ${new Date(upt.created_at).toLocaleDateString()}</small>
            </div>
        `).join('');
    } catch (e) {
        console.error(e);
    }
};

window.getStatusColor = function (status) {
    switch (status) {
        case 'submitted': return 'warning';
        case 'answered': return 'success';
        case 'closed': return 'secondary';
        default: return 'info';
    }
};

// Logout
window.logout = function () {
    if (confirm('Logout?')) {
        localStorage.removeItem('authToken');
        localStorage.removeItem('userRole'); // Clear role too
        window.location.href = '/login/';
    }
};
