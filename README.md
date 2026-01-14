# Global Transit Tracker 🚌🌍

A modern, real-time public transport tracking application with global coverage across 50+ countries. Track buses, metros, trams, and light rail vehicles on an interactive world map.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## ✨ Features

### 🗺️ Interactive World Map
- **Global Coverage**: Track public transport in 50+ countries
- **80+ Cities**: Major cities across all continents
- **Real-time Visualization**: Live vehicle positions on OpenStreetMap
- **Custom Markers**: Color-coded by transport type

### 🔍 Advanced Search
- **Smart Search**: Find routes by name, number, or city
- **Autocomplete**: Real-time suggestions as you type
- **Filtered Results**: Search within specific regions
- **Fast Performance**: Debounced search with caching

### 📍 Real-Time Tracking
- **Live Updates**: Vehicle positions refresh every 5 seconds
- **500+ Routes**: Comprehensive route coverage
- **1000+ Vehicles**: Active vehicles across all regions
- **Detailed Info**: Speed, occupancy, next stop, and more

### 🎨 Modern UI Design
- **Dark Theme**: Optimized for map visibility
- **Glassmorphism**: Frosted glass effects on panels
- **Vibrant Gradients**: Purple-blue color scheme
- **Smooth Animations**: Micro-interactions throughout
- **Fully Responsive**: Works on desktop, tablet, and mobile

## 🚀 Quick Start

### Prerequisites
- Python 3.7+
- Modern web browser (Chrome, Firefox, Safari, Edge)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/vishalgalande/Project-Hackathon.git
   cd Project-Hackathon
   ```

2. **Install backend dependencies**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

3. **Start the backend server**
   ```bash
   python main.py
   ```
   Backend will run on http://localhost:5000

4. **Start the frontend server** (in a new terminal)
   ```bash
   cd frontend/web
   python -m http.server 8000
   ```
   Frontend will be available at http://localhost:8000

5. **Open in browser**
   Navigate to http://localhost:8000

## 📖 Usage Guide

### Selecting a Region
1. Click the region dropdown in the header
2. Choose a country from the list
3. Map will zoom to that region
4. Routes will be filtered automatically

### Searching for Routes
1. Click the search bar
2. Type a route name, number, or city
3. Click on a search result to view details

### Viewing Route Details
- Route path displays as a colored line on the map
- Stop markers show all stops along the route
- Side panel displays:
  - Route information
  - Live vehicles
  - Occupancy levels
  - Next stop information

### Tracking Vehicles
- Vehicle markers appear on the map
- Click any marker to view its route
- Positions update automatically every 5 seconds
- Toggle vehicle display with the traffic button

## 🏗️ Architecture

### Backend (Flask)
```
backend/
├── main.py                      # Flask application
├── requirements.txt             # Python dependencies
└── features/
    ├── mock_data_generator.py  # Global transport data
    ├── routes.py                # Routes API
    └── tracking.py              # Tracking API
```

### Frontend (Web)
```
frontend/web/
│   ├── transit.html                 # Main HTML structure
├── styles.css                   # Design system
├── api.js                       # API communication
└── app.js                       # Application logic
```

## 🔌 API Endpoints

### Regions
- `GET /api/regions` - List all available countries

### Routes
- `GET /api/routes` - Get all routes (filterable by country/city)
- `GET /api/routes/search?q={query}` - Search routes
- `GET /api/routes/{route_id}` - Get route details

### Tracking
- `GET /api/tracking/{route_id}` - Get vehicle positions
- `GET /api/tracking/{route_id}/updates` - Get updated positions
- `GET /api/tracking/all` - Get all active vehicles

## 🌍 Coverage

### Regions Included
- **North America**: USA, Canada, Mexico
- **Europe**: UK, France, Germany, Spain, Italy, Netherlands
- **Asia**: India, China, Japan, Singapore, South Korea, Thailand, UAE
- **Oceania**: Australia, New Zealand
- **South America**: Brazil, Argentina, Chile
- **Africa**: South Africa, Egypt, Nigeria

### Transport Types
- 🚌 **Bus**: Local and express routes
- 🚇 **Metro**: Underground/subway systems
- 🚊 **Tram**: Light rail and streetcars
- 🚈 **Light Rail**: Modern rail transit

## 🎨 Design System

### Color Palette
- **Primary**: Purple-blue gradient (#667eea → #764ba2)
- **Background**: Deep navy (#0f0f23)
- **Accent**: Pink-red (#f5576c)
- **Success**: Cyan gradient (#4facfe → #00f2fe)

### Typography
- **Font Family**: Inter (Google Fonts)
- **Weights**: 300, 400, 500, 600, 700, 800

### Effects
- Glassmorphism with backdrop blur
- Smooth transitions (150-400ms)
- Gradient text and backgrounds
- Custom scrollbars

## 🔧 Configuration

### Backend Configuration
Edit `backend/main.py` to change:
- Server port (default: 5000)
- CORS settings
- Debug mode

### Frontend Configuration
Edit `frontend/web/api.js` to change:
- API base URL (default: http://localhost:5000)
- Cache settings
- Request timeout

## 📱 Responsive Breakpoints

- **Desktop**: 1024px and above
- **Tablet**: 768px - 1023px
- **Mobile**: Below 768px

## 🚧 Development

### Adding New Routes
Edit `backend/features/mock_data_generator.py`:
1. Add city to `_generate_regions()`
2. Routes will be auto-generated

### Customizing UI
Edit `frontend/web/styles.css`:
- Modify CSS variables in `:root`
- Change colors, spacing, fonts
- Add new animations

### Adding Features
1. Backend: Create new endpoint in `backend/features/`
2. Frontend: Add API method in `frontend/web/api.js`
3. UI: Update `frontend/web/app.js` and HTML

## 🧪 Testing

### Backend Tests
```bash
cd backend
python -m pytest tests/
```

### Frontend Tests
Open http://localhost:8000 and verify:
- Map loads correctly
- Search returns results
- Routes display on map
- Vehicles update in real-time

## 📦 Deployment

### Backend (Vercel)
1. Configure `vercel.json` for serverless functions
2. Deploy with `vercel deploy`

### Frontend (Vercel/Netlify)
1. Build is not required (static files)
2. Deploy `frontend/web/` directory
3. Update API URL in `api.js`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

See [GIT_WORKFLOW.md](./GIT_WORKFLOW.md) for detailed workflow.

## 📄 License

This project is licensed under the MIT License.

## 👥 Team

Built with ❤️ for the Hackathon

## 🙏 Acknowledgments

- **Leaflet.js** - Interactive mapping library
- **OpenStreetMap** - Map tile provider
- **Google Fonts** - Inter font family
- **Flask** - Python web framework

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Check existing documentation
- Review the walkthrough guide

---

**Note**: This application uses mock data for demonstration purposes. For production use, integrate with real transit APIs.
