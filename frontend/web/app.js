/**
 * Global Transit Tracker - Main Application
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
        vehicles: [],
        routes: []
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
        showError('Failed to load application. Please refresh the page.');
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
    // Create map centered on India with interactive options
    state.map = L.map('map', {
        zoomControl: false,
        zoomAnimation: true,
        fadeAnimation: true,
        markerZoomAnimation: true
    }).setView([20.5937, 78.9629], 5); // Center of India

    // Add tile layer (OpenStreetMap)
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors',
        maxZoom: 19,
        minZoom: 4
    }).addTo(state.map);

    // Add zoom control to bottom right
    L.control.zoom({
        position: 'bottomright'
    }).addTo(state.map);

    // Add scale control
    L.control.scale({
        position: 'bottomleft',
        metric: true,
        imperial: false
    }).addTo(state.map);
}

/**
 * Load routes based on selected region
 */
async function loadRoutes(filters = {}) {
    try {
        const response = await api.getRoutes(filters);
        state.routes = response.data;

        // Update stats
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
 * Load all vehicles for current region
 */
async function loadAllVehicles(filters = {}) {
    try {
        const response = await api.getAllVehicles(filters);
        state.vehicles = response.data || [];

        console.log(`Loaded ${state.vehicles.length} vehicles`);

        // Display vehicles on map
        displayVehicles();

        // Update stats
        updateStats();

        // Start auto-refresh for vehicle positions
        startGlobalVehicleTracking();
    } catch (error) {
        console.error('Failed to load vehicles:', error);
        state.vehicles = [];
        updateStats();
    }
}

/**
 * Display vehicles on map
 */
function displayVehicles() {
    // Clear existing vehicle markers
    state.markers.vehicles.forEach(marker => marker.remove());
    state.markers.vehicles = [];

    if (!state.showVehicles) return;

    // Create custom icon for vehicles with animation
    const vehicleIcon = (type) => {
        const colors = {
            'Bus': '#667eea',
            'Metro': '#f5576c',
            'Tram': '#4ade80',
            'Light Rail': '#fbbf24'
        };

        const icons = {
            'Bus': '🚌',
            'Metro': '🚇',
            'Tram': '🚊',
            'Light Rail': '🚈'
        };

        return L.divIcon({
            className: 'vehicle-marker',
            html: `<div class="vehicle-icon-wrapper" style="
                width: 32px;
                height: 32px;
                background: ${colors[type] || '#667eea'};
                border: 3px solid white;
                border-radius: 50%;
                box-shadow: 0 4px 12px rgba(0,0,0,0.3);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 16px;
                cursor: pointer;
                transition: all 0.3s ease;
                animation: pulse 2s infinite;
            ">${icons[type] || '🚌'}</div>`,
            iconSize: [32, 32],
            iconAnchor: [16, 16]
        });
    };

    // Add markers for each vehicle
    state.vehicles.forEach(vehicle => {
        const marker = L.marker(
            [vehicle.position.lat, vehicle.position.lng],
            {
                icon: vehicleIcon(vehicle.type),
                riseOnHover: true
            }
        ).addTo(state.map);

        // Add tooltip on hover
        marker.bindTooltip(
            `<strong>${vehicle.route_number}</strong><br>${vehicle.route_name}`,
            {
                permanent: false,
                direction: 'top',
                offset: [0, -16]
            }
        );

        // Add popup with enhanced info
        const nextStops = vehicle.next_stops || [];
        const nextStopText = nextStops.length >= 2
            ? `${nextStops[0].name} (${nextStops[0].eta} min) → ${nextStops[1].name} (${nextStops[1].eta} min)`
            : vehicle.next_stop || 'Terminal';

        marker.bindPopup(`
            <div style="font-family: Inter, sans-serif; min-width: 220px;">
                <div style="font-weight: 700; font-size: 16px; margin-bottom: 8px; color: #667eea;">
                    ${vehicle.route_number || 'Route'}
                </div>
                <div style="font-weight: 600; margin-bottom: 8px; font-size: 14px;">${vehicle.route_name}</div>
                <div style="font-size: 13px; color: #333; line-height: 1.8;">
                    <div>🚀 <strong>Speed:</strong> ${vehicle.speed} km/h</div>
                    <div>⏱️ <strong>Status:</strong> <span style="color: ${vehicle.status && vehicle.status.includes('Delayed') ? '#f5576c' : '#4ade80'};">${vehicle.status || 'On Time'}</span></div>
                    <div>📍 <strong>Next Stops:</strong><br><span style="margin-left: 20px;">${nextStopText}</span></div>
                    <div>👥 <strong>Occupancy:</strong> ${vehicle.occupancy}/${vehicle.capacity} (${Math.round((vehicle.occupancy / vehicle.capacity) * 100)}%)</div>
                </div>
            </div>
        `);

        // Click to view route details
        marker.on('click', () => {
            loadRouteDetails(vehicle.route_id);
        });

        // Hover effect
        marker.on('mouseover', function () {
            this.openTooltip();
        });

        // Store marker reference with vehicle ID for updates
        marker.vehicleId = vehicle.id;
        state.markers.vehicles.push(marker);
    });

    console.log(`Displayed ${state.vehicles.length} vehicle markers`);
}

/**
 * Load and display route details
 */
async function loadRouteDetails(routeId) {
    try {
        const response = await api.getRouteDetails(routeId);
        const route = response.data;

        state.selectedRoute = route;

        // Display route on map
        displayRoute(route);

        // Load vehicles for this route
        const vehiclesResponse = await api.getVehiclePositions(routeId);
        const vehicles = vehiclesResponse.data;

        // Update side panel
        displayRoutePanel(route, vehicles);

        // Start auto-refresh for this route
        startVehicleTracking(routeId);

    } catch (error) {
        console.error('Failed to load route details:', error);
    }
}

/**
 * Display route on map
 */
function displayRoute(route) {
    // Clear existing route markers
    state.markers.routes.forEach(marker => marker.remove());
    state.markers.routes = [];

    // Draw route path
    if (route.stops && route.stops.length > 0) {
        const coordinates = route.stops.map(stop => [stop.lat, stop.lng]);

        const routeLine = L.polyline(coordinates, {
            color: '#667eea',
            weight: 4,
            opacity: 0.7,
            smoothFactor: 1
        }).addTo(state.map);

        state.markers.routes.push(routeLine);

        // Add stop markers
        route.stops.forEach((stop, index) => {
            const stopMarker = L.circleMarker([stop.lat, stop.lng], {
                radius: 6,
                fillColor: '#fff',
                color: '#667eea',
                weight: 2,
                opacity: 1,
                fillOpacity: 1
            }).addTo(state.map);

            stopMarker.bindPopup(`
                <div style="font-family: Inter, sans-serif;">
                    <strong>${stop.name}</strong><br>
                    <small>Stop ${stop.order} of ${route.stops.length}</small>
                </div>
            `);

            state.markers.routes.push(stopMarker);
        });

        // Fit map to route bounds
        state.map.fitBounds(routeLine.getBounds(), { padding: [50, 50] });
    }
}

/**
 * Display route details in side panel
 */
function displayRoutePanel(route, vehicles) {
    const panel = document.getElementById('panel-content');
    const title = document.getElementById('panel-title');

    title.textContent = route.name;

    panel.innerHTML = `
        <div class="route-details">
            <div class="route-header">
                <div class="route-number">${route.route_number}</div>
                <h3>${route.name}</h3>
            </div>
            
            <div class="route-info">
                <div class="info-row">
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                        <path d="M8 16s6-5.686 6-10A6 6 0 0 0 2 6c0 4.314 6 10 6 10zm0-7a3 3 0 1 1 0-6 3 3 0 0 1 0 6z"/>
                    </svg>
                    <span>${route.city}, ${route.country}</span>
                </div>
                
                <div class="info-row">
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                        <path d="M8 3.5a.5.5 0 0 0-1 0V9a.5.5 0 0 0 .252.434l3.5 2a.5.5 0 0 0 .496-.868L8 8.71V3.5z"/>
                        <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm7-8A7 7 0 1 1 1 8a7 7 0 0 1 14 0z"/>
                    </svg>
                    <span>Every ${route.frequency}</span>
                </div>
                
                <div class="info-row">
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                        <path d="M0 4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V4zm2-1a1 1 0 0 0-1 1v.217l7 4.2 7-4.2V4a1 1 0 0 0-1-1H2zm13 2.383-4.708 2.825L15 11.105V5.383zm-.034 6.876-5.64-3.471L8 9.583l-1.326-.795-5.64 3.47A1 1 0 0 0 2 13h12a1 1 0 0 0 .966-.741zM1 11.105l4.708-2.897L1 5.383v5.722z"/>
                    </svg>
                    <span>${route.stops.length} stops</span>
                </div>
            </div>
            
            <div class="section-title">Live Vehicles (${vehicles.length})</div>
            
            <div class="vehicle-list" id="vehicle-list">
                ${vehicles.map(vehicle => createVehicleCard(vehicle)).join('')}
            </div>
        </div>
    `;
}

/**
 * Create vehicle card HTML
 */
function createVehicleCard(vehicle) {
    const occupancyPercent = (vehicle.occupancy / vehicle.capacity) * 100;
    const nextStops = vehicle.next_stops || [];
    const status = vehicle.status || 'On Time';
    const statusClass = status.includes('Delayed') ? 'status-delayed' : 'status-ontime';

    return `
        <div class="vehicle-card">
            <div class="vehicle-header">
                <div class="vehicle-id">
                    <div style="font-size: 14px; font-weight: 700; color: #667eea;">${vehicle.route_number || 'Route'}</div>
                    <div style="font-size: 11px; color: var(--text-tertiary);">${vehicle.id.replace('vehicle_', 'Vehicle #')}</div>
                </div>
                <div class="vehicle-status ${statusClass}">
                    <span class="status-dot"></span>
                    <span>${status}</span>
                </div>
            </div>
            
            <div class="vehicle-info">
                <div style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                    <span>Speed:</span>
                    <span style="font-weight: 600;">${vehicle.speed} km/h</span>
                </div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                    <span>Passengers:</span>
                    <span style="font-weight: 600;">${vehicle.occupancy}/${vehicle.capacity}</span>
                </div>
            </div>
            
            <div class="occupancy-bar">
                <div class="occupancy-fill" style="width: ${occupancyPercent}%"></div>
            </div>
            
            ${nextStops.length >= 2 ? `
                <div class="next-stops">
                    <div class="next-stop-title">Next Stops:</div>
                    <div class="next-stop-item">
                        <div class="stop-number">1</div>
                        <div class="stop-details">
                            <div class="stop-name">${nextStops[0].name}</div>
                            <div class="stop-eta">${nextStops[0].eta} min</div>
                        </div>
                    </div>
                    <div class="next-stop-item">
                        <div class="stop-number">2</div>
                        <div class="stop-details">
                            <div class="stop-name">${nextStops[1].name}</div>
                            <div class="stop-eta">${nextStops[1].eta} min</div>
                        </div>
                    </div>
                </div>
            ` : ''}
        </div>
    `;
}

/**
 * Start real-time vehicle tracking
 */
function startVehicleTracking(routeId) {
    // Clear existing interval
    if (state.updateInterval) {
        clearInterval(state.updateInterval);
    }

    // Update every 5 seconds
    state.updateInterval = setInterval(async () => {
        try {
            const response = await api.getVehicleUpdates(routeId);
            const vehicles = response.data;

            // Update vehicle list in panel
            const vehicleList = document.getElementById('vehicle-list');
            if (vehicleList) {
                vehicleList.innerHTML = vehicles.map(vehicle => createVehicleCard(vehicle)).join('');
            }

            // Update vehicle markers on map
            // For simplicity, we'll just update the global vehicles if showing all
            if (state.showVehicles && !state.selectedRoute) {
                await loadAllVehicles(state.selectedRegion ? { country: state.selectedRegion } : {});
            }

        } catch (error) {
            console.error('Failed to update vehicles:', error);
        }
    }, 5000);
}

/**
 * Update statistics display
 */
function updateStats() {
    const routeCount = state.routes ? state.routes.length : 0;
    const vehicleCount = state.vehicles ? state.vehicles.length : 0;

    document.getElementById('active-routes').textContent = routeCount;
    document.getElementById('active-vehicles').textContent = vehicleCount;

    console.log(`Stats updated - Routes: ${routeCount}, Vehicles: ${vehicleCount}`);
}

/**
 * Start global vehicle tracking with smooth movement
 */
function startGlobalVehicleTracking() {
    // Clear existing interval
    if (state.globalUpdateInterval) {
        clearInterval(state.globalUpdateInterval);
    }

    // Update every 5 seconds
    state.globalUpdateInterval = setInterval(async () => {
        if (!state.showVehicles || state.selectedRoute) return;

        try {
            const response = await api.getAllVehicles({});
            const updatedVehicles = response.data || [];

            // Smoothly move vehicles to new positions
            updatedVehicles.forEach(updatedVehicle => {
                const marker = state.markers.vehicles.find(m => m.vehicleId === updatedVehicle.id);
                if (marker) {
                    const oldPos = marker.getLatLng();
                    const newPos = L.latLng(updatedVehicle.position.lat, updatedVehicle.position.lng);

                    // Animate movement
                    animateMarkerMovement(marker, oldPos, newPos, 4000); // 4 second animation

                    // Update popup content
                    const nextStops = updatedVehicle.next_stops || [];
                    const nextStopText = nextStops.length >= 2
                        ? `${nextStops[0].name} (${nextStops[0].eta} min) → ${nextStops[1].name} (${nextStops[1].eta} min)`
                        : 'Terminal';

                    marker.setPopupContent(`
                        <div style="font-family: Inter, sans-serif; min-width: 220px;">
                            <div style="font-weight: 700; font-size: 16px; margin-bottom: 8px; color: #667eea;">
                                ${updatedVehicle.route_number || 'Route'}
                            </div>
                            <div style="font-weight: 600; margin-bottom: 8px; font-size: 14px;">${updatedVehicle.route_name}</div>
                            <div style="font-size: 13px; color: #333; line-height: 1.8;">
                                <div>🚀 <strong>Speed:</strong> ${updatedVehicle.speed} km/h</div>
                                <div>⏱️ <strong>Status:</strong> <span style="color: ${updatedVehicle.status && updatedVehicle.status.includes('Delayed') ? '#f5576c' : '#4ade80'};">${updatedVehicle.status || 'On Time'}</span></div>
                                <div>📍 <strong>Next Stops:</strong><br><span style="margin-left: 20px;">${nextStopText}</span></div>
                                <div>👥 <strong>Occupancy:</strong> ${updatedVehicle.occupancy}/${updatedVehicle.capacity} (${Math.round((updatedVehicle.occupancy / updatedVehicle.capacity) * 100)}%)</div>
                            </div>
                        </div>
                    `);
                }
            });

            // Update state
            state.vehicles = updatedVehicles;
            updateStats();

        } catch (error) {
            console.error('Failed to update vehicles:', error);
        }
    }, 5000);
}

/**
 * Animate marker movement smoothly
 */
function animateMarkerMovement(marker, startPos, endPos, duration) {
    const startTime = Date.now();
    const startLat = startPos.lat;
    const startLng = startPos.lng;
    const endLat = endPos.lat;
    const endLng = endPos.lng;

    function updatePosition() {
        const elapsed = Date.now() - startTime;
        const progress = Math.min(elapsed / duration, 1);

        // Easing function for smooth movement
        const easeProgress = progress < 0.5
            ? 2 * progress * progress
            : 1 - Math.pow(-2 * progress + 2, 2) / 2;

        const currentLat = startLat + (endLat - startLat) * easeProgress;
        const currentLng = startLng + (endLng - startLng) * easeProgress;

        marker.setLatLng([currentLat, currentLng]);

        if (progress < 1) {
            requestAnimationFrame(updatePosition);
        }
    }

    requestAnimationFrame(updatePosition);
}

/**
 * Open traffic report modal
 */
function openTrafficReport() {
    // Check if modal already exists
    if (document.querySelector('.traffic-report-panel')) return;

    // Filter crowded vehicles (occupancy > 70%)
    const crowdedVehicles = state.vehicles.filter(v =>
        (v.occupancy / v.capacity) > 0.7
    ).sort((a, b) => (b.occupancy / b.capacity) - (a.occupancy / a.capacity));

    // Filter delayed vehicles
    const delayedVehicles = state.vehicles.filter(v =>
        v.status && v.status.includes('Delayed')
    );

    // Create modal structure
    const backdrop = document.createElement('div');
    backdrop.className = 'overlay-backdrop';
    backdrop.onclick = closeTrafficReport; // Close when clicking backdrop

    const panel = document.createElement('div');
    panel.className = 'traffic-report-panel';

    // Generate content
    let crowdedContent = '';
    if (crowdedVehicles.length > 0) {
        crowdedContent = crowdedVehicles.slice(0, 5).map(v => {
            const occupancyPct = Math.round((v.occupancy / v.capacity) * 100);
            return `
                <div class="traffic-item high-traffic">
                    <div class="traffic-info">
                        <div class="traffic-route">${v.route_number || v.route_name}</div>
                        <div class="traffic-details">
                            <span>Vehicle #${v.id.split('_')[1]}</span>
                            <span>${v.speed} km/h</span>
                        </div>
                    </div>
                    <div class="traffic-status status-crowded">
                        ${occupancyPct}% Full
                    </div>
                </div>
            `;
        }).join('');
    } else {
        crowdedContent = '<div style="color: var(--text-secondary); text-align: center; padding: 1rem;">No substantial crowding reported</div>';
    }

    let delayedContent = '';
    if (delayedVehicles.length > 0) {
        delayedContent = delayedVehicles.slice(0, 5).map(v => `
            <div class="traffic-item medium-traffic">
                <div class="traffic-info">
                    <div class="traffic-route">${v.route_number || v.route_name}</div>
                    <div class="traffic-details">
                        <span>Heading to: ${v.next_stops && v.next_stops[0] ? v.next_stops[0].name : 'Unknown'}</span>
                    </div>
                </div>
                <div class="traffic-status status-moderate">
                    ${v.status}
                </div>
            </div>
        `).join('');
    } else {
        delayedContent = '<div style="color: var(--text-secondary); text-align: center; padding: 1rem;">No delays reported</div>';
    }

    panel.innerHTML = `
        <div class="traffic-report-header">
            <h2>
                <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" color="#fbbf24">
                    <path d="M12 2L2 22h20L12 2zm0 3.5L18.5 20H5.5L12 5.5zM11 16h2v2h-2v-2zm0-6h2v4h-2v-4z"/>
                </svg>
                Live Traffic Report
            </h2>
            <button class="close-report-btn" onclick="closeTrafficReport()">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
                </svg>
            </button>
        </div>
        <div class="traffic-report-content">
            <div class="traffic-section">
                <h3>⚠️ High Occupancy Routes</h3>
                ${crowdedContent}
            </div>
            
            <div class="traffic-section">
                <h3>⏱️ Delayed Services</h3>
                ${delayedContent}
            </div>
        </div>
    `;

    document.body.appendChild(backdrop);
    document.body.appendChild(panel);
}

/**
 * Close traffic report modal
 */
// Define globally so it can be called from HTML onclick
window.closeTrafficReport = function () {
    const backdrop = document.querySelector('.overlay-backdrop');
    const panel = document.querySelector('.traffic-report-panel');

    if (backdrop) backdrop.remove();
    if (panel) panel.remove();
}

/**
 * Setup event listeners
 */
function setupEventListeners() {
    // Search input
    const searchInput = document.getElementById('search-input');
    const searchResults = document.getElementById('search-results');
    const clearSearch = document.getElementById('clear-search');

    let searchTimeout;
    searchInput.addEventListener('input', (e) => {
        const query = e.target.value.trim();

        // Show/hide clear button
        clearSearch.style.display = query ? 'flex' : 'none';

        // Debounce search
        clearTimeout(searchTimeout);

        if (query.length === 0) {
            searchResults.style.display = 'none';
            return;
        }

        searchTimeout = setTimeout(async () => {
            await performSearch(query);
        }, 300);
    });

    // Clear search
    clearSearch.addEventListener('click', () => {
        searchInput.value = '';
        clearSearch.style.display = 'none';
        searchResults.style.display = 'none';
    });

    // Close search results when clicking outside
    document.addEventListener('click', (e) => {
        if (!e.target.closest('.search-container')) {
            searchResults.style.display = 'none';
        }
    });

    // Refresh button
    document.getElementById('refresh-btn').addEventListener('click', async () => {
        const filters = state.selectedRegion ? { country: state.selectedRegion } : {};
        await loadRoutes(filters);
    });

    // Locate button
    document.getElementById('locate-btn').addEventListener('click', () => {
        if (state.selectedRoute && state.selectedRoute.stops.length > 0) {
            state.map.setView([state.selectedRoute.stops[0].lat, state.selectedRoute.stops[0].lng], 13);
        } else if (state.selectedRegion && state.routes.length > 0) {
            const firstRoute = state.routes[0];
            if (firstRoute.stops && firstRoute.stops.length > 0) {
                state.map.setView([firstRoute.stops[0].lat, firstRoute.stops[0].lng], 10);
            }
        } else {
            state.map.setView([20, 0], 2);
        }
    });

    // Toggle traffic button
    const toggleTrafficBtn = document.getElementById('toggle-traffic');
    toggleTrafficBtn.addEventListener('click', async () => {
        state.showVehicles = !state.showVehicles;
        toggleTrafficBtn.classList.toggle('active');

        if (state.showVehicles) {
            const filters = state.selectedRegion ? { country: state.selectedRegion } : {};
            await loadAllVehicles(filters);
        } else {
            // Clear vehicle markers
            state.markers.vehicles.forEach(marker => marker.remove());
            state.markers.vehicles = [];
        }
    });

    // Traffic report button
    document.getElementById('traffic-report-btn').addEventListener('click', openTrafficReport);

    // Close panel button
    document.getElementById('close-panel').addEventListener('click', () => {
        // Clear selected route
        state.selectedRoute = null;
        clearInterval(state.updateInterval);
        state.map.closePopup(); // Close any open popups
        document.getElementById('side-panel').classList.remove('open'); // Close the side panel

        // Clear route markers
        state.markers.routes.forEach(marker => marker.remove());
        state.markers.routes = [];

        // Reset panel
        document.getElementById('panel-title').textContent = 'Select a Route';
        document.getElementById('panel-content').innerHTML = `
            <div class="empty-state">
                <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                    <circle cx="32" cy="32" r="30" stroke="currentColor" stroke-width="2" opacity="0.2"/>
                    <path d="M32 20v24M20 32h24" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                </svg>
                <p>Search for a route or click on the map to view details</p>
            </div>
        `;
    });
}

/**
 * Perform search
 */
async function performSearch(query) {
    try {
        const response = await api.searchRoutes(query, state.selectedRegion);
        const results = response.data;

        const searchResults = document.getElementById('search-results');
        const searchResultsList = document.getElementById('search-results-list');
        const resultsCount = document.getElementById('results-count');

        resultsCount.textContent = `${results.length} result${results.length !== 1 ? 's' : ''}`;

        if (results.length === 0) {
            searchResultsList.innerHTML = `
                <div style="padding: 2rem; text-align: center; color: var(--text-secondary);">
                    No routes found for "${query}"
                </div>
            `;
        } else {
            searchResultsList.innerHTML = results.map(route => `
                <div class="search-result-item" data-route-id="${route.id}">
                    <div class="result-route-name">${route.name}</div>
                    <div class="result-route-details">
                        <span class="result-badge">${route.type}</span>
                        <span>${route.city}</span>
                        <span>•</span>
                        <span>${route.stops.length} stops</span>
                    </div>
                </div>
            `).join('');

            // Add click handlers
            searchResultsList.querySelectorAll('.search-result-item').forEach(item => {
                item.addEventListener('click', () => {
                    const routeId = item.dataset.routeId;
                    loadRouteDetails(routeId);
                    searchResults.style.display = 'none';
                    document.getElementById('search-input').value = '';
                    document.getElementById('clear-search').style.display = 'none';
                });
            });
        }

        searchResults.style.display = 'block';

    } catch (error) {
        console.error('Search failed:', error);
    }
}

/**
 * Show error message
 */
function showError(message) {
    // Simple error display - could be enhanced with a toast notification
    console.error(message);
    alert(message);
}
