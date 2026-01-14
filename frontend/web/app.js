/**
 * India Transit Tracker - Main Application
 * Handles map initialization, user interactions, and real-time updates
 */

// Application State
const state = {
    map: null,
    selectedRegion: null,
    selectedRoute: null,
    routes: [],
    vehicles: [],
    markers: {
        vehicles: [], // Array of { id: string, marker: L.Marker }
        routes: []    // Array of L.Layer (markers/polylines)
    },
    updateInterval: null,
    globalUpdateInterval: null,
    showVehicles: true // Vehicles visible by default
};

// Initialize application when DOM is loaded
document.addEventListener('DOMContentLoaded', async () => {
    try {
        await initializeApp();
    } catch (error) {
        console.error('Failed to initialize app:', error);
    }
});

/**
 * Initialize the application
 */
async function initializeApp() {
    // Initialize map centered on India
    initializeMap();

    // Setup event listeners
    setupEventListeners();

    // Load routes for India
    await loadRoutes();

    // Activate traffic button by default
    document.getElementById('toggle-traffic').classList.add('active');

    // Hide loading screen
    setTimeout(() => {
        document.getElementById('loading-screen').classList.add('hidden');
    }, 1000);
}

/**
 * Initialize Leaflet map
 */
function initializeMap() {
    // Create map centered on India
    state.map = L.map('map', {
        zoomControl: false,
        zoomAnimation: true,
        fadeAnimation: true,
        markerZoomAnimation: true
    }).setView([20.5937, 78.9629], 5); // Center of India

    // Add tile layer (CartoDB Voyager for better street visibility)
    L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
        attribution: '© OpenStreetMap contributors & CartoDB',
        maxZoom: 19,
        minZoom: 4
    }).addTo(state.map);

    // Add zoom control
    L.control.zoom({ position: 'bottomright' }).addTo(state.map);

    // Add scale control
    L.control.scale({ position: 'bottomleft', metric: true, imperial: false }).addTo(state.map);
}

/**
 * Load routes based on selected region
 */
async function loadRoutes(filters = {}) {
    try {
        const response = await api.getRoutes(filters);
        state.routes = response.data;

        // Update vehicle stats (routes count)
        updateStats();

        // Load vehicles if enabled
        if (state.showVehicles) {
            await loadAllVehicles(filters);
        }
    } catch (error) {
        console.error('Failed to load routes:', error);
    }
}

/**
 * Load all vehicles
 */
async function loadAllVehicles(filters = {}) {
    try {
        const response = await api.getAllVehicles(filters);
        state.vehicles = response.data || [];

        console.log(`Loaded ${state.vehicles.length} vehicles`);

        // Sync markers with new data
        updateVehicleMarkers();

        // Update stats
        updateStats();

        // Start auto-refresh
        startGlobalVehicleTracking();
    } catch (error) {
        console.error('Failed to load vehicles:', error);
        state.vehicles = [];
        updateVehicleMarkers();
        updateStats();
    }
}

/**
 * Sync vehicle markers on map (Add/Update/Remove)
 */
function updateVehicleMarkers() {
    if (!state.showVehicles || state.selectedRoute) {
        // Remove all markers if hidden or in single route mode (handled separately)
        state.markers.vehicles.forEach(item => item.marker.remove());
        state.markers.vehicles = [];
        return;
    }

    const currentIds = new Set(state.vehicles.map(v => v.id));

    // 1. Remove markers for vehicles that are gone
    state.markers.vehicles = state.markers.vehicles.filter(item => {
        if (!currentIds.has(item.id)) {
            item.marker.remove();
            return false;
        }
        return true;
    });

    // 2. Add or Update markers
    state.vehicles.forEach(vehicle => {
        const existingItem = state.markers.vehicles.find(item => item.id === vehicle.id);

        if (existingItem) {
            // Update existing marker
            const oldPos = existingItem.marker.getLatLng();
            const newPos = L.latLng(vehicle.position.lat, vehicle.position.lng);

            // Animate only if position changed significantly
            if (oldPos.distanceTo(newPos) > 10) {
                // Use CSS transition (defined in styles.css) for performance instead of JS loop
                existingItem.marker.setLatLng(newPos);
            }

            // Update popup/tooltip info
            updateMarkerContent(existingItem.marker, vehicle);
        } else {
            // Create new marker
            const marker = createVehicleMarker(vehicle);
            marker.addTo(state.map);
            state.markers.vehicles.push({ id: vehicle.id, marker: marker });
        }
    });
}

/**
 * Create a single vehicle marker
 */
function createVehicleMarker(vehicle) {
    const typeClass = `vehicle-type-${(vehicle.type || 'bus').toLowerCase().replace(/\s+/g, '-')}`;
    const icons = { 'Bus': '🚌', 'Metro': '🚇', 'Tram': '🚊', 'Light Rail': '🚈', 'Train': '🚆' };
    const iconChar = icons[vehicle.type] || '🚌';

    const icon = L.divIcon({
        className: 'vehicle-marker',
        html: `<div class="vehicle-icon-wrapper ${typeClass}">${iconChar}</div>`,
        iconSize: [32, 32],
        iconAnchor: [16, 16]
    });

    const marker = L.marker([vehicle.position.lat, vehicle.position.lng], {
        icon: icon,
        riseOnHover: true
    });

    marker.vehicleId = vehicle.id;
    updateMarkerContent(marker, vehicle);

    // Events
    marker.on('click', () => loadRouteDetails(vehicle.route_id));
    marker.on('mouseover', function () { this.openTooltip(); });

    return marker;
}

/**
 * Update content of marker popup and tooltip
 */
function updateMarkerContent(marker, vehicle) {
    // Tooltip
    marker.bindTooltip(
        `<strong>${vehicle.route_number || 'Route'}</strong><br>${vehicle.route_name}`,
        { permanent: false, direction: 'top', offset: [0, -16] }
    );

    // Popup
    const nextStops = vehicle.next_stops || [];
    const nextStopText = nextStops.length >= 2
        ? `${nextStops[0].name} (${nextStops[0].eta} min) → ${nextStops[1].name} (${nextStops[1].eta} min)`
        : 'Terminal';

    const statusColor = vehicle.status && vehicle.status.includes('Delayed') ? '#f5576c' : '#4ade80';

    marker.bindPopup(`
        <div style="font-family: Inter, sans-serif; min-width: 220px;">
            <div style="font-weight: 700; font-size: 16px; margin-bottom: 8px; color: #667eea;">
                ${vehicle.route_number || 'Route'}
            </div>
            <div style="font-weight: 600; margin-bottom: 8px; font-size: 14px;">${vehicle.route_name}</div>
            <div style="font-size: 13px; color: #333; line-height: 1.8;">
                <div>🚀 <strong>Speed:</strong> ${vehicle.speed} km/h</div>
                <div>⏱️ <strong>Status:</strong> <span style="color: ${statusColor};">${vehicle.status || 'On Time'}</span></div>
                <div>📍 <strong>Next Stops:</strong><br><span style="margin-left: 20px;">${nextStopText}</span></div>
                <div>👥 <strong>Occupancy:</strong> ${vehicle.occupancy}/${vehicle.capacity} (${Math.round((vehicle.occupancy / vehicle.capacity) * 100)}%)</div>
            </div>
        </div>
    `);
}

/**
 * Start global vehicle tracking loop
 */
function startGlobalVehicleTracking() {
    if (state.globalUpdateInterval) clearInterval(state.globalUpdateInterval);

    state.globalUpdateInterval = setInterval(async () => {
        if (!state.showVehicles || state.selectedRoute) return;

        try {
            const response = await api.getAllVehicles({});
            state.vehicles = response.data || [];
            updateVehicleMarkers(); // This handles add/update/remove
            updateStats();
        } catch (error) {
            console.error('Failed to update vehicles:', error);
        }
    }, 5000);
}

/**
 * Animate marker movement smoothly
 */
/**
 * CSS Transition handles animation now.
 * Keeping this helper empty or removed to avoid JS overhead.
 */
function animateMarkerMovement(marker, startPos, endPos, duration) {
    // Deprecated in favor of CSS transitions
    // marker.setLatLng(endPos); 
}

/**
 * Load and display route details (Single Route Mode)
 */
async function loadRouteDetails(routeId) {
    try {
        const response = await api.getRouteDetails(routeId);
        const route = response.data;
        state.selectedRoute = route;

        // Hide global vehicles
        state.markers.vehicles.forEach(item => item.marker.remove());
        state.markers.vehicles = [];

        // Display route path
        displayRoute(route);

        // Load vehicles for this route
        const vehiclesResponse = await api.getVehiclePositions(routeId);
        const vehicles = vehiclesResponse.data;

        // Update side panel
        displayRoutePanel(route, vehicles);

        // Start route tracking
        startRouteTracking(routeId);
    } catch (error) {
        console.error('Failed to load route details:', error);
    }
}

/**
 * Display route geometry on map
 */
function displayRoute(route) {
    state.markers.routes.forEach(layer => layer.remove());
    state.markers.routes = [];

    if (route.stops && route.stops.length > 0) {
        const coordinates = route.stops.map(stop => [stop.lat, stop.lng]);

        // Route Line
        const polyline = L.polyline(coordinates, {
            color: '#667eea', weight: 4, opacity: 0.7, smoothFactor: 1
        }).addTo(state.map);
        state.markers.routes.push(polyline);

        // Stops
        route.stops.forEach(stop => {
            const circle = L.circleMarker([stop.lat, stop.lng], {
                radius: 6, fillColor: '#fff', color: '#667eea', weight: 2, opacity: 1, fillOpacity: 1
            }).addTo(state.map);

            circle.bindPopup(`<strong>${stop.name}</strong><br><small>Stop ${stop.order}</small>`);
            state.markers.routes.push(circle);
        });

        state.map.fitBounds(polyline.getBounds(), { padding: [50, 50] });
    }
}

/**
 * Route Tracking Loop (Single Route)
 */
function startRouteTracking(routeId) {
    if (state.updateInterval) clearInterval(state.updateInterval);

    state.updateInterval = setInterval(async () => {
        try {
            const response = await api.getVehicleUpdates(routeId);
            const vehicles = response.data;

            // Update panel list
            const list = document.getElementById('vehicle-list');
            if (list) list.innerHTML = vehicles.map(createVehicleCard).join('');

            // Update map markers
            // Remove old route markers
            state.markers.vehicles.forEach(item => item.marker.remove());

            // Add new markers
            state.markers.vehicles = vehicles.map(v => {
                const marker = createVehicleMarker(v);
                marker.addTo(state.map);
                return { id: v.id, marker: marker };
            });

        } catch (error) {
            console.error('Failed to update route vehicles:', error);
        }
    }, 5000);
}

/**
 * UI: Side Panel
 */
function displayRoutePanel(route, vehicles) {
    const panel = document.getElementById('panel-content');
    const title = document.getElementById('panel-title');
    document.getElementById('side-panel').classList.add('open');

    title.textContent = route.name;

    panel.innerHTML = `
        <div class="route-details">
            <div class="route-header">
                <div class="route-number">${route.route_number}</div>
                <h3>${route.name}</h3>
            </div>
            <div class="route-info">
                <div class="info-row">
                    <span>${route.city}, ${route.country}</span>
                </div>
                <div class="info-row">
                    <span>Every ${route.frequency} • ${route.stops.length} stops</span>
                </div>
            </div>
            <div class="section-title">Live Vehicles (${vehicles.length})</div>
            <div class="vehicle-list" id="vehicle-list">
                ${vehicles.map(createVehicleCard).join('')}
            </div>
        </div>
    `;
}

/**
 * UI: Vehicle Card
 */
function createVehicleCard(vehicle) {
    const occupancy = Math.round((vehicle.occupancy / vehicle.capacity) * 100);
    const nextStops = vehicle.next_stops || [];
    const statusClass = vehicle.status && vehicle.status.includes('Delayed') ? 'status-delayed' : 'status-ontime';

    return `
        <div class="vehicle-card">
            <div class="vehicle-header">
                <div class="vehicle-id">
                    <div style="font-weight: 700; color: #667eea;">${vehicle.route_number}</div>
                    <div style="font-size: 11px; opacity: 0.7;">${vehicle.id.replace('vehicle_', '#')}</div>
                </div>
                <div class="vehicle-status ${statusClass}">
                    <span class="status-dot"></span>
                    <span>${vehicle.status || 'On Time'}</span>
                </div>
            </div>
            <div class="vehicle-info">
                <div style="display:flex; justify-content:space-between;">
                    <span>Speed: ${vehicle.speed} km/h</span>
                    <span>${occupancy}% Full</span>
                </div>
            </div>
            <div class="occupancy-bar">
                <div class="occupancy-fill" style="width: ${occupancy}%"></div>
            </div>
            ${nextStops.length >= 2 ? `
                <div class="next-stops">
                    <div class="next-stop-title">Next: ${nextStops[0].name} (${nextStops[0].eta} min)</div>
                </div>
            ` : ''}
        </div>
    `;
}

/**
 * UI: Traffic Report
 */
function openTrafficReport() {
    if (document.querySelector('.traffic-report-panel')) return;

    // Filter vehicles visible in current map view
    const bounds = state.map.getBounds();
    const visibleVehicles = state.vehicles.filter(v =>
        bounds.contains([v.position.lat, v.position.lng])
    );

    const crowded = visibleVehicles.filter(v => (v.occupancy / v.capacity) > 0.7)
        .sort((a, b) => (b.occupancy / b.capacity) - (a.occupancy / a.capacity)).slice(0, 5);

    const delayed = visibleVehicles.filter(v => v.status && v.status.includes('Delayed')).slice(0, 5);

    const renderItem = (v, type) => {
        const isCrowded = type === 'crowded';
        const cssClass = isCrowded ? 'high-traffic' : 'medium-traffic';
        const badgeClass = isCrowded ? 'status-crowded' : 'status-moderate';
        const badgeText = isCrowded ? `${Math.round((v.occupancy / v.capacity) * 100)}% Full` : v.status;

        return `
            <div class="traffic-item ${cssClass}" onclick="openVehicleRoute('${v.id}', '${v.route_id}')">
                <div class="traffic-info">
                    <div class="traffic-route">${v.route_number || v.route_name}</div>
                    <div class="traffic-details"><span>#${v.id.split('_')[1]} • ${v.speed} km/h</span></div>
                </div>
                <div class="traffic-status ${badgeClass}">${badgeText}</div>
            </div>
        `;
    };

    const modal = document.createElement('div');
    modal.innerHTML = `
        <div class="overlay-backdrop" onclick="closeTrafficReport()"></div>
        <div class="traffic-report-panel">
            <div class="traffic-report-header">
                <h2>📊 Live Traffic Report</h2>
                <div style="font-size:12px; opacity:0.7; margin-top:2px;">Visible Region Only</div>
                <button class="close-report-btn" onclick="closeTrafficReport()">✕</button>
            </div>
            <div class="traffic-report-content">
                <div class="traffic-section">
                    <h3>⚠️ Crowded Routes (>70%)</h3>
                    ${crowded.length ? crowded.map(v => renderItem(v, 'crowded')).join('') : '<p style="text-align:center;color:#888">No crowded vehicles in view</p>'}
                </div>
                <div class="traffic-section">
                    <h3>⏱️ Delays</h3>
                    ${delayed.length ? delayed.map(v => renderItem(v, 'delayed')).join('') : '<p style="text-align:center;color:#888">No reported delays in view</p>'}
                </div>
            </div>
        </div>
    `;
    document.body.appendChild(modal);
}

/**
 * Helper: Switch to route and pan to vehicle
 */
window.openVehicleRoute = async function (vehicleId, routeId) {
    closeTrafficReport();

    // 1. Load the route details (switches view)
    await loadRouteDetails(routeId);

    // 2. Find the vehicle marker (now part of the route view)
    // We need a small delay to allow the route markers to be created
    setTimeout(() => {
        const vehicle = state.vehicles.find(v => v.id === vehicleId) ||
            state.markers.vehicles.find(m => m.id === vehicleId); // might be in state.markers if loaded

        if (vehicle) {
            // Find marker object
            const markerItem = state.markers.vehicles.find(m => m.id === vehicleId);

            if (markerItem) {
                state.map.flyTo(markerItem.marker.getLatLng(), 15, {
                    animate: true,
                    duration: 1.5
                });
                markerItem.marker.openPopup();
            } else {
                // Try finding it in the freshly loaded state.vehicles if not yet matched
                const freshVehicle = state.vehicles.find(v => v.id === vehicleId);
                if (freshVehicle) state.map.flyTo([freshVehicle.position.lat, freshVehicle.position.lng], 15);
            }
        }
    }, 500);
};

window.panToVehicle = function (vehicleId) {
    // Deprecated for direct pan, now uses openVehicleRoute
};

window.closeTrafficReport = function () {
    const el = document.querySelector('.traffic-report-panel').parentNode;
    if (el) el.remove();
};

/**
 * Update stats
 */
function updateStats() {
    const routes = document.getElementById('active-routes');
    const vehicles = document.getElementById('active-vehicles');
    if (routes && vehicles && state.routes && state.vehicles) {
        // Only if elements still exist (we removed them in HTML, but if user added them back)
        // Since we removed them from HTML, this function might fail if elements are missing,
        // but user request said "remove active counts".
        // We will just log it.
        console.log(`Stats: ${state.routes.length} Routes, ${state.vehicles.length} Vehicles`);
    } else {
        console.log(`Stats: ${state.routes?.length || 0} Routes, ${state.vehicles?.length || 0} Vehicles`);
    }
}

/**
 * Event Listeners
 */
function setupEventListeners() {
    // Traffic Toggle
    document.getElementById('toggle-traffic').addEventListener('click', function () {
        state.showVehicles = !state.showVehicles;
        this.classList.toggle('active', state.showVehicles);
        updateVehicleMarkers();
        startGlobalVehicleTracking();
    });

    // Refresh
    document.getElementById('refresh-btn').addEventListener('click', () => loadRoutes());

    // Locate
    document.getElementById('locate-btn').addEventListener('click', () => {
        state.map.setView([20.5937, 78.9629], 5);
    });

    // Traffic Report
    document.getElementById('traffic-report-btn').addEventListener('click', openTrafficReport);

    // Close Panel
    document.getElementById('close-panel').addEventListener('click', () => {
        state.selectedRoute = null;
        if (state.updateInterval) clearInterval(state.updateInterval);
        document.getElementById('side-panel').classList.remove('open');
        state.markers.routes.forEach(m => m.remove());
        state.markers.routes = [];

        // Resume global view
        loadAllVehicles();
    });

    // Search logic (Simplified)
    const searchInput = document.getElementById('search-input');
    const resultsList = document.getElementById('search-results-list');
    const resultsContainer = document.getElementById('search-results');

    searchInput.addEventListener('input', async (e) => {
        const query = e.target.value.toLowerCase();
        if (query.length < 2) {
            resultsContainer.style.display = 'none';
            return;
        }

        const response = await api.searchRoutes(query);
        const results = response.data;

        resultsContainer.style.display = 'block';
        document.getElementById('results-count').textContent = `${results.length} found`;

        resultsList.innerHTML = results.map(r => `
            <div class="search-result-item" onclick="selectSearchedRoute('${r.id}')">
                <div class="result-route-name">${r.route_number}</div>
                <div class="result-route-details">${r.name}</div>
            </div>
        `).join('');
    });

    // Hide search on click outside
    document.addEventListener('click', (e) => {
        if (!e.target.closest('.search-container')) resultsContainer.style.display = 'none';
    });
}

// Global helper for search click
window.selectSearchedRoute = function (routeId) {
    document.getElementById('search-results').style.display = 'none';
    document.getElementById('search-input').value = '';
    loadRouteDetails(routeId);
};
