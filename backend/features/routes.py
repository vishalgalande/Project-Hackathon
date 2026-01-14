"""
Routes API - Endpoints for managing and querying transport routes
"""

from flask import Blueprint, jsonify, request
from features.mock_data_generator import mock_data
from features.gtfs_handler import gtfs_handler
from features.reporting import get_excluded_vehicles
import googlemaps
import os

routes_bp = Blueprint('routes', __name__)

@routes_bp.route('/api/regions', methods=['GET'])
def get_regions():
    """Get all available regions/countries"""
    try:
        regions = mock_data.get_all_regions()
        return jsonify({
            "success": True,
            "data": regions,
            "count": len(regions)
        }), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@routes_bp.route('/api/routes', methods=['GET'])
def get_routes():
    """Get routes, optionally filtered by region"""
    try:
        country_code = request.args.get('country')
        city = request.args.get('city')
        
        routes = mock_data.get_routes_by_region(country_code, city)
        
        return jsonify({
            "success": True,
            "data": routes,
            "count": len(routes),
            "filters": {
                "country": country_code,
                "city": city
            }
        }), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@routes_bp.route('/api/routes/search', methods=['GET'])
def search_routes():
    """Search routes by name, number, or city"""
    try:
        query = request.args.get('q', '')
        country_code = request.args.get('country')
        
        if not query:
            return jsonify({
                "success": False,
                "error": "Search query is required"
            }), 400
        
        results = mock_data.search_routes(query, country_code)
        
        return jsonify({
            "success": True,
            "data": results,
            "count": len(results),
            "query": query
        }), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@routes_bp.route('/api/routes/<route_id>', methods=['GET'])
def get_route_details(route_id):
    """Get detailed information about a specific route"""
    try:
        # Check if route is excluded/disrupted
        excluded_vehicles = get_excluded_vehicles()
        
        # Get base route data
        route = mock_data.get_route_by_id(route_id)
        
        if not route:
            return jsonify({
                "success": False,
                "error": "Route not found"
            }), 404

        # If we have a Google Maps Key, try to get real Directions
        api_key = os.environ.get('GOOGLE_MAPS_API_KEY')
        if api_key:
            try:
                gmaps = googlemaps.Client(key=api_key)
                # Parse origin/dest from route stops (mock data usually has stops)
                if route.get('stops') and len(route['stops']) >= 2:
                    origin = f"{route['stops'][0]['lat']},{route['stops'][0]['lng']}"
                    dest = f"{route['stops'][-1]['lat']},{route['stops'][-1]['lng']}"
                    
                    # Request directions
                    # If there are reports on this route's vehicles, we might want to avoid them
                    # But Google API 'avoid' is for tools/highways. 
                    # We can't strictly avoid a specific bus ID via Directions API.
                    # We simply return the standard route, but frontend will show alerts.
                    
                    directions = gmaps.directions(origin, dest, mode='transit')
                    if directions:
                        route['google_directions'] = directions[0]
            except Exception as g_err:
                print(f"Google Maps API Error: {g_err}")

        # Check for active alerts on this route's vehicles
        # This is a bit indirect since we map vehicles to routes manually in mock data
        vehicles = mock_data.get_vehicles_by_route(route_id)
        alerts = []
        for v in vehicles:
            if v['id'] in excluded_vehicles:
                alerts.append({
                    'vehicle_id': v['id'],
                    'message': 'Vehicle reported with issues. Re-routing suggested.'
                })
        
        route['alerts'] = alerts
        
        return jsonify({
            "success": True,
            "data": route
        }), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500
