# Backend Geofencing API
# Provides geofence zone management and location checking

from typing import List, Optional
from pydantic import BaseModel
import math

# ============================================================================
# DATA MODELS
# ============================================================================

class GeofenceZone(BaseModel):
    """A circular geofence zone centered on a point of interest."""
    id: str
    name: str
    description: str
    latitude: float
    longitude: float
    radius_meters: float
    category: str  # e.g., "monument", "park", "museum"

class LocationCheck(BaseModel):
    """User's current location for checking against geofences."""
    latitude: float
    longitude: float

class ZoneStatus(BaseModel):
    """Result of checking if user is inside a zone."""
    zone_id: str
    zone_name: str
    is_inside: bool
    distance_meters: float
    description: str

# ============================================================================
# MOCK GEOFENCE DATA (Famous Tourist Spots - Demo Locations)
# ============================================================================

# Using coordinates near San Francisco for easy emulator testing
# Android Emulator default location: 37.4220, -122.0840 (Googleplex)
MOCK_GEOFENCE_ZONES: List[GeofenceZone] = [
    GeofenceZone(
        id="zone_1",
        name="Tech Museum",
        description="Interactive technology exhibits and hands-on experiences. Perfect for tech enthusiasts!",
        latitude=37.4220,
        longitude=-122.0840,
        radius_meters=200,
        category="museum"
    ),
    GeofenceZone(
        id="zone_2", 
        name="Central Park",
        description="Beautiful urban park with walking trails, picnic areas, and stunning views.",
        latitude=37.4250,
        longitude=-122.0800,
        radius_meters=300,
        category="park"
    ),
    GeofenceZone(
        id="zone_3",
        name="Historic Monument",
        description="A landmark commemorating the city's rich history. Great photo opportunity!",
        latitude=37.4190,
        longitude=-122.0870,
        radius_meters=150,
        category="monument"
    ),
    GeofenceZone(
        id="zone_4",
        name="Art Gallery",
        description="Contemporary art gallery featuring local and international artists.",
        latitude=37.4280,
        longitude=-122.0820,
        radius_meters=100,
        category="museum"
    ),
    GeofenceZone(
        id="zone_5",
        name="Waterfront Plaza",
        description="Scenic waterfront area with restaurants, shops, and live entertainment.",
        latitude=37.4200,
        longitude=-122.0900,
        radius_meters=250,
        category="landmark"
    ),
]

# ============================================================================
# GEOFENCE UTILITY FUNCTIONS
# ============================================================================

def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate the great-circle distance between two points on Earth.
    Returns distance in meters.
    """
    R = 6371000  # Earth's radius in meters
    
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)
    
    a = (math.sin(delta_phi / 2) ** 2 + 
         math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    return R * c

def check_point_in_zone(lat: float, lon: float, zone: GeofenceZone) -> ZoneStatus:
    """Check if a point is inside a geofence zone."""
    distance = haversine_distance(lat, lon, zone.latitude, zone.longitude)
    is_inside = distance <= zone.radius_meters
    
    return ZoneStatus(
        zone_id=zone.id,
        zone_name=zone.name,
        is_inside=is_inside,
        distance_meters=round(distance, 2),
        description=zone.description
    )

# ============================================================================
# API ROUTE HANDLERS
# ============================================================================

class GeofenceRoutes:
    """API route handlers for geofencing endpoints."""
    
    @staticmethod
    def get_all_zones() -> List[dict]:
        """Return all available geofence zones."""
        return [zone.model_dump() for zone in MOCK_GEOFENCE_ZONES]
    
    @staticmethod
    def get_zone_by_id(zone_id: str) -> Optional[dict]:
        """Return a specific zone by ID."""
        for zone in MOCK_GEOFENCE_ZONES:
            if zone.id == zone_id:
                return zone.model_dump()
        return None
    
    @staticmethod
    def check_location(latitude: float, longitude: float) -> dict:
        """
        Check user location against all geofence zones.
        Returns zones user is inside and nearby zones.
        """
        results = {
            "current_location": {"latitude": latitude, "longitude": longitude},
            "inside_zones": [],
            "nearby_zones": [],  # Within 500m but outside the zone
            "timestamp": "now"
        }
        
        for zone in MOCK_GEOFENCE_ZONES:
            status = check_point_in_zone(latitude, longitude, zone)
            
            if status.is_inside:
                results["inside_zones"].append(status.model_dump())
            elif status.distance_meters <= 500:  # Nearby threshold
                results["nearby_zones"].append(status.model_dump())
        
        return results
    
    @staticmethod
    def get_zones_by_category(category: str) -> List[dict]:
        """Return zones filtered by category."""
        return [
            zone.model_dump() 
            for zone in MOCK_GEOFENCE_ZONES 
            if zone.category.lower() == category.lower()
        ]
