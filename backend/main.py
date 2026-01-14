"""
Main Flask Application for Public Transport Tracking System
"""

from flask import Flask, jsonify
from flask_cors import CORS
import sys
import os

# Add current directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Import feature blueprints
from features.routes import routes_bp
from features.tracking import tracking_bp

# Create Flask app
app = Flask(__name__)

# Enable CORS for frontend communication
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Register blueprints
app.register_blueprint(routes_bp)
app.register_blueprint(tracking_bp)

@app.route('/')
def home():
    """API home endpoint"""
    return jsonify({
        "name": "Public Transport Tracking API",
        "version": "1.0.0",
        "endpoints": {
            "regions": "/api/regions",
            "routes": "/api/routes",
            "search": "/api/routes/search?q=<query>",
            "route_details": "/api/routes/<route_id>",
            "tracking": "/api/tracking/<route_id>",
            "tracking_updates": "/api/tracking/<route_id>/updates",
            "all_vehicles": "/api/tracking/all"
        }
    })

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "transport-tracking-api"
    }), 200

if __name__ == '__main__':
    print("Starting Public Transport Tracking API...")
    print("Server running on http://localhost:5000")
    print("CORS enabled for all origins")
    app.run(debug=True, host='0.0.0.0', port=5000)

