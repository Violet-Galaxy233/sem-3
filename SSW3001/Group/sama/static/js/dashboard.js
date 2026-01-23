// SamaRasa Family Dashboard JavaScript

const API_BASE = 'http://localhost:5001/api';
const USER_ID = 1; // Default user for prototype

// Initialize dashboard
document.addEventListener('DOMContentLoaded', () => {
    loadDashboard();
});

async function loadDashboard() {
    try {
        const response = await fetch(`${API_BASE}/dashboard/${USER_ID}`);
        const data = await response.json();

        if (data.success) {
            displayDashboard(data.dashboard);
        }
    } catch (error) {
        console.error('Error loading dashboard:', error);
        showError('Failed to load dashboard data');
    }
}

function displayDashboard(dashboard) {
    // User info
    document.getElementById('elderlyName').textContent =
        `Monitoring: ${dashboard.user.name} (${dashboard.user.age} years old)`;

    // Statistics
    document.getElementById('statMedications').textContent = dashboard.statistics.total_medications;
    document.getElementById('statDiary').textContent = dashboard.statistics.diary_entries_this_week;

    // Fall risk
    if (dashboard.fall_assessment) {
        const riskLevel = dashboard.fall_assessment.risk_level;
        const statFallRisk = document.getElementById('statFallRisk');
        statFallRisk.textContent = riskLevel;

        // Color code based on risk
        statFallRisk.style.color =
            riskLevel === 'Low' ? '#10b981' :
            riskLevel === 'Medium' ? '#f59e0b' : '#ef4444';
    }

    // Active alerts
    if (dashboard.active_alerts.length > 0) {
        displayAlerts(dashboard.active_alerts);
    }

    // Medications
    displayMedications(dashboard.medications);

    // Health diary
    displayHealthDiary(dashboard.diary_entries);

    // Fall risk assessment
    displayFallRisk(dashboard.fall_assessment);

    // Recent chats
    displayRecentChats(dashboard.recent_chats);

    // Caregivers
    displayCaregivers(dashboard.caregivers);
}

function displayAlerts(alerts) {
    const alertsSection = document.getElementById('alertsSection');
    const alertsList = document.getElementById('alertsList');

    alertsSection.classList.remove('hidden');
    alertsList.innerHTML = '';

    alerts.forEach(alert => {
        const alertDiv = document.createElement('div');
        alertDiv.className = 'alert alert-danger';
        alertDiv.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <strong>🆘 ${alert.alert_type} Alert</strong>
                    <p>Triggered at: ${new Date(alert.created_at).toLocaleString()}</p>
                </div>
                <button class="btn btn-success" onclick="resolveAlert(${alert.id})">
                    Resolve
                </button>
            </div>
        `;
        alertsList.appendChild(alertDiv);
    });
}

async function resolveAlert(alertId) {
    try {
        const response = await fetch(`${API_BASE}/emergency/alert/${alertId}/resolve`, {
            method: 'POST'
        });

        const data = await response.json();

        if (data.success) {
            showSuccess('Alert resolved successfully');
            refreshDashboard();
        }
    } catch (error) {
        console.error('Error resolving alert:', error);
        showError('Failed to resolve alert');
    }
}

function displayMedications(medications) {
    const medDiv = document.getElementById('dashboardMedications');
    medDiv.innerHTML = '';

    if (medications.length === 0) {
        medDiv.innerHTML = '<p>No active medications</p>';
        return;
    }

    medications.forEach(med => {
        const item = document.createElement('div');
        item.className = 'medication-item';
        item.innerHTML = `
            <div class="medication-info">
                <div class="medication-name">${med.medication_name}</div>
                <div class="medication-details">
                    ${med.dosage} at ${med.time} - ${med.frequency}
                </div>
            </div>
        `;
        medDiv.appendChild(item);
    });
}

function displayHealthDiary(entries) {
    const diaryDiv = document.getElementById('dashboardDiary');
    diaryDiv.innerHTML = '';

    if (entries.length === 0) {
        diaryDiv.innerHTML = '<p>No diary entries this week</p>';
        return;
    }

    // Create summary table
    const table = document.createElement('table');
    table.style.width = '100%';
    table.style.borderCollapse = 'collapse';

    table.innerHTML = `
        <thead>
            <tr style="background: #f1f5f9;">
                <th style="padding: 12px; text-align: left; border-bottom: 2px solid #e2e8f0;">Date</th>
                <th style="padding: 12px; text-align: left; border-bottom: 2px solid #e2e8f0;">Mood</th>
                <th style="padding: 12px; text-align: center; border-bottom: 2px solid #e2e8f0;">Sleep</th>
                <th style="padding: 12px; text-align: center; border-bottom: 2px solid #e2e8f0;">Exercise</th>
            </tr>
        </thead>
        <tbody>
            ${entries.map(entry => `
                <tr>
                    <td style="padding: 10px; border-bottom: 1px solid #e2e8f0;">
                        ${new Date(entry.date).toLocaleDateString()}
                    </td>
                    <td style="padding: 10px; border-bottom: 1px solid #e2e8f0;">
                        ${getMoodEmoji(entry.mood)} ${entry.mood || '-'}
                    </td>
                    <td style="padding: 10px; text-align: center; border-bottom: 1px solid #e2e8f0;">
                        ${entry.sleep_hours || 0}h
                    </td>
                    <td style="padding: 10px; text-align: center; border-bottom: 1px solid #e2e8f0;">
                        ${entry.exercise_minutes || 0}m
                    </td>
                </tr>
            `).join('')}
        </tbody>
    `;

    diaryDiv.appendChild(table);
}

function getMoodEmoji(mood) {
    const moods = {
        'happy': '😊',
        'neutral': '😐',
        'sad': '😢',
        'tired': '😴'
    };
    return moods[mood] || '😐';
}

function displayFallRisk(assessment) {
    const fallDiv = document.getElementById('dashboardFallRisk');

    if (!assessment) {
        fallDiv.innerHTML = '<p>No fall risk assessment completed yet</p>';
        return;
    }

    const riskColor =
        assessment.risk_level === 'Low' ? 'success' :
        assessment.risk_level === 'Medium' ? 'warning' : 'danger';

    fallDiv.innerHTML = `
        <div class="alert alert-${riskColor}" style="margin: 0;">
            <h3 style="margin-bottom: 8px;">Risk Level: ${assessment.risk_level}</h3>
            <p style="margin-bottom: 8px;">Score: ${assessment.score}/10</p>
            <p style="font-size: 16px; color: #64748b;">
                Assessed on: ${new Date(assessment.assessment_date).toLocaleDateString()}
            </p>
        </div>
    `;
}

function displayRecentChats(chats) {
    const chatsDiv = document.getElementById('dashboardChats');

    if (chats.length === 0) {
        chatsDiv.innerHTML = '<p>No recent conversations</p>';
        return;
    }

    chatsDiv.innerHTML = '';

    chats.forEach(chat => {
        const chatItem = document.createElement('div');
        chatItem.style.marginBottom = '16px';
        chatItem.style.padding = '12px';
        chatItem.style.background = '#f8fafc';
        chatItem.style.borderRadius = '8px';
        chatItem.style.borderLeft = '4px solid #2563eb';

        chatItem.innerHTML = `
            <p style="margin-bottom: 8px; color: #475569;">
                <strong>User:</strong> ${chat.message}
            </p>
            <p style="margin-bottom: 4px; color: #10b981;">
                <strong>SamaRasa:</strong> ${chat.response}
            </p>
            <p style="font-size: 14px; color: #94a3b8; margin-top: 8px;">
                ${new Date(chat.created_at).toLocaleString()}
            </p>
        `;

        chatsDiv.appendChild(chatItem);
    });
}

function displayCaregivers(caregivers) {
    const caregiversDiv = document.getElementById('caregiversList');

    if (caregivers.length === 0) {
        caregiversDiv.innerHTML = '<p>No caregivers registered</p>';
        return;
    }

    caregiversDiv.innerHTML = '';

    caregivers.forEach(caregiver => {
        const item = document.createElement('div');
        item.style.display = 'flex';
        item.style.justifyContent = 'space-between';
        item.style.alignItems = 'center';
        item.style.padding = '16px';
        item.style.background = '#f8fafc';
        item.style.borderRadius = '12px';
        item.style.marginBottom = '12px';
        item.style.border = '2px solid #e2e8f0';

        item.innerHTML = `
            <div>
                <div style="font-size: 20px; font-weight: 600; margin-bottom: 4px;">
                    ${caregiver.name}
                </div>
                <div style="font-size: 16px; color: #64748b;">
                    📞 ${caregiver.phone || 'N/A'} |
                    📧 ${caregiver.email || 'N/A'}
                </div>
            </div>
        `;

        caregiversDiv.appendChild(item);
    });
}

function refreshDashboard() {
    loadDashboard();
}

function showSuccess(message) {
    showNotification(message, 'success');
}

function showError(message) {
    showNotification(message, 'danger');
}

function showNotification(message, type) {
    const notification = document.createElement('div');
    notification.className = `alert alert-${type}`;
    notification.textContent = message;
    notification.style.position = 'fixed';
    notification.style.top = '20px';
    notification.style.right = '20px';
    notification.style.zIndex = '9999';
    notification.style.minWidth = '300px';

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.remove();
    }, 5000);
}
