
from flask import Blueprint, request, jsonify
from datetime import datetime, timedelta

reporting_bp = Blueprint('reporting', __name__)

from services.firebase_service import firebase
from firebase_admin import firestore

reporting_bp = Blueprint('reporting', __name__)

# Collection name in Firestore
REPORTS_COLLECTION = 'reports'

EXCLUSION_TIMEOUT_MINUTES = 15

@reporting_bp.route('/api/report', methods=['POST'])
def submit_report():
    """
    Submit a report for a vehicle/stop.
    Body: { "vehicle_id": "...", "report_type": "FULL"|"DELAYED"|"BREAKDOWN", "route_id": "..." }
    """
    try:
        data = request.json
        vehicle_id = data.get('vehicle_id')
        report_type = data.get('report_type')
        route_id = data.get('route_id')

        if not vehicle_id or not report_type:
            return jsonify({'success': False, 'error': 'Missing fields'}), 400

        if not vehicle_id or not report_type:
            return jsonify({'success': False, 'error': 'Missing fields'}), 400

        # Create report object
        report_data = {
            'vehicle_id': vehicle_id,
            'report_type': report_type,
            'route_id': route_id,
            'timestamp': firestore.SERVER_TIMESTAMP,
            'created_at': datetime.now().isoformat()
        }
        
        # Save to Firestore
        firebase.create_document(REPORTS_COLLECTION, report_data)

        return jsonify({
            'success': True, 
            'message': 'Report submitted to Sync Engine',
            'exclusion_active': True 
        }), 200

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

def get_excluded_vehicles():
    """
    Returns list of vehicle IDs that should be excluded/avoided.
    Filters out old reports.
    """

    if not firebase.db:
        return []

    try:
        # Calculate cutoff time
        cutoff = datetime.now() - timedelta(minutes=EXCLUSION_TIMEOUT_MINUTES)
        
        # Query Firestore
        # Note: In a real app, you would use a proper composite index and query
        # For prototype, we might fetch recent reports and filter in python if index is missing
        # But let's try a simple query.
        
        # Since we use SERVER_TIMESTAMP, querying by time might be tricky without the exact field type match in potential mock setup
        # We will fetch all reports and filter in memory for this hackathon scale
        
        all_reports = firebase.get_collection(REPORTS_COLLECTION)
        excluded = set()
        
        for report in all_reports:
            # Check timestamp
            # 'created_at' is stored as ISO string for easier parsing here if timestamp is a complex object
            created_at_str = report.get('created_at')
            if created_at_str:
                created_at = datetime.fromisoformat(created_at_str)
                if created_at > cutoff:
                    excluded.add(report.get('vehicle_id'))
                    
        return list(excluded)
    except Exception as e:
        print(f"Error fetching exclusions: {e}")
        return []
