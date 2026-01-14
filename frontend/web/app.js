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
    showVehicles: true
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
    // Initialize map
    initializeMap();

    // Load regions
    await loadRegions();

    // Setup event listeners
    setupEventListeners();

    // Load initial routes
    await loadRoutes();

    // Hide loading screen
    setTimeout(() => {
        document.getElementById('loading-screen').classList.add('hidden');
    }, 1000);
}

/**
 * Initialize Leaflet map
 */
function initializeMap() {
    // Create map centered on world view
    state.map = L.map('map', {
        zoomControl: false
    }).setView([20, 0], 2);

    // Add tile layer (OpenStreetMap)
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors',
        maxZoom: 19,
        minZoom: 2
    }).addTo(state.map);

    // Add zoom control to bottom right
    L.control.zoom({
        position: 'bottomright'
    }).addTo(state.map);
}

/**
 * Load and populate regions dropdown
 */
async function loadRegions() {
    try {
        const response = await api.getRegions();
        const regions = response.data;

        const select = document.getElementById('region-select');

        // Sort regions by name
        regions.sort((a, b) => a.name.localeCompare(b.name));

        // Populate dropdown
        regions.forEach(region => {
            const option = document.createElement('option');
            option.value = region.code;
            option.textContent = `${region.name}`;
            select.appendChild(option);
        });
    } catch (error) {
        console.error('Failed to load regions:', error);
    }
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
        state.vehicles = response.data;

        // Display vehicles on map
        displayVehicles();

        // Update stats
        updateStats();
    } catch (error) {
        console.error('Failed to load vehicles:', error);
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

    // Create custom icon for vehicles
    const vehicleIcon = (type) => {
        const colors = {
            'Bus': '#667eea',
            'Metro': '#f5576c',
            'Tram': '#4ade80',
            'Light Rail': '#fbbf24'
        };

        return L.divIcon({
            className: 'vehicle-marker',
            html: `<div style="
                width: 24px;
                height: 24px;
                background: ${colors[type] || '#667eea'};
                border: 3px solid white;
                border-radius: 50%;
                box-shadow: 0 2px 8px rgba(0,0,0,0.3);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 12px;
            ">🚌</div>`,
            iconSize: [24, 24],
            iconAnchor: [12, 12]
        });
    };

    // Add markers for each vehicle
    state.vehicles.forEach(vehicle => {
        const marker = L.marker(
            [vehicle.position.lat, vehicle.position.lng],
            { icon: vehicleIcon(vehicle.type) }
        ).addTo(state.map);

        // Add popup with enhanced info
        const nextStops = vehicle.next_stops || [];
        const nextStopText = nextStops.length >= 2
            ? `${nextStops[0].name} (${nextStops[0].eta} min) → ${nextStops[1].name} (${nextStops[1].eta} min)`
            : vehicle.next_stop || 'Terminal';

        marker.bindPopup(`
            <div style="font-family: Inter, sans-serif; min-width: 200px;">
                <div style="font-weight: 700; font-size: 14px; margin-bottom: 8px; color: #667eea;">
                    ${vehicle.route_number || 'Route'}
                </div>
                <div style="font-weight: 600; margin-bottom: 6px;">${vehicle.route_name}</div>
                <div style="font-size: 12px; color: #666; line-height: 1.6;">
                    <div><strong>Speed:</strong> ${vehicle.speed} km/h</div>
                    <div><strong>Status:</strong> ${vehicle.status || 'On Time'}</div>
                    <div><strong>Next Stops:</strong><br>${nextStopText}</div>
                    <div><strong>Occupancy:</strong> ${vehicle.occupancy}/${vehicle.capacity} (${Math.round((vehicle.occupancy / vehicle.capacity) * 100)}%)</div>
                </div>
            </div>
        `);

        // Click to view route details
        marker.on('click', () => {
            loadRouteDetails(vehicle.route_id);
        });

        state.markers.vehicles.push(marker);
    });
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
    document.getElementById('active-routes').textContent = state.routes.length;
    document.getElementById('active-vehicles').textContent = state.vehicles.length;
}

/**
 * Setup event listeners
 */
function setupEventListeners() {
    // Region selector
    document.getElementById('region-select').addEventListener('change', async (e) => {
        const region = e.target.value;
        state.selectedRegion = region;

        // Clear selected route
        state.selectedRoute = null;
        clearInterval(state.updateInterval);

        // Clear route markers
        state.markers.routes.forEach(marker => marker.remove());
        state.markers.routes = [];

        // Load routes for selected region
        const filters = region ? { country: region } : {};
        await loadRoutes(filters);

        // Center map on region if selected
        if (region && state.routes.length > 0) {
            const firstRoute = state.routes[0];
            if (firstRoute.stops && firstRoute.stops.length > 0) {
                state.map.setView([firstRoute.stops[0].lat, firstRoute.stops[0].lng], 10);
            }
        } else {
            state.map.setView([20, 0], 2);
        }
    });

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

    // Close panel button
    document.getElementById('close-panel').addEventListener('click', () => {
        // Clear selected route
        state.selectedRoute = null;
        clearInterval(state.updateInterval);

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
