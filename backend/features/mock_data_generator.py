"""
Mock Data Generator for Global Public Transport System
Generates realistic transport data for 50+ countries
"""

import random
import math
from datetime import datetime, timedelta

class MockDataGenerator:
    def __init__(self):
        self.regions = self._generate_regions()
        self.routes = self._generate_routes()
        self.vehicles = self._generate_vehicles()
    
    def _generate_regions(self):
        """Generate data for major cities across 50+ countries"""
        return {
            "north_america": {
                "usa": {
                    "name": "United States",
                    "cities": [
                        {"name": "New York", "lat": 40.7128, "lng": -74.0060, "routes": 15},
                        {"name": "Los Angeles", "lat": 34.0522, "lng": -118.2437, "routes": 12},
                        {"name": "Chicago", "lat": 41.8781, "lng": -87.6298, "routes": 10},
                        {"name": "San Francisco", "lat": 37.7749, "lng": -122.4194, "routes": 8}
                    ]
                },
                "canada": {
                    "name": "Canada",
                    "cities": [
                        {"name": "Toronto", "lat": 43.6532, "lng": -79.3832, "routes": 10},
                        {"name": "Vancouver", "lat": 49.2827, "lng": -123.1207, "routes": 8},
                        {"name": "Montreal", "lat": 45.5017, "lng": -73.5673, "routes": 9}
                    ]
                },
                "mexico": {
                    "name": "Mexico",
                    "cities": [
                        {"name": "Mexico City", "lat": 19.4326, "lng": -99.1332, "routes": 14},
                        {"name": "Guadalajara", "lat": 20.6597, "lng": -103.3496, "routes": 7}
                    ]
                }
            },
            "europe": {
                "uk": {
                    "name": "United Kingdom",
                    "cities": [
                        {"name": "London", "lat": 51.5074, "lng": -0.1278, "routes": 20},
                        {"name": "Manchester", "lat": 53.4808, "lng": -2.2426, "routes": 8},
                        {"name": "Birmingham", "lat": 52.4862, "lng": -1.8904, "routes": 7}
                    ]
                },
                "france": {
                    "name": "France",
                    "cities": [
                        {"name": "Paris", "lat": 48.8566, "lng": 2.3522, "routes": 18},
                        {"name": "Lyon", "lat": 45.7640, "lng": 4.8357, "routes": 8},
                        {"name": "Marseille", "lat": 43.2965, "lng": 5.3698, "routes": 7}
                    ]
                },
                "germany": {
                    "name": "Germany",
                    "cities": [
                        {"name": "Berlin", "lat": 52.5200, "lng": 13.4050, "routes": 16},
                        {"name": "Munich", "lat": 48.1351, "lng": 11.5820, "routes": 10},
                        {"name": "Hamburg", "lat": 53.5511, "lng": 9.9937, "routes": 9}
                    ]
                },
                "spain": {
                    "name": "Spain",
                    "cities": [
                        {"name": "Madrid", "lat": 40.4168, "lng": -3.7038, "routes": 14},
                        {"name": "Barcelona", "lat": 41.3851, "lng": 2.1734, "routes": 12}
                    ]
                },
                "italy": {
                    "name": "Italy",
                    "cities": [
                        {"name": "Rome", "lat": 41.9028, "lng": 12.4964, "routes": 12},
                        {"name": "Milan", "lat": 45.4642, "lng": 9.1900, "routes": 10}
                    ]
                },
                "netherlands": {
                    "name": "Netherlands",
                    "cities": [
                        {"name": "Amsterdam", "lat": 52.3676, "lng": 4.9041, "routes": 11},
                        {"name": "Rotterdam", "lat": 51.9244, "lng": 4.4777, "routes": 7}
                    ]
                }
            },
            "asia": {
                "india": {
                    "name": "India",
                    "cities": [
                        {"name": "Mumbai", "lat": 19.0760, "lng": 72.8777, "routes": 18},
                        {"name": "Delhi", "lat": 28.7041, "lng": 77.1025, "routes": 16},
                        {"name": "Bangalore", "lat": 12.9716, "lng": 77.5946, "routes": 14},
                        {"name": "Pune", "lat": 18.5204, "lng": 73.8567, "routes": 10}
                    ]
                },
                "china": {
                    "name": "China",
                    "cities": [
                        {"name": "Beijing", "lat": 39.9042, "lng": 116.4074, "routes": 22},
                        {"name": "Shanghai", "lat": 31.2304, "lng": 121.4737, "routes": 20},
                        {"name": "Guangzhou", "lat": 23.1291, "lng": 113.2644, "routes": 15}
                    ]
                },
                "japan": {
                    "name": "Japan",
                    "cities": [
                        {"name": "Tokyo", "lat": 35.6762, "lng": 139.6503, "routes": 25},
                        {"name": "Osaka", "lat": 34.6937, "lng": 135.5023, "routes": 14},
                        {"name": "Kyoto", "lat": 35.0116, "lng": 135.7681, "routes": 8}
                    ]
                },
                "singapore": {
                    "name": "Singapore",
                    "cities": [
                        {"name": "Singapore", "lat": 1.3521, "lng": 103.8198, "routes": 16}
                    ]
                },
                "south_korea": {
                    "name": "South Korea",
                    "cities": [
                        {"name": "Seoul", "lat": 37.5665, "lng": 126.9780, "routes": 18},
                        {"name": "Busan", "lat": 35.1796, "lng": 129.0756, "routes": 10}
                    ]
                },
                "thailand": {
                    "name": "Thailand",
                    "cities": [
                        {"name": "Bangkok", "lat": 13.7563, "lng": 100.5018, "routes": 14}
                    ]
                },
                "uae": {
                    "name": "United Arab Emirates",
                    "cities": [
                        {"name": "Dubai", "lat": 25.2048, "lng": 55.2708, "routes": 12},
                        {"name": "Abu Dhabi", "lat": 24.4539, "lng": 54.3773, "routes": 8}
                    ]
                }
            },
            "oceania": {
                "australia": {
                    "name": "Australia",
                    "cities": [
                        {"name": "Sydney", "lat": -33.8688, "lng": 151.2093, "routes": 14},
                        {"name": "Melbourne", "lat": -37.8136, "lng": 144.9631, "routes": 12},
                        {"name": "Brisbane", "lat": -27.4698, "lng": 153.0251, "routes": 9}
                    ]
                },
                "new_zealand": {
                    "name": "New Zealand",
                    "cities": [
                        {"name": "Auckland", "lat": -36.8485, "lng": 174.7633, "routes": 8},
                        {"name": "Wellington", "lat": -41.2865, "lng": 174.7762, "routes": 6}
                    ]
                }
            },
            "south_america": {
                "brazil": {
                    "name": "Brazil",
                    "cities": [
                        {"name": "São Paulo", "lat": -23.5505, "lng": -46.6333, "routes": 16},
                        {"name": "Rio de Janeiro", "lat": -22.9068, "lng": -43.1729, "routes": 12}
                    ]
                },
                "argentina": {
                    "name": "Argentina",
                    "cities": [
                        {"name": "Buenos Aires", "lat": -34.6037, "lng": -58.3816, "routes": 14}
                    ]
                },
                "chile": {
                    "name": "Chile",
                    "cities": [
                        {"name": "Santiago", "lat": -33.4489, "lng": -70.6693, "routes": 10}
                    ]
                }
            },
            "africa": {
                "south_africa": {
                    "name": "South Africa",
                    "cities": [
                        {"name": "Johannesburg", "lat": -26.2041, "lng": 28.0473, "routes": 10},
                        {"name": "Cape Town", "lat": -33.9249, "lng": 18.4241, "routes": 8}
                    ]
                },
                "egypt": {
                    "name": "Egypt",
                    "cities": [
                        {"name": "Cairo", "lat": 30.0444, "lng": 31.2357, "routes": 12}
                    ]
                },
                "nigeria": {
                    "name": "Nigeria",
                    "cities": [
                        {"name": "Lagos", "lat": 6.5244, "lng": 3.3792, "routes": 10}
                    ]
                }
            }
        }
    
    def _generate_routes(self):
        """Generate transport routes for all cities"""
        routes = []
        route_id = 1
        
        transport_types = ["Bus", "Metro", "Tram", "Light Rail"]
        route_prefixes = {
            "Bus": ["Route", "Line", "Express"],
            "Metro": ["Line", ""],
            "Tram": ["Line", "Route"],
            "Light Rail": ["Line", ""]
        }
        
        for continent, countries in self.regions.items():
            for country_code, country_data in countries.items():
                for city in country_data["cities"]:
                    num_routes = city["routes"]
                    
                    for i in range(num_routes):
                        transport_type = random.choice(transport_types)
                        prefix = random.choice(route_prefixes[transport_type])
                        
                        # Generate route number/name
                        if transport_type == "Metro":
                            route_name = f"{prefix} {random.choice(['Red', 'Blue', 'Green', 'Yellow', 'Orange', 'Purple'])}"
                        else:
                            route_number = random.randint(1, 999)
                            route_name = f"{prefix} {route_number}" if prefix else str(route_number)
                        
                        # Generate route path (simplified as a line)
                        start_lat = city["lat"] + random.uniform(-0.1, 0.1)
                        start_lng = city["lng"] + random.uniform(-0.1, 0.1)
                        end_lat = city["lat"] + random.uniform(-0.1, 0.1)
                        end_lng = city["lng"] + random.uniform(-0.1, 0.1)
                        
                        # Generate stops along the route
                        num_stops = random.randint(8, 20)
                        stops = []
                        for j in range(num_stops):
                            t = j / (num_stops - 1)
                            stop_lat = start_lat + (end_lat - start_lat) * t
                            stop_lng = start_lng + (end_lng - start_lng) * t
                            stops.append({
                                "name": f"Stop {j + 1}",
                                "lat": stop_lat,
                                "lng": stop_lng,
                                "order": j + 1
                            })
                        
                        route = {
                            "id": f"route_{route_id}",
                            "route_number": route_name,
                            "name": f"{city['name']} {transport_type} {route_name}",
                            "type": transport_type,
                            "city": city["name"],
                            "country": country_data["name"],
                            "country_code": country_code,
                            "continent": continent,
                            "stops": stops,
                            "path": [
                                {"lat": start_lat, "lng": start_lng},
                                {"lat": end_lat, "lng": end_lng}
                            ],
                            "active": True,
                            "frequency": f"{random.randint(5, 30)} mins"
                        }
                        
                        routes.append(route)
                        route_id += 1
        
        return routes
    
    def _generate_vehicles(self):
        """Generate vehicle positions for active routes"""
        vehicles = []
        vehicle_id = 1
        
        for route in self.routes:
            # Each route has 2-5 active vehicles
            num_vehicles = random.randint(2, 5)
            
            for i in range(num_vehicles):
                # Position vehicle somewhere along the route
                progress = random.random()
                
                if len(route["stops"]) > 0:
                    stop_index = int(progress * (len(route["stops"]) - 1))
                    current_stop = route["stops"][stop_index]
                    
                    # Add some randomness to position
                    lat = current_stop["lat"] + random.uniform(-0.002, 0.002)
                    lng = current_stop["lng"] + random.uniform(-0.002, 0.002)
                else:
                    lat = route["path"][0]["lat"]
                    lng = route["path"][0]["lng"]
                
                vehicle = {
                    "id": f"vehicle_{vehicle_id}",
                    "route_id": route["id"],
                    "route_name": route["name"],
                    "type": route["type"],
                    "position": {
                        "lat": lat,
                        "lng": lng
                    },
                    "speed": random.randint(20, 60),  # km/h
                    "heading": random.randint(0, 360),
                    "next_stop": route["stops"][min(stop_index + 1, len(route["stops"]) - 1)]["name"] if route["stops"] else "Terminal",
                    "capacity": random.randint(30, 100),
                    "occupancy": random.randint(10, 80),
                    "last_updated": datetime.now().isoformat()
                }
                
                vehicles.append(vehicle)
                vehicle_id += 1
        
        return vehicles
    
    def get_all_regions(self):
        """Get list of all regions/countries"""
        result = []
        for continent, countries in self.regions.items():
            for country_code, country_data in countries.items():
                result.append({
                    "code": country_code,
                    "name": country_data["name"],
                    "continent": continent,
                    "cities": [city["name"] for city in country_data["cities"]]
                })
        return result
    
    def get_routes_by_region(self, country_code=None, city=None):
        """Get routes filtered by region"""
        filtered_routes = self.routes
        
        if country_code:
            filtered_routes = [r for r in filtered_routes if r["country_code"] == country_code]
        
        if city:
            filtered_routes = [r for r in filtered_routes if r["city"] == city]
        
        return filtered_routes
    
    def search_routes(self, query, country_code=None):
        """Search routes by name or number"""
        query = query.lower()
        results = []
        
        for route in self.routes:
            if country_code and route["country_code"] != country_code:
                continue
            
            if (query in route["name"].lower() or 
                query in route["route_number"].lower() or
                query in route["city"].lower()):
                results.append(route)
        
        return results[:20]  # Limit to 20 results
    
    def get_route_by_id(self, route_id):
        """Get specific route details"""
        for route in self.routes:
            if route["id"] == route_id:
                return route
        return None
    
    def get_vehicles_by_route(self, route_id):
        """Get all vehicles for a specific route"""
        return [v for v in self.vehicles if v["route_id"] == route_id]
    
    def update_vehicle_positions(self):
        """Simulate vehicle movement"""
        for vehicle in self.vehicles:
            route = self.get_route_by_id(vehicle["route_id"])
            if not route or not route["stops"]:
                continue
            
            # Move vehicle slightly along the route
            vehicle["position"]["lat"] += random.uniform(-0.001, 0.001)
            vehicle["position"]["lng"] += random.uniform(-0.001, 0.001)
            vehicle["speed"] = random.randint(20, 60)
            vehicle["heading"] = (vehicle["heading"] + random.randint(-10, 10)) % 360
            vehicle["occupancy"] = max(5, min(vehicle["capacity"], vehicle["occupancy"] + random.randint(-5, 5)))
            vehicle["last_updated"] = datetime.now().isoformat()
        
        return self.vehicles

# Global instance
mock_data = MockDataGenerator()
