import csv
import random
from datetime import datetime, timedelta

# Constants
NUM_CITIES = 50
NUM_HOTELS = 500
ZIPF_MAX_POPULARITY = 1000
POPULARITY_VARIANCE = 50
CITY_TAG_RANGE = (2, 4)
HOTEL_TAG_RANGE = (3, 6)

CITY_COUNTRY_PAIRS = [
    ("New York", "US"), ("London", "GB"), ("Paris", "FR"), ("Tokyo", "JP"), ("Sydney", "AU"),
    ("Dubai", "AE"), ("Singapore", "SG"), ("Hong Kong", "HK"), ("Barcelona", "ES"), ("Rome", "IT"),
    ("Amsterdam", "NL"), ("Berlin", "DE"), ("Vienna", "AT"), ("Prague", "CZ"), ("Budapest", "HU"),
    ("Istanbul", "TR"), ("Bangkok", "TH"), ("Mumbai", "IN"), ("Seoul", "KR"), ("Toronto", "CA"),
    ("Los Angeles", "US"), ("Miami", "US"), ("Las Vegas", "US"), ("San Francisco", "US"), ("Chicago", "US"),
    ("Boston", "US"), ("Washington DC", "US"), ("Seattle", "US"), ("Vancouver", "CA"), ("Montreal", "CA"),
    ("Mexico City", "MX"), ("Buenos Aires", "AR"), ("Rio de Janeiro", "BR"), ("São Paulo", "BR"), ("Lima", "PE"),
    ("Cairo", "EG"), ("Cape Town", "ZA"), ("Marrakech", "MA"), ("Nairobi", "KE"), ("Lagos", "NG"),
    ("Moscow", "RU"), ("St Petersburg", "RU"), ("Warsaw", "PL"), ("Stockholm", "SE"), ("Copenhagen", "DK"),
    ("Oslo", "NO"), ("Helsinki", "FI"), ("Reykjavik", "IS"), ("Dublin", "IE"), ("Edinburgh", "GB")
]

CITY_TAGS = [
    "Business Hub", "Tourist Destination", "Cultural Center", "Shopping District", "Nightlife",
    "Historic City", "Modern Metropolis", "Coastal City", "Mountain City", "River City",
    "Art Scene", "Food Paradise", "Tech Hub", "Financial Center", "Entertainment Capital",
    "Fashion Capital", "Sports City", "Festival City", "Architecture", "Museums",
    "Parks & Gardens", "Waterfront", "Skyline Views", "Public Transport", "Walkable City",
    "Bike Friendly", "Family Friendly", "Pet Friendly", "LGBTQ+ Friendly", "Student City",
    "Retirement Friendly", "Eco Friendly", "Smart City", "Safe City", "Affordable",
    "Luxury Destination", "Adventure Sports", "Water Sports", "Winter Sports", "Beach Access",
    "Island City", "Desert City", "Tropical Climate", "Temperate Climate", "Four Seasons",
    "Sunny Weather", "Mild Climate", "Urban Jungle", "Green Spaces", "Clean Air"
]

HOTEL_NAMES = [
    # Grand Hotels
    "Grand Plaza Hotel", "Royal Crown Resort", "Imperial Palace Hotel", "Majestic Heights Resort", "Regal Plaza Hotel",
    "Grand Central Hotel", "Royal Heights Resort", "Imperial Crown Hotel", "Majestic Plaza Resort", "Regal Heights Hotel",
    "Grand Royal Hotel", "Royal Palace Resort", "Imperial Heights Hotel", "Majestic Crown Resort", "Regal Central Hotel",
    "Grand Crown Resort", "Royal Central Hotel", "Imperial Plaza Resort", "Majestic Royal Hotel", "Regal Plaza Resort",
    
    # Luxury Hotels
    "Luxury Plaza Hotel", "Elite Crown Resort", "Premium Royal Hotel", "Deluxe Heights Resort", "Prestige Plaza Hotel",
    "Luxury Heights Hotel", "Elite Plaza Resort", "Premium Crown Hotel", "Deluxe Royal Resort", "Prestige Heights Hotel",
    "Luxury Royal Resort", "Elite Heights Hotel", "Premium Plaza Resort", "Deluxe Crown Hotel", "Prestige Royal Hotel",
    "Luxury Crown Hotel", "Elite Royal Resort", "Premium Heights Hotel", "Deluxe Plaza Resort", "Prestige Crown Resort",
    
    # Business Hotels
    "Business Plaza Hotel", "Executive Crown Resort", "Corporate Royal Hotel", "Professional Heights Resort", "Commerce Plaza Hotel",
    "Business Heights Hotel", "Executive Plaza Resort", "Corporate Crown Hotel", "Professional Royal Resort", "Commerce Heights Hotel",
    "Business Royal Resort", "Executive Heights Hotel", "Corporate Plaza Resort", "Professional Crown Hotel", "Commerce Royal Hotel",
    "Business Crown Hotel", "Executive Royal Resort", "Corporate Heights Hotel", "Professional Plaza Resort", "Commerce Crown Resort",
    
    # Boutique Hotels
    "Boutique Plaza Hotel", "Artisan Crown Resort", "Designer Royal Hotel", "Stylish Heights Resort", "Chic Plaza Hotel",
    "Boutique Heights Hotel", "Artisan Plaza Resort", "Designer Crown Hotel", "Stylish Royal Resort", "Chic Heights Hotel",
    "Boutique Royal Resort", "Artisan Heights Hotel", "Designer Plaza Resort", "Stylish Crown Hotel", "Chic Royal Hotel",
    "Boutique Crown Hotel", "Artisan Royal Resort", "Designer Heights Hotel", "Stylish Plaza Resort", "Chic Crown Resort",
    
    # Resort Hotels
    "Ocean Plaza Resort", "Beach Crown Hotel", "Seaside Royal Resort", "Coastal Heights Hotel", "Marina Plaza Resort",
    "Ocean Heights Hotel", "Beach Plaza Resort", "Seaside Crown Hotel", "Coastal Royal Resort", "Marina Heights Hotel",
    "Ocean Royal Hotel", "Beach Heights Resort", "Seaside Plaza Hotel", "Coastal Crown Resort", "Marina Royal Resort",
    "Ocean Crown Resort", "Beach Royal Hotel", "Seaside Heights Resort", "Coastal Plaza Hotel", "Marina Crown Hotel",
    
    "Mountain Plaza Resort", "Alpine Crown Hotel", "Summit Royal Resort", "Peak Heights Hotel", "Ridge Plaza Resort",
    "Mountain Heights Hotel", "Alpine Plaza Resort", "Summit Crown Hotel", "Peak Royal Resort", "Ridge Heights Hotel",
    "Mountain Royal Hotel", "Alpine Heights Resort", "Summit Plaza Hotel", "Peak Crown Resort", "Ridge Royal Resort",
    "Mountain Crown Resort", "Alpine Royal Hotel", "Summit Heights Resort", "Peak Plaza Hotel", "Ridge Crown Hotel",
    
    "Garden Plaza Resort", "Park Crown Hotel", "Green Royal Resort", "Nature Heights Hotel", "Forest Plaza Resort",
    "Garden Heights Hotel", "Park Plaza Resort", "Green Crown Hotel", "Nature Royal Resort", "Forest Heights Hotel",
    "Garden Royal Hotel", "Park Heights Resort", "Green Plaza Hotel", "Nature Crown Resort", "Forest Royal Resort",
    "Garden Crown Resort", "Park Royal Hotel", "Green Heights Resort", "Nature Plaza Hotel", "Forest Crown Hotel",
    
    "Desert Plaza Resort", "Oasis Crown Hotel", "Mirage Royal Resort", "Dune Heights Hotel", "Sahara Plaza Resort",
    "Desert Heights Hotel", "Oasis Plaza Resort", "Mirage Crown Hotel", "Dune Royal Resort", "Sahara Heights Hotel",
    "Desert Royal Hotel", "Oasis Heights Resort", "Mirage Plaza Hotel", "Dune Crown Resort", "Sahara Royal Resort",
    "Desert Crown Resort", "Oasis Royal Hotel", "Mirage Heights Resort", "Dune Plaza Hotel", "Sahara Crown Hotel",
    
    "Tropical Plaza Resort", "Paradise Crown Hotel", "Island Royal Resort", "Lagoon Heights Hotel", "Palm Plaza Resort",
    "Tropical Heights Hotel", "Paradise Plaza Resort", "Island Crown Hotel", "Lagoon Royal Resort", "Palm Heights Hotel",
    "Tropical Royal Hotel", "Paradise Heights Resort", "Island Plaza Hotel", "Lagoon Crown Resort", "Palm Royal Resort",
    "Tropical Crown Resort", "Paradise Royal Hotel", "Island Heights Resort", "Lagoon Plaza Hotel", "Palm Crown Hotel",
    
    # Additional Hotels
    "Skyline Plaza Hotel", "Horizon Crown Resort", "Vista Royal Suites", "Panorama Plaza Hotel", "Skyline Heights Resort",
    "Horizon Royal Hotel", "Vista Elite Suites", "Panorama Crown Resort", "Skyline Central Hotel", "Horizon Plaza Resort",
    "Vista Royal Hotel", "Panorama Executive Suites", "Skyline Crown Resort", "Horizon Heights Hotel", "Vista Plaza Resort",
    "Panorama Royal Hotel", "Skyline Elite Suites", "Horizon Central Resort", "Vista Crown Hotel", "Panorama Plaza Resort",
    
    "Riverside Plaza Hotel", "Waterfront Crown Resort", "Lakeside Royal Suites", "Riverside Heights Hotel", "Waterfront Plaza Resort",
    "Lakeside Crown Hotel", "Riverside Elite Suites", "Waterfront Royal Hotel", "Lakeside Plaza Resort", "Riverside Central Hotel",
    "Waterfront Executive Suites", "Lakeside Heights Resort", "Riverside Crown Resort", "Waterfront Plaza Hotel", "Lakeside Royal Hotel",
    "Riverside Plaza Resort", "Waterfront Elite Hotel", "Lakeside Central Suites", "Riverside Royal Resort", "Waterfront Heights Hotel",
    
    "Sunset Plaza Hotel", "Sunrise Crown Resort", "Dawn Royal Suites", "Sunset Heights Hotel", "Sunrise Plaza Resort",
    "Dawn Crown Hotel", "Sunset Elite Suites", "Sunrise Royal Hotel", "Dawn Plaza Resort", "Sunset Central Hotel",
    "Sunrise Executive Suites", "Dawn Heights Resort", "Sunset Crown Resort", "Sunrise Plaza Hotel", "Dawn Royal Hotel",
    "Sunset Plaza Resort", "Sunrise Elite Hotel", "Dawn Central Suites", "Sunset Royal Resort", "Sunrise Heights Hotel",
    
    "Central Plaza Hotel", "Downtown Crown Resort", "Midtown Royal Suites", "Central Heights Hotel", "Downtown Plaza Resort",
    "Midtown Crown Hotel", "Central Elite Suites", "Downtown Royal Hotel", "Midtown Plaza Resort", "Central Crown Hotel",
    "Downtown Executive Suites", "Midtown Heights Resort", "Central Plaza Resort", "Downtown Heights Hotel", "Midtown Royal Hotel",
    "Central Royal Resort", "Downtown Elite Hotel", "Midtown Central Suites", "Central Executive Hotel", "Downtown Plaza Hotel",
    
    "Royal Plaza Resort", "Elite Crown Suites", "Grand Heights Hotel", "Royal Central Resort",
    "Elite Plaza Hotel", "Grand Royal Suites", "Elite Central Hotel", "Grand Plaza Resort",
    "Royal Executive Hotel", "Elite Heights Suites", "Grand Crown Resort", "Royal Plaza Hotel", "Elite Royal Hotel",
    "Royal Elite Resort", "Elite Crown Hotel", "Grand Executive Suites", "Royal Heights Hotel",
    
    "Premier Plaza Hotel", "Supreme Crown Resort", "Ultimate Royal Suites", "Premier Heights Hotel", "Supreme Plaza Resort",
    "Ultimate Crown Hotel", "Premier Elite Suites", "Supreme Royal Hotel", "Ultimate Plaza Resort", "Premier Central Hotel",
    "Supreme Executive Suites", "Ultimate Heights Resort", "Premier Crown Resort", "Supreme Plaza Hotel", "Ultimate Royal Hotel",
    "Premier Plaza Resort", "Supreme Elite Hotel", "Ultimate Central Suites", "Premier Royal Resort", "Supreme Heights Hotel"
]

HOTEL_TAGS = [
    # Accommodation Types
    "Hotel", "Resort", "Boutique Hotel", "Business Hotel", "Extended Stay", "Hostel", "Inn", "Lodge", "Motel", "Suite Hotel",
    
    # Service Level
    "5 Star", "4 Star", "3 Star", "Budget", "Mid-Range", "Luxury", "Premium", "Economy", "Deluxe", "Standard",
    
    # Amenities & Facilities
    "Swimming Pool", "Spa Services", "Fitness Center", "Restaurant", "Bar", "Room Service", "Concierge", "Valet Parking",
    "Business Center", "Meeting Rooms", "Conference Facilities", "Laundry Service", "Dry Cleaning", "Airport Transfer",
    
    # Room Features
    "Balcony", "Ocean View", "City View", "Mountain View", "Garden View", "Kitchenette", "Mini Bar", "Safe", "Air Conditioning",
    "Heating", "Jacuzzi", "Fireplace", "Terrace", "Private Bathroom", "Shared Bathroom",
    
    # Technology
    "Free WiFi", "High Speed Internet", "Smart TV", "Cable TV", "Phone", "Work Desk", "USB Charging", "Bluetooth Speaker",
    
    # Dining
    "Breakfast Included", "Half Board", "Full Board", "All Inclusive", "Continental Breakfast", "Buffet", "A la Carte",
    "24 Hour Dining", "In-Room Dining", "Minibar", "Coffee Maker", "Refrigerator",
    
    # Special Services
    "Pet Friendly", "Child Friendly", "Babysitting", "Kids Club", "Playground", "Family Rooms", "Connecting Rooms",
    "Accessible", "Non Smoking", "Smoking Allowed", "Late Check Out", "Early Check In",
    
    # Location Features
    "Beachfront", "Waterfront", "City Center", "Airport Nearby", "Train Station Nearby", "Shopping District",
    "Entertainment District", "Financial District", "Historic District", "Quiet Area", "Scenic Location",
    
    # Recreation
    "Tennis Court", "Golf Course", "Water Sports", "Bike Rental", "Car Rental", "Tour Desk", "Ticket Service",
    "Game Room", "Library", "Garden", "Outdoor Activities", "Indoor Activities",
    
    # Wellness
    "Spa", "Massage", "Sauna", "Steam Room", "Hot Tub", "Wellness Center", "Yoga Classes", "Meditation Area",
    
    # Business Features
    "Business Lounge", "Executive Floor", "Boardroom", "Presentation Equipment", "Printing Services", "Fax Service",
    "Secretarial Services", "Translation Services",
    
    # Seasonal
    "Ski In Ski Out", "Beach Access", "Pool Bar", "Rooftop Bar", "Terrace Dining", "Outdoor Pool", "Indoor Pool",
    "Heated Pool", "Pool Service", "Beach Service"
]

HOTEL_RATINGS = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]
HOTEL_RATING_WEIGHTS = [1, 2, 4, 6, 14, 18, 22, 10, 3]
PRICE_BANDS = ["budget", "mid", "luxury"]
NUM_USERS = 1000
NUM_INTERACTIONS = 5000
INTERACTION_TYPES = ["view", "click", "book", "favourite", "search"]
INTERACTION_WEIGHTS = [40, 25, 15, 10, 10]

def calculate_zipf_popularity(rank, max_popularity=ZIPF_MAX_POPULARITY):
    return int(max_popularity / rank)

def generate_hotel_rating():
    """Generate weighted random hotel rating."""
    return random.choices(HOTEL_RATINGS, weights=HOTEL_RATING_WEIGHTS, k=1)[0]

def generate_tags(tags_list, tag_range):
    """Generate random tags string."""
    num_tags = random.randint(*tag_range)
    selected_tags = random.sample(tags_list, num_tags)
    return ",".join(selected_tags)

def generate_hotel_popularity():
    """Generate hotel popularity with variance."""
    base_popularity = calculate_zipf_popularity(random.randint(1, NUM_CITIES))
    return base_popularity + random.randint(-POPULARITY_VARIANCE, POPULARITY_VARIANCE)

def generate_cities():
    # Create CSV file
    with open('cities.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)

        # Write header
        writer.writerow(['city_id', 'city_name', 'country_code', 'popularity_index', 'tags'])

        # Write data for each city
        for rank, (city_name, country_code) in enumerate(CITY_COUNTRY_PAIRS, 1):
            # 1. Create city_id (format: CITY_001, CITY_002, etc.)
            city_id = f"CITY_{rank:03d}"
            # 2. Calculate popularity using calculate_zipf_popularity(rank)
            popularity = calculate_zipf_popularity(rank)
            # 3. Generate tags
            tags_string = generate_tags(CITY_TAGS, CITY_TAG_RANGE)
            # 4. Write the row
            writer.writerow([city_id, city_name, country_code, popularity, tags_string])

def generate_hotels():
    # Create CSV file
    with open('hotels.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['hotel_id', 'city_id', 'hotel_name', 'rating', 'price_band', 'tags', 'popularity_score'])

        for i in range(NUM_HOTELS):
            hotel_id = f"HOTEL_{i+1:03d}"
            city_id = f"CITY_{random.randint(1, NUM_CITIES):03d}"
            hotel_name = random.choice(HOTEL_NAMES)
            rating = generate_hotel_rating()
            price_band = random.choice(PRICE_BANDS)
            tags_string = generate_tags(HOTEL_TAGS, HOTEL_TAG_RANGE)
            popularity_score = generate_hotel_popularity()

            writer.writerow([hotel_id, city_id, hotel_name, rating, price_band, tags_string, popularity_score])

def generate_timestamp():
    today = datetime.now()
    ninety_days_ago = today - timedelta(days=90)
    random_seconds = random.randint(0, 90 * 24 * 3600)
    random_timestamp = ninety_days_ago + timedelta(seconds=random_seconds)
    return random_timestamp.strftime("%Y-%m-%d %H:%M:%S")

def generate_user_interactions():
    with open('user_interactions.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['interaction_id', 'user_id', 'hotel_id', 'interaction_type', 'timestamp', 'session_id'])

        for r in range(NUM_INTERACTIONS):
            interaction_id = f"INT_{r+1:05d}"
            user_id = f"USER_{random.randint(1, NUM_USERS):03d}"
            hotel_id = f"HOTEL_{random.randint(1, NUM_HOTELS):03d}"
            interaction_type = random.choices(INTERACTION_TYPES, weights=INTERACTION_WEIGHTS, k=1)[0]
            timestamp = generate_timestamp()
            session_id = f"SESSION_{random.randint(1, NUM_INTERACTIONS//3):05d}"

            writer.writerow([interaction_id, user_id, hotel_id, interaction_type, timestamp, session_id])

if __name__ == "__main__":
    generate_cities()
    generate_hotels()
    generate_user_interactions()