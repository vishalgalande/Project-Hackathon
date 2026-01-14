/**
 * API Communication Layer
 * Handles all backend API requests
 */

const API_BASE_URL = 'http://localhost:5000';

class API {
    constructor(baseURL = API_BASE_URL) {
        this.baseURL = baseURL;
        this.cache = new Map();
    }

    /**
     * Generic fetch wrapper with error handling
     */
    async request(endpoint, options = {}) {
        const url = `${this.baseURL}${endpoint}`;

        try {
            const response = await fetch(url, {
                ...options,
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers,
                },
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();

            if (!data.success) {
                throw new Error(data.error || 'API request failed');
            }

            return data;
        } catch (error) {
            console.error('API Request Error:', error);
            throw error;
        }
    }

    /**
     * Get all available regions/countries
     */
    async getRegions() {
        const cacheKey = 'regions';

        if (this.cache.has(cacheKey)) {
            return this.cache.get(cacheKey);
        }

        const data = await this.request('/api/regions');
        this.cache.set(cacheKey, data);
        return data;
    }

    /**
     * Get routes, optionally filtered by region
     */
    async getRoutes(filters = {}) {
        const params = new URLSearchParams();

        if (filters.country) {
            params.append('country', filters.country);
        }
        if (filters.city) {
            params.append('city', filters.city);
        }

        const endpoint = `/api/routes${params.toString() ? '?' + params.toString() : ''}`;
        return await this.request(endpoint);
    }

    /**
     * Search routes by query
     */
    async searchRoutes(query, country = null) {
        if (!query || query.trim().length === 0) {
            return { success: true, data: [], count: 0 };
        }

        const params = new URLSearchParams({ q: query });
        if (country) {
            params.append('country', country);
        }

        return await this.request(`/api/routes/search?${params.toString()}`);
    }

    /**
     * Get detailed information about a specific route
     */
    async getRouteDetails(routeId) {
        return await this.request(`/api/routes/${routeId}`);
    }

    /**
     * Get current vehicle positions for a route
     */
    async getVehiclePositions(routeId) {
        return await this.request(`/api/tracking/${routeId}`);
    }

    /**
     * Get updated vehicle positions (simulates real-time)
     */
    async getVehicleUpdates(routeId) {
        return await this.request(`/api/tracking/${routeId}/updates`);
    }

    /**
     * Get all active vehicles, optionally filtered by region
     */
    async getAllVehicles(filters = {}) {
        const params = new URLSearchParams();

        if (filters.country) {
            params.append('country', filters.country);
        }
        if (filters.city) {
            params.append('city', filters.city);
        }

        const endpoint = `/api/tracking/all${params.toString() ? '?' + params.toString() : ''}`;
        return await this.request(endpoint);
    }

    /**
     * Clear cache
     */
    clearCache() {
        this.cache.clear();
    }
}

// Create global API instance
const api = new API();
