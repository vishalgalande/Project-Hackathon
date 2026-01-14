# EXAMPLE BACKEND FEATURE
# Each team member works in a file like this.

class TourRoutes:
    @staticmethod
    def get_all_tours():
        return {"tours": ["Safari", "Mountain Hike", "City Walk"]}

    @staticmethod
    def get_tour_details(tour_id):
        return {"id": tour_id, "name": "Sample Tour"}
