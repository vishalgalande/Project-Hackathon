import requests
import json

def get_osrm_route(start_coords, end_coords):
    # OSRM expects: lon,lat
    base_url = "http://router.project-osrm.org/route/v1/driving"
    coordinates = f"{start_coords[1]},{start_coords[0]};{end_coords[1]},{end_coords[0]}"
    url = f"{base_url}/{coordinates}?overview=full&geometries=geojson"
    
    print(f"Requesting: {url}")
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            data = response.json()
            if data['code'] == 'Ok':
                print("Success! Route found.")
                # print(json.dumps(data['routes'][0]['geometry'], indent=2))
                return True
            else:
                print(f"OSRM Error: {data['code']}")
        else:
            print(f"HTTP Error: {response.status_code}")
    except Exception as e:
        print(f"Connection Error: {e}")
    return False

# Test with coordinates in Mumbai (Churchgate to Dadar)
# Churchgate: 18.9322, 72.8264
# Dadar: 19.0178, 72.8478
get_osrm_route((18.9322, 72.8264), (19.0178, 72.8478))
