import math
from typing import Tuple, Dict

# Known industrial hub coordinates in Tamil Nadu & South India
TAMIL_NADU_HUBS: Dict[str, Tuple[float, float]] = {
    "coimbatore": (11.0168, 76.9558),
    "ganapathy": (11.0384, 76.9744),
    "sidco kurichi": (10.9412, 76.9723),
    "peelamedu": (11.0289, 77.0093),
    "saravanampatti": (11.0797, 76.9997),
    "chennai": (13.0827, 80.2707),
    "ambattur": (13.0978, 80.1611),
    "guindy": (13.0067, 80.2026),
    "sriperumbudur": (12.9691, 79.9497),
    "hosur": (12.7409, 77.8253),
    "salem": (11.6643, 78.1460),
    "tiruppur": (11.1085, 77.3411),
    "erode": (11.3410, 77.7172),
    "madurai": (9.9252, 78.1198),
    "trichy": (10.7905, 78.7047),
    "bengaluru": (12.9716, 77.5946),
}


def haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate the great circle distance between two points
    on the earth (specified in decimal degrees) using Haversine formula.
    """
    # Earth radius in kilometers
    R = 6371.0

    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = (
        math.sin(delta_phi / 2.0) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2
    )
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))

    distance = R * c
    return round(distance, 2)


def resolve_coordinates(location_name: str) -> Tuple[float, float]:
    """
    Resolve location string to (lat, lon) coordinates from known industrial clusters
    or fallback to central Coimbatore default.
    """
    cleaned = location_name.lower().strip()
    for hub, coords in TAMIL_NADU_HUBS.items():
        if hub in cleaned:
            return coords
    # Default to Coimbatore center
    return (11.0168, 76.9558)
