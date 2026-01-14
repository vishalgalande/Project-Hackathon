"""
Tracking API - Real-time vehicle tracking endpoints
"""

from flask import Blueprint, jsonify, request
from features.mock_data_generator import mock_data

tracking_bp = Blueprint('tracking', __name__)

@tracking_bp.route('/api/tracking/<route_id>', methods=['GET'])
def get_vehicle_positions(route_id):
    """Get current positions of all vehicles on a route"""
    try:
        # Verify route exists
        route = mock_data.get_route_by_id(route_id)
        if not route:
            return jsonify({
                "success": False,
                "error": "Route not found"
            }), 404
        
        # Get vehicles for this route
        vehicles = mock_data.get_vehicles_by_route(route_id)
        
        return jsonify({
            "success": True,
            "route_id": route_id,
            "route_name": route["name"],
            "data": vehicles,
            "count": len(vehicles)
        }), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@tracking_bp.route('/api/tracking/<route_id>/updates', methods=['GET'])
def get_vehicle_updates(route_id):
    """Get updated vehicle positions (simulates real-time updates)"""
    try:
        # Verify route exists
        route = mock_data.get_route_by_id(route_id)
        if not route:
            return jsonify({
                "success": False,
                "error": "Route not found"
            }), 404
        
        # Update vehicle positions (simulate movement)
        mock_data.update_vehicle_positions()
        
        # Get updated vehicles for this route
        vehicles = mock_data.get_vehicles_by_route(route_id)
        
        return jsonify({
            "success": True,
            "route_id": route_id,
            "route_name": route["name"],
            "data": vehicles,
            "count": len(vehicles),
            "updated": True
        }), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@tracking_bp.route('/api/tracking/all', methods=['GET'])
def get_all_vehicles():
    """Get all active vehicles across all routes"""
    try:
        country_code = request.args.get('country')
        city = request.args.get('city')
        
        # Filter vehicles by region if specified
        vehicles = mock_data.vehicles
        
        if country_code or city:
            routes = mock_data.get_routes_by_region(country_code, city)
            route_ids = [r["id"] for r in routes]
            vehicles = [v for v in vehicles if v["route_id"] in route_ids]
        
        return jsonify({
            "success": True,
            "data": vehicles,
            "count": len(vehicles)
        }), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500
