// Apolaki Solar - Main Application JavaScript
// API Configuration
const API_CONFIG = {
    BASE_URL: window.location.hostname === 'localhost' 
        ? 'http://localhost:8080'
        : '', // Use relative path for Netlify
    TIMEOUT: 30000,
    RETRY_ATTEMPTS: 3,
    RETRY_DELAY: 1000
};

// Format currency (supports multiple currencies)
function formatCurrency(value, currency = 'USD') {
    const formats = {
        'USD': { locale: 'en-US', currency: 'USD' },
        'PHP': { locale: 'en-PH', currency: 'PHP' },
        'EUR': { locale: 'de-DE', currency: 'EUR' },
        'GBP': { locale: 'en-GB', currency: 'GBP' }
    };
    const fmt = formats[currency] || formats['USD'];
    return new Intl.NumberFormat(fmt.locale, {
        style: 'currency',
        currency: fmt.currency,
        minimumFractionDigits: 2
    }).format(value);
}

// Format number with thousands separator
function formatNumber(value, decimals = 2) {
    return parseFloat(value).toLocaleString('en-US', {
        minimumFractionDigits: decimals,
        maximumFractionDigits: decimals
    });
}

// API client with retry logic
async function fetchWithRetry(endpoint, options = {}, retries = API_CONFIG.RETRY_ATTEMPTS) {
    const url = `${API_CONFIG.BASE_URL}${endpoint}`;
    
    try {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), API_CONFIG.TIMEOUT);
        
        const response = await fetch(url, {
            ...options,
            signal: controller.signal
        });
        
        clearTimeout(timeout);
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        return await response.json();
    } catch (error) {
        if (retries > 0 && (error.name === 'AbortError' || error.message.includes('Failed to fetch'))) {
            console.log(`Retry attempt ${API_CONFIG.RETRY_ATTEMPTS - retries + 1}/${API_CONFIG.RETRY_ATTEMPTS}`);
            await new Promise(r => setTimeout(r, API_CONFIG.RETRY_DELAY));
            return fetchWithRetry(endpoint, options, retries - 1);
        }
        throw error;
    }
}

// Show error message
function showError(title, message) {
    const errorDiv = document.getElementById('errorMessage') || createErrorDiv();
    errorDiv.innerHTML = `
        <div style="color: #ef4444; background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.3); padding: 16px; border-radius: 8px; margin-bottom: 16px;">
            <strong>⚠️ ${title}</strong>
            <p style="margin: 8px 0 0 0; font-size: 14px;">${message}</p>
        </div>
    `;
    errorDiv.style.display = 'block';
}

function createErrorDiv() {
    const div = document.createElement('div');
    div.id = 'errorMessage';
    const container = document.getElementById('calcBtn')?.parentElement?.parentElement;
    if (container) {
        container.insertBefore(div, container.firstChild);
    }
    return div;
}

function hideError() {
    const errorDiv = document.getElementById('errorMessage');
    if (errorDiv) errorDiv.style.display = 'none';
}

// Validate input
function validateInput(zip, kw) {
    if (!zip || zip.trim() === '') {
        showError('Validation Error', 'Please enter a valid postal code');
        return false;
    }
    
    const trimmedZip = zip.trim();
    if (trimmedZip.length < 2 || trimmedZip.length > 15) {
        showError('Validation Error', 'Postal code must be between 2 and 15 characters');
        return false;
    }
    
    if (!/^[A-Za-z0-9\s\-]{2,15}$/.test(trimmedZip)) {
        showError('Validation Error', 'Postal code contains invalid characters');
        return false;
    }
    
    const kwNum = parseInt(kw);
    if (isNaN(kwNum) || kwNum < 1 || kwNum > 100) {
        showError('Validation Error', 'System size must be between 1 and 100 kW');
        return false;
    }
    
    return true;
}

// Main calculate function
async function calculate() {
    const btn = document.getElementById('calcBtn');
    if (!btn) return;
    
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fa-solid fa-circle-notch fa-spin"></i> Processing...';
    btn.disabled = true;
    
    const zip = document.getElementById('zipcode')?.value || '';
    const kw = document.getElementById('kwSelect')?.value || '10';

    hideError();

    if (!validateInput(zip, kw)) {
        btn.innerHTML = originalText;
        btn.disabled = false;
        return;
    }

    try {
        const data = await fetchWithRetry('/api/calculate', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ 
                postalCode: zip.trim(), 
                systemSizeKw: parseFloat(kw),
                electricityRate: 0.12
            })
        });

        renderResults(data);
    } catch (error) {
        console.error('Calculation Error:', error);
        
        if (error.name === 'AbortError') {
            showError('Timeout', 'Request took too long. Please try again.');
        } else if (error.message.includes('Failed to fetch')) {
            showError('Connection Error', 'Cannot reach the server. Please check your connection.');
        } else {
            showError('Error', error.message || 'An unexpected error occurred.');
        }
    } finally {
        btn.innerHTML = originalText;
        btn.disabled = false;
    }
}

let chartInstance = null;

function renderResults(data) {
    const dashboard = document.getElementById('dashboard');
    if (!dashboard) return;
    
    dashboard.classList.remove('hidden');
    
    // Update stats
    const paybackEl = document.getElementById('payback');
    if (paybackEl) {
        paybackEl.textContent = formatNumber(data.paybackYears || 0, 1) + " Years";
    }
    
    const savingsEl = document.getElementById('savings');
    if (savingsEl) {
        savingsEl.textContent = formatCurrency(data.annualSavings || 0);
    }
    
    const irrEl = document.getElementById('irr');
    if (irrEl) {
        irrEl.textContent = formatNumber(data.peakSunHours || 0, 1) + ' hrs/day';
    }
    
    const climateEl = document.getElementById('climate');
    if (climateEl) {
        climateEl.textContent = data.climateZone || 'N/A';
    }
    
    const totalSavingsEl = document.getElementById('totalSavings');
    if (totalSavingsEl) {
        totalSavingsEl.textContent = formatCurrency(data.totalSavings25Year || 0);
    }
    
    const co2El = document.getElementById('co2');
    if (co2El) {
        co2El.textContent = formatNumber(data.co2OffsetKg || 0, 0);
    }

    // Render Chart
    renderChart(data);
    
    // Scroll to results
    setTimeout(() => {
        dashboard.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 100);
}

function renderChart(data) {
    const canvas = document.getElementById('usageChart');
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    if (chartInstance) chartInstance.destroy();
    
    const monthlyGen = data.monthlyGeneration || {};
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const values = months.map(m => monthlyGen[m] || 0);
    
    chartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: months,
            datasets: [{
                label: 'kWh Generated',
                data: values,
                backgroundColor: 'rgba(59, 130, 246, 0.7)',
                borderColor: '#3b82f6',
                borderWidth: 1,
                borderRadius: 4
            }]
        },
        options: { 
            responsive: true,
            maintainAspectRatio: false,
            plugins: { 
                legend: { display: false }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { color: '#94a3b8' },
                    grid: { color: 'rgba(148, 163, 184, 0.1)' }
                },
                x: {
                    ticks: { color: '#94a3b8' },
                    grid: { display: false }
                }
            }
        }
    });
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    console.log('Apolaki Solar Platform initialized');
});
