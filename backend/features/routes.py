"""
Routes API - Endpoints for managing and querying transport routes
"""

from flask import Blueprint, jsonify, request
from features.mock_data_generator import mock_data

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
        route = mock_data.get_route_by_id(route_id)
        
        if not route:
            return jsonify({
                "success": False,
                "error": "Route not found"
            }), 404
        
        return jsonify({
            "success": True,
            "data": route
        }), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500
