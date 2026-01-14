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
        """Generate data for major cities in India"""
        return {
            "india": {
                "maharashtra": {
                    "name": "Maharashtra",
                    "cities": [
                        {
                            "name": "Mumbai", 
                            "lat": 19.0760, 
                            "lng": 72.8777, 
                            "routes": 20,
                            "stops": [
                                "Churchgate", "Marine Lines", "Charni Road", "Grant Road", "Mumbai Central",
                                "Mahalaxmi", "Lower Parel", "Elphinstone Road", "Dadar", "Matunga",
                                "Sion", "Kurla", "Ghatkopar", "Vikhroli", "Bhandup",
                                "Mulund", "Thane", "Kalyan", "Dombivli", "Badlapur",
                                "Andheri", "Jogeshwari", "Goregaon", "Malad", "Kandivali",
                                "Borivali", "Dahisar", "Mira Road", "Bhayandar", "Vasai"
                            ]
                        },
                        {
                            "name": "Pune", 
                            "lat": 18.5204, 
                            "lng": 73.8567, 
                            "routes": 15,
                            "stops": [
                                "Shivajinagar", "Deccan", "Kothrud", "Karve Nagar", "Warje",
                                "Katraj", "Swargate", "Hadapsar", "Magarpatta", "Kharadi",
                                "Viman Nagar", "Kalyani Nagar", "Koregaon Park", "Camp", "MG Road",
                                "Pimpri", "Chinchwad", "Wakad", "Hinjewadi", "Baner"
                            ]
                        },
                        {
                            "name": "Nagpur",
                            "lat": 21.1458,
                            "lng": 79.0882,
                            "routes": 10,
                            "stops": [
                                "Sitabuldi", "Dharampeth", "Sadar", "Itwari", "Kamptee Road",
                                "Ajni", "Wardha Road", "Hingna", "Koradi", "Khapri"
                            ]
                        }
                    ]
                },
                "delhi": {
                    "name": "Delhi NCR",
                    "cities": [
                        {
                            "name": "Delhi", 
                            "lat": 28.7041, 
                            "lng": 77.1025, 
                            "routes": 25,
                            "stops": [
                                "Connaught Place", "Rajiv Chowk", "Kashmere Gate", "ISBT", "Red Fort",
                                "Chandni Chowk", "New Delhi Railway Station", "Paharganj", "Karol Bagh", "Rajouri Garden",
                                "Janakpuri", "Dwarka", "Uttam Nagar", "Najafgarh", "Rohini",
                                "Pitampura", "Shalimar Bagh", "Model Town", "GTB Nagar", "Vishwavidyalaya",
                                "Civil Lines", "Shahdara", "Anand Vihar", "Laxmi Nagar", "Mayur Vihar",
                                "Noida City Centre", "Botanical Garden", "Vaishali", "Ghaziabad", "Saket"
                            ]
                        },
                        {
                            "name": "Gurgaon",
                            "lat": 28.4595,
                            "lng": 77.0266,
                            "routes": 12,
                            "stops": [
                                "Cyber City", "MG Road", "IFFCO Chowk", "Huda City Centre", "Sikanderpur",
                                "Golf Course Road", "DLF Phase 1", "DLF Phase 2", "DLF Phase 3", "Sector 14",
                                "Sector 29", "Sector 56", "Sector 54", "Sector 55", "Sector 43"
                            ]
                        }
                    ]
                },
                "karnataka": {
                    "name": "Karnataka",
                    "cities": [
                        {
                            "name": "Bangalore", 
                            "lat": 12.9716, 
                            "lng": 77.5946, 
                            "routes": 22,
                            "stops": [
                                "Majestic", "City Railway Station", "Cubbon Park", "MG Road", "Brigade Road",
                                "Indiranagar", "Koramangala", "BTM Layout", "Jayanagar", "JP Nagar",
                                "Banashankari", "Basavanagudi", "Malleshwaram", "Rajajinagar", "Yeshwanthpur",
                                "Hebbal", "Manyata Tech Park", "Yelahanka", "Whitefield", "Marathahalli",
                                "Silk Board", "Electronic City", "Hosur Road", "Sarjapur Road", "Bellandur"
                            ]
                        },
                        {
                            "name": "Mysore",
                            "lat": 12.2958,
                            "lng": 76.6394,
                            "routes": 8,
                            "stops": [
                                "Mysore Palace", "Chamundi Hills", "KR Circle", "Saraswathipuram", "Vijayanagar",
                                "Kuvempunagar", "Hebbal", "Hinkal", "Hunsur Road", "Bannimantap"
                            ]
                        }
                    ]
                },
                "tamil_nadu": {
                    "name": "Tamil Nadu",
                    "cities": [
                        {
                            "name": "Chennai",
                            "lat": 13.0827,
                            "lng": 80.2707,
                            "routes": 18,
                            "stops": [
                                "Chennai Central", "Egmore", "T Nagar", "Anna Nagar", "Adyar",
                                "Velachery", "Tambaram", "Chrompet", "Guindy", "Saidapet",
                                "Mylapore", "Triplicane", "George Town", "Parrys", "Broadway",
                                "Koyambedu", "Vadapalani", "Ashok Nagar", "KK Nagar", "Porur"
                            ]
                        }
                    ]
                },
                "west_bengal": {
                    "name": "West Bengal",
                    "cities": [
                        {
                            "name": "Kolkata",
                            "lat": 22.5726,
                            "lng": 88.3639,
                            "routes": 16,
                            "stops": [
                                "Howrah", "Sealdah", "Esplanade", "Park Street", "Dalhousie",
                                "BBD Bagh", "Maidan", "Kalighat", "Tollygunge", "Jadavpur",
                                "Garia", "Ballygunge", "Gariahat", "Lake Market", "Salt Lake",
                                "Rajarhat", "New Town", "Dum Dum", "Airport", "Barasat"
                            ]
                        }
                    ]
                },
                "telangana": {
                    "name": "Telangana",
                    "cities": [
                        {
                            "name": "Hyderabad",
                            "lat": 17.3850,
                            "lng": 78.4867,
                            "routes": 18,
                            "stops": [
                                "Secunderabad", "Parade Ground", "Begumpet", "Ameerpet", "SR Nagar",
                                "KPHB", "Kukatpally", "Miyapur", "Lingampally", "Hi-Tech City",
                                "Madhapur", "Gachibowli", "Financial District", "Mehdipatnam", "Lakdi-ka-pul",
                                "Nampally", "Abids", "Koti", "Malakpet", "Dilsukhnagar"
                            ]
                        }
                    ]
                },
                "gujarat": {
                    "name": "Gujarat",
                    "cities": [
                        {
                            "name": "Ahmedabad",
                            "lat": 23.0225,
                            "lng": 72.5714,
                            "routes": 14,
                            "stops": [
                                "Kalupur Railway Station", "Lal Darwaja", "Relief Road", "Paldi", "Navrangpura",
                                "Satellite", "Vastrapur", "Bodakdev", "SG Highway", "Maninagar",
                                "Naroda", "Nikol", "Vastral", "Narol", "Sarkhej"
                            ]
                        }
                    ]
                },
                "rajasthan": {
                    "name": "Rajasthan",
                    "cities": [
                        {
                            "name": "Jaipur",
                            "lat": 26.9124,
                            "lng": 75.7873,
                            "routes": 12,
                            "stops": [
                                "Jaipur Railway Station", "Sindhi Camp", "MI Road", "Ajmeri Gate", "Sanganeri Gate",
                                "Malviya Nagar", "Mansarovar", "Vaishali Nagar", "Jagatpura", "Sitapura",
                                "Tonk Road", "Durgapura", "Jawahar Circle", "C-Scheme", "Bani Park"
                            ]
                        }
                    ]
                },
                "kerala": {
                    "name": "Kerala",
                    "cities": [
                        {
                            "name": "Kochi",
                            "lat": 9.9312,
                            "lng": 76.2673,
                            "routes": 10,
                            "allowed_types": ["Metro", "Bus", "Light Rail"],
                            "stops": [
                                "Aluva", "Companypaddy", "Ambattukavu", "Muttom", "Kalamassery",
                                "Cochin University", "Pathadipalam", "Edapally", "Changampuzha Park", "Palarivattom",
                                "Jawaharlal Nehru Stadium", "Kaloor", "Lissie", "MG Road", "Maharaja's College",
                                "Ernakulam South", "Kadavanthra", "Elamkulam", "Vytila", "Pettah"
                            ]
                        },
                        {
                            "name": "Trivandrum",
                            "lat": 8.5241,
                            "lng": 76.9366,
                            "routes": 8,
                            "allowed_types": ["Bus"],
                            "stops": [
                                "East Fort", "Thampanoor", "Palayam", "Pattom", "Kesavadasapuram",
                                "Ulloor", "Sreekaryam", "Kazhakootam", "Technopark", "Vellayambalam",
                                "Kowdiar", "Peroorkada", "Vattiyoorkavu", "Poojappura", "Karamana"
                            ]
                        }
                    ]
                },
                "uttar_pradesh": {
                    "name": "Uttar Pradesh",
                    "cities": [
                        {
                            "name": "Lucknow",
                            "lat": 26.8467,
                            "lng": 80.9462,
                            "routes": 12,
                            "allowed_types": ["Metro", "Bus"],
                            "stops": [
                                "CCS Airport", "Amausi", "Transport Nagar", "Krishna Nagar", "Singar Nagar",
                                "Alambagh", "Charbagh", "Hussainganj", "Sachivalaya", "Hazratganj",
                                "KD Singh Stadium", "Vishwavidyalaya", "IT College", "Badshahnagar", "Lekhraj Market",
                                "Indira Nagar", "Munshipulia"
                            ]
                        },
                        {
                            "name": "Noida",
                            "lat": 28.5355,
                            "lng": 77.3910,
                            "routes": 10,
                            "allowed_types": ["Metro", "Bus"],
                            "stops": [
                                "Noida Sector 15", "Noida Sector 16", "Noida Sector 18", "Botanical Garden", "Golf Course",
                                "Noida City Centre", "Sector 34", "Sector 52", "Sector 61", "Sector 59",
                                "Sector 62", "Noida Electronic City"
                            ]
                        }
                    ]
                },
                "punjab": {
                    "name": "Punjab",
                    "cities": [
                        {
                            "name": "Chandigarh",
                            "lat": 30.7333,
                            "lng": 76.7794,
                            "routes": 8,
                            "allowed_types": ["Bus"],
                            "stops": [
                                "ISBT 17", "ISBT 43", "PGI", "PEC", "Panjab University",
                                "Sector 22", "Sector 35", "Sector 34", "Sector 8", "Sector 9",
                                "Sukhna Lake", "Rock Garden", "High Court", "Sector 26", "Housing Board"
                            ]
                        },
                        {
                            "name": "Amritsar",
                            "lat": 31.6340,
                            "lng": 74.8723,
                            "routes": 8,
                            "allowed_types": ["Bus"],
                            "stops": [
                                "Golden Temple", "Jallianwala Bagh", "Hall Gate", "Railway Station", "ISBT",
                                "Guru Nanak Dev University", "Putlighar", "Chheharta", "Verka", "Majitha Road"
                            ]
                        }
                    ]
                },
                "odisha": {
                    "name": "Odisha",
                    "cities": [
                        {
                            "name": "Bhubaneswar",
                            "lat": 20.2961,
                            "lng": 85.8245,
                            "routes": 8,
                            "allowed_types": ["Bus"],
                            "stops": [
                                "Master Canteen", "Vani Vihar", "Jayadev Vihar", "Acharya Vihar", "Kalpana Square",
                                "Rasulgarh", "Patia", "KIIT", "Infocity", "Chandrasekharpur",
                                "Baramunda", "Khandagiri", "Fire Station", "CRP Square"
                            ]
                        }
                    ]
                }
            }
        }
    
    def _generate_routes(self):
        """Generate transport routes for all cities"""
        routes = []
        route_id = 1
        
        # Default types if not specified in city
        default_transport_types = ["Bus", "Metro"]
        
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
                    city_stops = city.get("stops", [])
                    
                    # Determine allowed transport types for this city
                    allowed = city.get("allowed_types", default_transport_types)
                    
                    for i in range(num_routes):
                        transport_type = random.choice(allowed)
                        prefix = random.choice(route_prefixes.get(transport_type, ["Route"]))
                        
                        # Generate route path coordinates (start/end points)
                        start_lat = city["lat"] + random.uniform(-0.1, 0.1)
                        start_lng = city["lng"] + random.uniform(-0.1, 0.1)
                        end_lat = city["lat"] + random.uniform(-0.1, 0.1)
                        end_lng = city["lng"] + random.uniform(-0.1, 0.1)

                        # Generate route stops first to get start/end names
                        num_stops = random.randint(8, 15)
                        stops = []
                        
                        if city_stops and len(city_stops) >= num_stops:
                            # Use actual stop names from city data
                            selected_stops = random.sample(city_stops, num_stops)
                            for j, stop_name in enumerate(selected_stops):
                                t = j / (num_stops - 1) if num_stops > 1 else 0
                                stop_lat = start_lat + (end_lat - start_lat) * t
                                stop_lng = start_lng + (end_lng - start_lng) * t
                                stops.append({
                                    "name": stop_name,
                                    "lat": stop_lat,
                                    "lng": stop_lng,
                                    "order": j + 1
                                })
                        else:
                            # Fallback to generic names if no city stops available
                            for j in range(num_stops):
                                t = j / (num_stops - 1) if num_stops > 1 else 0
                                stop_lat = start_lat + (end_lat - start_lat) * t
                                stop_lng = start_lng + (end_lng - start_lng) * t
                                stops.append({
                                    "name": f"Stop {j + 1}",
                                    "lat": stop_lat,
                                    "lng": stop_lng,
                                    "order": j + 1
                                })

                        # Generate route name based on start and end stops
                        if stops:
                            start_stop = stops[0]["name"]
                            end_stop = stops[-1]["name"]
                            route_name = f"{start_stop} - {end_stop}"
                        else:
                            route_name = f"{prefix} {random.randint(1, 999)}"

                        # Add original route number for display if needed
                        route_number_display = f"{prefix} {random.randint(1, 999)}" if transport_type != "Metro" else f"{prefix} {random.choice(['Red', 'Blue', 'Green', 'Yellow', 'Orange', 'Purple'])}"

                        route = {
                            "id": f"route_{route_id}",
                            "route_number": route_number_display,
                            "name": route_name,
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
                    
                    # Get next two stops
                    next_stop_1_index = min(stop_index + 1, len(route["stops"]) - 1)
                    next_stop_2_index = min(stop_index + 2, len(route["stops"]) - 1)
                    
                    next_stop_1 = route["stops"][next_stop_1_index]["name"]
                    next_stop_2 = route["stops"][next_stop_2_index]["name"]
                    
                    # Calculate ETA for next stops (in minutes)
                    eta_1 = random.randint(2, 8)
                    eta_2 = random.randint(10, 20)
                else:
                    lat = route["path"][0]["lat"]
                    lng = route["path"][0]["lng"]
                    next_stop_1 = "Terminal"
                    next_stop_2 = "End of Line"
                    eta_1 = 0
                    eta_2 = 0
                
                vehicle = {
                    "id": f"vehicle_{vehicle_id}",
                    "route_id": route["id"],
                    "route_name": route["name"],
                    "route_number": route["route_number"],
                    "type": route["type"],
                    "position": {
                        "lat": lat,
                        "lng": lng
                    },
                    "speed": random.randint(20, 60),  # km/h
                    "heading": random.randint(0, 360),
                    "next_stops": [
                        {
                            "name": next_stop_1,
                            "eta": eta_1
                        },
                        {
                            "name": next_stop_2,
                            "eta": eta_2
                        }
                    ],
                    "capacity": random.randint(30, 100),
                    "occupancy": random.randint(10, 80),
                    "last_updated": datetime.now().isoformat(),
                    "status": random.choice(["On Time", "Delayed 2 min", "On Time", "On Time"])
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
            
            # Update next stops ETAs (decrease by 1 minute)
            if "next_stops" in vehicle and len(vehicle["next_stops"]) >= 2:
                vehicle["next_stops"][0]["eta"] = max(1, vehicle["next_stops"][0]["eta"] - 1)
                vehicle["next_stops"][1]["eta"] = max(2, vehicle["next_stops"][1]["eta"] - 1)
                
                # If first stop ETA is 0, move to next stop
                if vehicle["next_stops"][0]["eta"] <= 1:
                    # Find current position in route
                    for i, stop in enumerate(route["stops"]):
                        if stop["name"] == vehicle["next_stops"][0]["name"]:
                            # Move to next stops
                            next_1_idx = min(i + 1, len(route["stops"]) - 1)
                            next_2_idx = min(i + 2, len(route["stops"]) - 1)
                            
                            vehicle["next_stops"] = [
                                {
                                    "name": route["stops"][next_1_idx]["name"],
                                    "eta": random.randint(3, 8)
                                },
                                {
                                    "name": route["stops"][next_2_idx]["name"],
                                    "eta": random.randint(10, 18)
                                }
                            ]
                            break
            
            # Occasionally update status
            if random.random() < 0.1:  # 10% chance
                vehicle["status"] = random.choice(["On Time", "Delayed 2 min", "On Time", "On Time", "On Time"])
            
            vehicle["last_updated"] = datetime.now().isoformat()
        
        return self.vehicles

# Global instance
mock_data = MockDataGenerator()
