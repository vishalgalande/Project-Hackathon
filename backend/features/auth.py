"""
Authentication Feature
======================
Provides Firebase Auth verification for protected routes.
"""

import functools
from typing import Dict, Optional, Callable

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.firebase_service import firebase, FIREBASE_AVAILABLE


class AuthService:
    """Authentication helpers"""
    
    @staticmethod
    def verify_token(id_token: str) -> Optional[Dict]:
        """
        Verify a Firebase ID token.
        Returns user info dict or None if invalid.
        """
        if not id_token:
            return None
        
        # Remove "Bearer " prefix if present
        if id_token.startswith("Bearer "):
            id_token = id_token[7:]
        
        return firebase.verify_token(id_token)
    
    @staticmethod
    def get_user_from_request(request) -> Optional[Dict]:
        """
        Extract and verify user from HTTP request.
        Expects: Authorization: Bearer <id_token>
        """
        auth_header = request.headers.get("Authorization", "")
        if not auth_header:
            return None
        return AuthService.verify_token(auth_header)


def require_auth(func: Callable) -> Callable:
    """
    Decorator for Flask routes that require authentication.
    
    Usage:
        @app.route("/api/protected")
        @require_auth
        def protected_route():
            user = g.user  # Access authenticated user
            return {"message": f"Hello {user['email']}"}
    """
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        from flask import request, g, jsonify
        
        user = AuthService.get_user_from_request(request)
        if not user:
            return jsonify({
                "success": False,
                "error": "Authentication required",
                "code": "UNAUTHORIZED"
            }), 401
        
        g.user = user
        return func(*args, **kwargs)
    
    return wrapper


# For non-Flask usage (direct verification)
def verify_and_get_user(token: str) -> Dict:
    """
    Verify token and return result dict.
    
    Returns:
        {"success": True, "user": {...}} on success
        {"success": False, "error": "..."} on failure
    """
    if not FIREBASE_AVAILABLE:
        return {"success": False, "error": "Firebase not available"}
    
    user = AuthService.verify_token(token)
    if user:
        return {
            "success": True,
            "user": {
                "uid": user.get("uid"),
                "email": user.get("email"),
                "name": user.get("name"),
            }
        }
    return {"success": False, "error": "Invalid or expired token"}


# ============================================================
# TEST
# ============================================================
if __name__ == "__main__":
    print("=== Auth Service Test ===")
    print(f"Firebase available: {FIREBASE_AVAILABLE}")
    print("\nTo test authentication:")
    print("1. Get a Firebase ID token from your Flutter app")
    print("2. Call: verify_and_get_user('<token>')")
