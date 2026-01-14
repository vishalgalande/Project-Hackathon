import requests
import json

try:
    response = requests.get('http://localhost:5000/api/tracking/all')
    if response.status_code == 200:
        vehicles = response.json()
        print(f"Received type: {type(vehicles)}")
        if isinstance(vehicles, dict):
            print("Response is a dictionary, checking 'data' key or keys...")
            if 'data' in vehicles:
                 vehicles = vehicles['data']
            else:
                 # It might be keyed by ID
                 vehicles = list(vehicles.values())

        if isinstance(vehicles, list):
            if len(vehicles) > 0:
                print(f"First item type: {type(vehicles[0])}")
                if isinstance(vehicles[0], str):
                    print(f"First item is string: {vehicles[0]}")
                else:
                    print(json.dumps(vehicles[0], indent=2))
                    crowded = [v for v in vehicles if isinstance(v, dict) and (v.get('occupancy', 0) / v.get('capacity', 1)) > 0.7]
                    delayed = [v for v in vehicles if isinstance(v, dict) and 'Delayed' in v.get('status', '')]
                    print(f"Crowded Vehicles: {len(crowded)}")
                    print(f"Delayed Vehicles: {len(delayed)}")
        else:
            print("Response is not a list or dict")

    else:
        print(f"Failed to fetch: {response.status_code}")
except Exception as e:
    print(f"Error: {e}")
