"""
Geo-Fencing Zones Feature
=========================
Divides the map into chunks (grid cells) with zone classifications
(Red/Yellow/Green) based on user voting.

API Endpoints:
- GET  /zones          -> All chunks with current zone colors
- GET  /zones/{id}     -> Single chunk details
- POST /zones/{id}/vote -> Submit a vote (+1 safe, -1 danger)
"""

from typing import Dict, List, Optional
from dataclasses import dataclass, field
from enum import Enum


class ZoneColor(Enum):
    """Safety classification for a chunk"""
    RED = "red"       # Danger zone (score <= -5)
    YELLOW = "yellow" # Caution zone (-5 < score < 5)
    GREEN = "green"   # Safe zone (score >= 5)


@dataclass
class Chunk:
    """A rectangular area on the map"""
    id: str
    name: str
    # Bounding box coordinates
    lat_min: float
    lat_max: float
    lng_min: float
    lng_max: float
    # Voting data
    votes: List[int] = field(default_factory=list)
    
    @property
    def score(self) -> int:
        """Sum of all votes"""
        return sum(self.votes)
    
    @property
    def zone_color(self) -> ZoneColor:
        """Calculate zone based on vote score"""
        if self.score >= 5:
            return ZoneColor.GREEN
        elif self.score <= -5:
            return ZoneColor.RED
        else:
            return ZoneColor.YELLOW
    
    def to_dict(self) -> Dict:
        """Convert to JSON-serializable dict for Flutter frontend"""
        return {
            "id": self.id,
            "name": self.name,
            "bounds": {
                "lat_min": self.lat_min,
                "lat_max": self.lat_max,
                "lng_min": self.lng_min,
                "lng_max": self.lng_max,
            },
            "score": self.score,
            "zone_color": self.zone_color.value,
            "vote_count": len(self.votes)
        }


# ============================================================
# DELHI MAP DATA - Real tourist locations
# ============================================================
# Delhi bounds: roughly 28.4°N - 28.8°N, 76.8°E - 77.4°E
# Each chunk is ~0.01° x 0.01° (~1km x 1km)

DELHI_CENTER = {"lat": 28.6139, "lng": 77.2090}  # For Flutter map centering

MOCK_CHUNKS: Dict[str, Chunk] = {
    "delhi_001": Chunk(
        id="delhi_001",
        name="Connaught Place",
        lat_min=28.6280, lat_max=28.6380,
        lng_min=77.2150, lng_max=77.2250,
        votes=[1, 1, 1, 1, 1, 1, 1, 1]  # Very Safe - Green (tourist hub)
    ),
    "delhi_002": Chunk(
        id="delhi_002",
        name="India Gate",
        lat_min=28.6100, lat_max=28.6200,
        lng_min=77.2250, lng_max=77.2350,
        votes=[1, 1, 1, 1, 1, 1]  # Safe - Green (landmark)
    ),
    "delhi_003": Chunk(
        id="delhi_003",
        name="Chandni Chowk",
        lat_min=28.6500, lat_max=28.6600,
        lng_min=77.2250, lng_max=77.2350,
        votes=[1, -1, 1, -1, 1, -1]  # Busy/Crowded - Yellow
    ),
    "delhi_004": Chunk(
        id="delhi_004",
        name="Red Fort Area",
        lat_min=28.6550, lat_max=28.6650,
        lng_min=77.2350, lng_max=77.2450,
        votes=[1, 1, 1, 1]  # Leaning Safe - Yellow
    ),
    "delhi_005": Chunk(
        id="delhi_005",
        name="Old Delhi Railway Station",
        lat_min=28.6600, lat_max=28.6700,
        lng_min=77.2150, lng_max=77.2250,
        votes=[-1, -1, -1, 1, -1, -1]  # Crowded/Chaotic - Red
    ),
    "delhi_006": Chunk(
        id="delhi_006",
        name="Karol Bagh Market",
        lat_min=28.6500, lat_max=28.6600,
        lng_min=77.1850, lng_max=77.1950,
        votes=[1, -1, 1, 0]  # Mixed - Yellow
    ),
    "delhi_007": Chunk(
        id="delhi_007",
        name="Lodhi Garden",
        lat_min=28.5900, lat_max=28.6000,
        lng_min=77.2150, lng_max=77.2250,
        votes=[1, 1, 1, 1, 1, 1, 1]  # Very Safe - Green (park)
    ),
    "delhi_008": Chunk(
        id="delhi_008",
        name="Hauz Khas Village",
        lat_min=28.5500, lat_max=28.5600,
        lng_min=77.1900, lng_max=77.2000,
        votes=[1, 1, 1, 1, 1]  # Safe - Green (trendy area)
    ),
    "delhi_009": Chunk(
        id="delhi_009",
        name="Paharganj",
        lat_min=28.6400, lat_max=28.6500,
        lng_min=77.2050, lng_max=77.2150,
        votes=[-1, -1, -1, -1, -1, 1]  # Risky - Red (backpacker area, scams)
    ),
}


# ============================================================
# API HANDLERS (to be wired to Flask/FastAPI routes)
# ============================================================

class ZoneRoutes:
    """API handlers for geo-fencing zones"""
    
    @staticmethod
    def get_all_zones() -> Dict:
        """
        GET /zones
        Returns all chunks with their current zone colors
        """
        zones = [chunk.to_dict() for chunk in MOCK_CHUNKS.values()]
        return {
            "success": True,
            "count": len(zones),
            "zones": zones
        }
    
    @staticmethod
    def get_zone(chunk_id: str) -> Dict:
        """
        GET /zones/{chunk_id}
        Returns details for a single chunk
        """
        chunk = MOCK_CHUNKS.get(chunk_id)
        if not chunk:
            return {"success": False, "error": "Chunk not found"}
        return {
            "success": True,
            "zone": chunk.to_dict()
        }
    
    @staticmethod
    def submit_vote(chunk_id: str, vote: int) -> Dict:
        """
        POST /zones/{chunk_id}/vote
        Submit a vote: +1 for safe, -1 for danger
        
        Args:
            chunk_id: The ID of the chunk to vote on
            vote: +1 (safe) or -1 (danger)
        """
        if vote not in [-1, 1]:
            return {"success": False, "error": "Vote must be +1 or -1"}
        
        chunk = MOCK_CHUNKS.get(chunk_id)
        if not chunk:
            return {"success": False, "error": "Chunk not found"}
        
        chunk.votes.append(vote)
        
        return {
            "success": True,
            "message": f"Vote recorded for {chunk.name}",
            "new_score": chunk.score,
            "new_zone_color": chunk.zone_color.value
        }
    
    @staticmethod
    def get_zone_by_location(lat: float, lng: float) -> Dict:
        """
        GET /zones/location?lat=X&lng=Y
        Find which chunk contains a given coordinate
        """
        for chunk in MOCK_CHUNKS.values():
            if (chunk.lat_min <= lat <= chunk.lat_max and
                chunk.lng_min <= lng <= chunk.lng_max):
                return {
                    "success": True,
                    "zone": chunk.to_dict()
                }
        return {
            "success": False,
            "error": "No zone found at this location"
        }


# ============================================================
# TEST / DEMO
# ============================================================
if __name__ == "__main__":
    print("=== Geo-Fencing Zones Demo ===\n")
    
    # Test: Get all zones
    all_zones = ZoneRoutes.get_all_zones()
    print(f"Total zones: {all_zones['count']}")
    for zone in all_zones['zones']:
        print(f"  {zone['name']}: {zone['zone_color'].upper()} (score: {zone['score']})")
    
    print("\n--- Submitting a danger vote to Beach Area ---")
    result = ZoneRoutes.submit_vote("chunk_001", -1)
    print(f"Result: {result}")
    
    print("\n--- Updated zones ---")
    all_zones = ZoneRoutes.get_all_zones()
    for zone in all_zones['zones']:
        print(f"  {zone['name']}: {zone['zone_color'].upper()} (score: {zone['score']})")
