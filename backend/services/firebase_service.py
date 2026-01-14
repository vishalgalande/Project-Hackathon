"""
Firebase Service Module
=======================
Handles all Firebase operations:
- Authentication (verify tokens)
- Firestore (database operations)
- Storage (file uploads)

SETUP:
1. Create a Firebase project at console.firebase.google.com
2. Download service account key (Project Settings > Service Accounts > Generate New Private Key)
3. Save it as: firebase/service_account.json
"""

import os
import json
from typing import Dict, List, Optional

# Check if firebase_admin is installed
try:
    import firebase_admin
    from firebase_admin import credentials, firestore, auth, storage
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False
    print("WARNING: firebase-admin not installed. Run: pip install firebase-admin")


class FirebaseService:
    """Singleton Firebase service wrapper"""
    
    _instance = None
    _initialized = False
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if FirebaseService._initialized:
            return
            
        self.db = None
        self.bucket = None
        self._initialize()
        FirebaseService._initialized = True
    
    def _initialize(self):
        """Initialize Firebase Admin SDK"""
        if not FIREBASE_AVAILABLE:
            print("Firebase Admin SDK not available")
            return
            
        # Look for service account key in multiple locations
        possible_paths = [
            "firebase/service_account.json",
            "../firebase/service_account.json",
            os.environ.get("FIREBASE_SERVICE_ACCOUNT", ""),
        ]
        
        cred_path = None
        for path in possible_paths:
            if path and os.path.exists(path):
                cred_path = path
                break
        
        if not cred_path:
            print("WARNING: Firebase service account key not found!")
            print("Please download it from Firebase Console and save to: firebase/service_account.json")
            return
        
        try:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred, {
                'storageBucket': f'{cred.project_id}.appspot.com'
            })
            self.db = firestore.client()
            self.bucket = storage.bucket()
            print(f"Firebase initialized for project: {cred.project_id}")
        except Exception as e:
            print(f"Firebase initialization failed: {e}")
    
    # =========================================
    # AUTHENTICATION
    # =========================================
    
    def verify_token(self, id_token: str) -> Optional[Dict]:
        """
        Verify a Firebase ID token from the frontend.
        Returns the decoded token (contains user info) or None if invalid.
        """
        if not FIREBASE_AVAILABLE:
            return None
        try:
            decoded = auth.verify_id_token(id_token)
            return decoded
        except Exception as e:
            print(f"Token verification failed: {e}")
            return None
    
    def get_user(self, uid: str) -> Optional[Dict]:
        """Get user info by UID"""
        if not FIREBASE_AVAILABLE:
            return None
        try:
            user = auth.get_user(uid)
            return {
                "uid": user.uid,
                "email": user.email,
                "display_name": user.display_name,
                "photo_url": user.photo_url,
            }
        except Exception as e:
            print(f"Failed to get user: {e}")
            return None
    
    # =========================================
    # FIRESTORE DATABASE
    # =========================================
    
    def get_collection(self, collection_name: str) -> List[Dict]:
        """Get all documents from a collection"""
        if not self.db:
            return []
        docs = self.db.collection(collection_name).stream()
        return [{"id": doc.id, **doc.to_dict()} for doc in docs]
    
    def get_document(self, collection_name: str, doc_id: str) -> Optional[Dict]:
        """Get a single document by ID"""
        if not self.db:
            return None
        doc = self.db.collection(collection_name).document(doc_id).get()
        if doc.exists:
            return {"id": doc.id, **doc.to_dict()}
        return None
    
    def create_document(self, collection_name: str, data: Dict, doc_id: str = None) -> str:
        """Create a new document. Returns the document ID."""
        if not self.db:
            return ""
        if doc_id:
            self.db.collection(collection_name).document(doc_id).set(data)
            return doc_id
        else:
            doc_ref = self.db.collection(collection_name).add(data)
            return doc_ref[1].id
    
    def update_document(self, collection_name: str, doc_id: str, data: Dict) -> bool:
        """Update an existing document"""
        if not self.db:
            return False
        try:
            self.db.collection(collection_name).document(doc_id).update(data)
            return True
        except Exception as e:
            print(f"Update failed: {e}")
            return False
    
    def delete_document(self, collection_name: str, doc_id: str) -> bool:
        """Delete a document"""
        if not self.db:
            return False
        try:
            self.db.collection(collection_name).document(doc_id).delete()
            return True
        except Exception as e:
            print(f"Delete failed: {e}")
            return False
    
    # =========================================
    # STORAGE
    # =========================================
    
    def upload_file(self, file_path: str, destination: str) -> Optional[str]:
        """
        Upload a file to Firebase Storage.
        Returns the public URL or None if failed.
        """
        if not self.bucket:
            return None
        try:
            blob = self.bucket.blob(destination)
            blob.upload_from_filename(file_path)
            blob.make_public()
            return blob.public_url
        except Exception as e:
            print(f"Upload failed: {e}")
            return None
    
    def get_file_url(self, file_path: str) -> Optional[str]:
        """Get public URL for a file in storage"""
        if not self.bucket:
            return None
        blob = self.bucket.blob(file_path)
        if blob.exists():
            return blob.public_url
        return None


# Global instance
firebase = FirebaseService()


# =========================================
# CONVENIENCE FUNCTIONS
# =========================================

def save_zone_to_firebase(zone_data: Dict) -> bool:
    """Save a zone to Firestore"""
    zone_id = zone_data.get("id")
    if zone_id:
        firebase.create_document("zones", zone_data, doc_id=zone_id)
        return True
    return False

def get_zones_from_firebase() -> List[Dict]:
    """Get all zones from Firestore"""
    return firebase.get_collection("zones")

def save_vote_to_firebase(zone_id: str, user_id: str, vote: int) -> bool:
    """Save a vote to Firestore"""
    vote_data = {
        "zone_id": zone_id,
        "user_id": user_id,
        "vote": vote,
        "timestamp": firestore.SERVER_TIMESTAMP if FIREBASE_AVAILABLE else None
    }
    firebase.create_document("votes", vote_data)
    return True


# =========================================
# TEST
# =========================================
if __name__ == "__main__":
    print("=== Firebase Service Test ===")
    print(f"Firebase available: {FIREBASE_AVAILABLE}")
    print(f"Database connected: {firebase.db is not None}")
    print(f"Storage connected: {firebase.bucket is not None}")
