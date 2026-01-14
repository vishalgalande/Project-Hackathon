"""
Geo-Fencing Zones Feature (Firestore-backed)
=============================================
Divides the map into chunks with zone classifications based on user voting.
Data is stored in Firebase Firestore.
"""

import os
import sys
from typing import Dict, List, Optional
from dataclasses import dataclass, field
from enum import Enum

# Add parent dir to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Try to import Firebase service
try:
    from services.firebase_service import firebase, FIREBASE_AVAILABLE
except ImportError:
    FIREBASE_AVAILABLE = False
    firebase = None


class ZoneColor(Enum):
    """Safety classification for a chunk"""
    RED = "red"       # Danger zone (score <= -5)
    YELLOW = "yellow" # Caution zone (-5 < score < 5)
    GREEN = "green"   # Safe zone (score >= 5)


def calculate_zone_color(score: int) -> str:
    """Calculate zone color based on vote score"""
    if score >= 5:
        return ZoneColor.GREEN.value
    elif score <= -5:
        return ZoneColor.RED.value
    else:
        return ZoneColor.YELLOW.value


# ============================================================
# DELHI MOCK DATA (fallback if Firestore is empty)
# ============================================================
DELHI_CENTER = {"lat": 28.6139, "lng": 77.2090}

MOCK_ZONES = [
    {"id": "delhi_001", "name": "Connaught Place", "lat_min": 28.6280, "lat_max": 28.6380, "lng_min": 77.2150, "lng_max": 77.2250, "score": 8},
    {"id": "delhi_002", "name": "India Gate", "lat_min": 28.6100, "lat_max": 28.6200, "lng_min": 77.2250, "lng_max": 77.2350, "score": 6},
    {"id": "delhi_003", "name": "Chandni Chowk", "lat_min": 28.6500, "lat_max": 28.6600, "lng_min": 77.2250, "lng_max": 77.2350, "score": 0},
    {"id": "delhi_004", "name": "Red Fort Area", "lat_min": 28.6550, "lat_max": 28.6650, "lng_min": 77.2350, "lng_max": 77.2450, "score": 4},
    {"id": "delhi_005", "name": "Old Delhi Railway Station", "lat_min": 28.6600, "lat_max": 28.6700, "lng_min": 77.2150, "lng_max": 77.2250, "score": -4},
    {"id": "delhi_006", "name": "Karol Bagh Market", "lat_min": 28.6500, "lat_max": 28.6600, "lng_min": 77.1850, "lng_max": 77.1950, "score": 1},
    {"id": "delhi_007", "name": "Lodhi Garden", "lat_min": 28.5900, "lat_max": 28.6000, "lng_min": 77.2150, "lng_max": 77.2250, "score": 7},
    {"id": "delhi_008", "name": "Hauz Khas Village", "lat_min": 28.5500, "lat_max": 28.5600, "lng_min": 77.1900, "lng_max": 77.2000, "score": 5},
    {"id": "delhi_009", "name": "Paharganj", "lat_min": 28.6400, "lat_max": 28.6500, "lng_min": 77.2050, "lng_max": 77.2150, "score": -4},
]


# ============================================================
# FIRESTORE-BACKED ZONE MANAGER
# ============================================================

class ZoneManager:
    """Manages zones in Firestore"""
    
    COLLECTION = "zones"
    VOTES_COLLECTION = "votes"
    
    @staticmethod
    def _zone_to_dict(zone: Dict) -> Dict:
        """Convert zone to API response format"""
        score = zone.get("score", 0)
        return {
            "id": zone.get("id"),
            "name": zone.get("name"),
            "bounds": {
                "lat_min": zone.get("lat_min"),
                "lat_max": zone.get("lat_max"),
                "lng_min": zone.get("lng_min"),
                "lng_max": zone.get("lng_max"),
            },
            "score": score,
            "zone_color": calculate_zone_color(score),
        }
    
    @staticmethod
    def get_all_zones() -> Dict:
        """Get all zones from Firestore (or mock data)"""
        zones = []
        
        # Try Firestore first
        if firebase and firebase.db:
            docs = firebase.get_collection(ZoneManager.COLLECTION)
            if docs:
                zones = [ZoneManager._zone_to_dict(doc) for doc in docs]
        
        # Fallback to mock data
        if not zones:
            zones = [ZoneManager._zone_to_dict(z) for z in MOCK_ZONES]
        
        return {
            "success": True,
            "count": len(zones),
            "zones": zones,
            "source": "firestore" if firebase and firebase.db else "mock"
        }
    
    @staticmethod
    def get_zone(zone_id: str) -> Dict:
        """Get a single zone"""
        # Try Firestore
        if firebase and firebase.db:
            doc = firebase.get_document(ZoneManager.COLLECTION, zone_id)
            if doc:
                return {"success": True, "zone": ZoneManager._zone_to_dict(doc)}
        
        # Fallback to mock
        for z in MOCK_ZONES:
            if z["id"] == zone_id:
                return {"success": True, "zone": ZoneManager._zone_to_dict(z)}
        
        return {"success": False, "error": "Zone not found"}
    
    @staticmethod
    def submit_vote(zone_id: str, user_id: str, vote: int) -> Dict:
        """
        Submit a vote for a zone.
        Args:
            zone_id: The zone to vote on
            user_id: Firebase Auth UID of the voter
            vote: +1 (safe) or -1 (danger)
        """
        if vote not in [-1, 1]:
            return {"success": False, "error": "Vote must be +1 or -1"}
        
        if not firebase or not firebase.db:
            return {"success": False, "error": "Database not connected"}
        
        # Get current zone
        zone_doc = firebase.get_document(ZoneManager.COLLECTION, zone_id)
        if not zone_doc:
            return {"success": False, "error": "Zone not found"}
        
        # Save the vote
        vote_data = {
            "zone_id": zone_id,
            "user_id": user_id,
            "vote": vote,
        }
        firebase.create_document(ZoneManager.VOTES_COLLECTION, vote_data)
        
        # Update zone score
        new_score = zone_doc.get("score", 0) + vote
        firebase.update_document(ZoneManager.COLLECTION, zone_id, {"score": new_score})
        
        return {
            "success": True,
            "message": f"Vote recorded for {zone_doc.get('name')}",
            "new_score": new_score,
            "new_zone_color": calculate_zone_color(new_score)
        }
    
    @staticmethod
    def get_zone_by_location(lat: float, lng: float) -> Dict:
        """Find zone at a specific location"""
        result = ZoneManager.get_all_zones()
        for zone in result.get("zones", []):
            bounds = zone.get("bounds", {})
            if (bounds.get("lat_min", 0) <= lat <= bounds.get("lat_max", 0) and
                bounds.get("lng_min", 0) <= lng <= bounds.get("lng_max", 0)):
                return {"success": True, "zone": zone}
        return {"success": False, "error": "No zone at this location"}


# Alias for backward compatibility
class ZoneRoutes:
    get_all_zones = ZoneManager.get_all_zones
    get_zone = ZoneManager.get_zone
    submit_vote = ZoneManager.submit_vote
    get_zone_by_location = ZoneManager.get_zone_by_location


# ============================================================
# TEST
# ============================================================
if __name__ == "__main__":
    print("=== Zones Feature Test ===\n")
    
    result = ZoneManager.get_all_zones()
    print(f"Source: {result.get('source')}")
    print(f"Total zones: {result['count']}")
    for zone in result['zones']:
        print(f"  {zone['name']}: {zone['zone_color'].upper()} (score: {zone['score']})")
