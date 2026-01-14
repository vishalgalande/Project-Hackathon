# Project Architecture: Feature-Based Modules

To allow us to work in parallel on this Tourism App without constant merge conflicts, we will follow a strict **Feature-Based Architecture**.

## The Golden Rule: "New Feature = New File"

**NEVER** write all your code in `main.dart` or `main.py`.
The "Main" files are only for wiring things together.

## 1. Frontend (Flutter) Structure
We separate screens into a `features/` folder.

```text
frontend/
  lib/
    main.dart           <-- ONLY routes. Don't add logic here.
    features/           <-- create your definition here
      login_screen.dart
      tour_list.dart
      booking_page.dart
```

### How to add a new page:
1.  Create a new file: `frontend/lib/features/my_new_feature.dart`.
2.  Build your `StatelessWidget` or `StatefulWidget` there.
3.  Go to `main.dart` and add one line to the `routes` map to link your page.

## 2. Backend (Python) Structure
We use "Routers" or "Blueprints" to keep API endpoints separate.

```text
backend/
  main.py               <-- ONLY imports.
  features/
    auth.py             <-- login/signup endpoints
    tours.py            <-- tour CRUD endpoints
    payments.py         <-- payment logic
```

### How to add a new API group:
1.  Create a new file: `backend/features/my_api.py`.
2.  Define your API functions there.
3.  Go to `main.py` and import/include your new file.
