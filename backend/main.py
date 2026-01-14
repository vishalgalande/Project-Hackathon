# FastAPI Backend for Tourism Geofencing App
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import sys
import os

# Add current directory to path for imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from features.tours import TourRoutes
from features.geofencing import GeofenceRoutes, LocationCheck

# ============================================================================
# APP INITIALIZATION
# ============================================================================

app = FastAPI(
    title="Tourism Geofencing API",
    description="Backend API for the Tourism Hackathon App with geofencing support",
    version="1.0.0"
)

# Enable CORS for Flutter app connectivity
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict this
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================================
# ROOT ENDPOINT
# ============================================================================

@app.get("/")
def read_root():
    """API health check and welcome message."""
    return {
        "message": "Welcome to Tourism Geofencing API",
        "status": "running",
        "endpoints": {
            "tours": "/tours",
            "geofence_zones": "/geofence/zones",
            "geofence_check": "/geofence/check (POST)"
        }
    }

# ============================================================================
# TOUR ENDPOINTS
# ============================================================================

@app.get("/tours")
def get_all_tours():
    """Get all available tours."""
    return TourRoutes.get_all_tours()

@app.get("/tours/{tour_id}")
def get_tour_details(tour_id: str):
    """Get details for a specific tour."""
    return TourRoutes.get_tour_details(tour_id)

# ============================================================================
# GEOFENCING ENDPOINTS
# ============================================================================

@app.get("/geofence/zones")
def get_all_zones():
    """Get all geofence zones (tourist points of interest)."""
    return {
        "zones": GeofenceRoutes.get_all_zones(),
        "total": len(GeofenceRoutes.get_all_zones())
    }

@app.get("/geofence/zones/{zone_id}")
def get_zone_by_id(zone_id: str):
    """Get a specific zone by ID."""
    zone = GeofenceRoutes.get_zone_by_id(zone_id)
    if zone is None:
        raise HTTPException(status_code=404, detail="Zone not found")
    return zone

@app.get("/geofence/zones/category/{category}")
def get_zones_by_category(category: str):
    """Get zones filtered by category (museum, park, monument, landmark)."""
    zones = GeofenceRoutes.get_zones_by_category(category)
    return {"zones": zones, "category": category, "total": len(zones)}

@app.post("/geofence/check")
def check_location(location: LocationCheck):
    """
    Check if the user's current location is inside any geofence zones.
    
    Request body:
    {
        "latitude": 37.4220,
        "longitude": -122.0840
    }
    
    Returns zones the user is currently inside and nearby zones.
    """
    return GeofenceRoutes.check_location(location.latitude, location.longitude)

# ============================================================================
# RUN SERVER (for development)
# ============================================================================

if __name__ == "__main__":
    import uvicorn
    print("Starting Tourism Geofencing API...")
    print("API Docs: http://localhost:8000/docs")
    print("Zones: http://localhost:8000/geofence/zones")
    uvicorn.run(app, host="0.0.0.0", port=8000)
