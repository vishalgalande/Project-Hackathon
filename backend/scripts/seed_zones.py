"""
Seed Zones to Firestore
=======================
Run this script ONCE to populate Firestore with Delhi zones.

Usage:
    python backend/scripts/seed_zones.py
"""

import os
import sys

# Add paths for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from services.firebase_service import firebase

# Delhi zones data
DELHI_ZONES = [
    {
        "id": "delhi_001",
        "name": "Connaught Place",
        "lat_min": 28.6280, "lat_max": 28.6380,
        "lng_min": 77.2150, "lng_max": 77.2250,
        "score": 8,
        "description": "Central business district, very safe tourist hub"
    },
    {
        "id": "delhi_002",
        "name": "India Gate",
        "lat_min": 28.6100, "lat_max": 28.6200,
        "lng_min": 77.2250, "lng_max": 77.2350,
        "score": 6,
        "description": "Famous war memorial, popular tourist spot"
    },
    {
        "id": "delhi_003",
        "name": "Chandni Chowk",
        "lat_min": 28.6500, "lat_max": 28.6600,
        "lng_min": 77.2250, "lng_max": 77.2350,
        "score": 0,
        "description": "Historic market, very crowded"
    },
    {
        "id": "delhi_004",
        "name": "Red Fort Area",
        "lat_min": 28.6550, "lat_max": 28.6650,
        "lng_min": 77.2350, "lng_max": 77.2450,
        "score": 4,
        "description": "UNESCO World Heritage Site"
    },
    {
        "id": "delhi_005",
        "name": "Old Delhi Railway Station",
        "lat_min": 28.6600, "lat_max": 28.6700,
        "lng_min": 77.2150, "lng_max": 77.2250,
        "score": -4,
        "description": "Very crowded and chaotic"
    },
    {
        "id": "delhi_006",
        "name": "Karol Bagh Market",
        "lat_min": 28.6500, "lat_max": 28.6600,
        "lng_min": 77.1850, "lng_max": 77.1950,
        "score": 1,
        "description": "Popular shopping area"
    },
    {
        "id": "delhi_007",
        "name": "Lodhi Garden",
        "lat_min": 28.5900, "lat_max": 28.6000,
        "lng_min": 77.2150, "lng_max": 77.2250,
        "score": 7,
        "description": "Beautiful park, very safe"
    },
    {
        "id": "delhi_008",
        "name": "Hauz Khas Village",
        "lat_min": 28.5500, "lat_max": 28.5600,
        "lng_min": 77.1900, "lng_max": 77.2000,
        "score": 5,
        "description": "Trendy area with cafes and boutiques"
    },
    {
        "id": "delhi_009",
        "name": "Paharganj",
        "lat_min": 28.6400, "lat_max": 28.6500,
        "lng_min": 77.2050, "lng_max": 77.2150,
        "score": -4,
        "description": "Backpacker area, watch for scams"
    },
]


def seed_zones():
    """Upload all zones to Firestore"""
    if not firebase or not firebase.db:
        print("ERROR: Firebase not connected!")
        print("Make sure firebase/service_account.json exists")
        return False
    
    print("Seeding Delhi zones to Firestore...\n")
    
    for zone in DELHI_ZONES:
        zone_id = zone["id"]
        print(f"  Creating: {zone['name']}...", end=" ")
        
        try:
            firebase.create_document("zones", zone, doc_id=zone_id)
            print("✓")
        except Exception as e:
            print(f"✗ Error: {e}")
    
    print(f"\nDone! {len(DELHI_ZONES)} zones created.")
    return True


if __name__ == "__main__":
    seed_zones()
