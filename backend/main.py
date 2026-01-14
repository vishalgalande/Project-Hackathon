import sys
import os

# Simulating a web server entry point (like FastAPI/Flask)

# IMPORT FEATURES
# Adding the current directory to path so imports work easily for this demo
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from features.tours import TourRoutes

def main():
    print("Starting Tourism App Backend...")
    
    # REGISTER ROUTES
    # In Flask/FastAPI, this would be app.include_router(...)
    
    print("Registering Tour Routes...")
    tours = TourRoutes.get_all_tours()
    print(f"Verified Tours Endpoint: {tours}")

    print("Server Ready!")

if __name__ == "__main__":
    main()
