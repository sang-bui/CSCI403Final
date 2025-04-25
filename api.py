from fastapi import FastAPI, HTTPException, Depends, Body
from sqlalchemy import create_engine, Column, Integer, String, Boolean, Float, Text, ForeignKey, TIMESTAMP
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from typing import List, Optional
import os
import requests
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
from pydantic import BaseModel

# Load environment variables
load_dotenv()

# Create FastAPI app
app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Database configuration
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")

# Set search path in connection string
SQLALCHEMY_DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}?options=-c%20search_path%3Dgroup44"
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Models
class University(Base):
    __tablename__ = "universities"

    id = Column(Integer, primary_key=True)
    name = Column(Text)
    state = Column(Text)
    sector = Column(Text)
    zip = Column(Text)
    latitude = Column(Float)
    longitude = Column(Float)
    applicants_total = Column(Float)
    admissions_total = Column(Float)
    enrolled_total = Column(Float)
    pct_submit_sat = Column(Float)
    pct_submit_act = Column(Float)
    sat_reading_25 = Column(Float)
    sat_reading_75 = Column(Float)
    sat_math_25 = Column(Float)
    sat_math_75 = Column(Float)
    sat_writing_25 = Column(Float)
    sat_writing_75 = Column(Float)
    act_composite_25 = Column(Float)
    act_composite_75 = Column(Float)
    description = Column(Text)
    website = Column(Text)
    phone_number = Column(Text)

    degree_offerings = relationship("DegreeOffering", back_populates="university")
    institution_identity = relationship("InstitutionIdentity", back_populates="university", uselist=False)

class InstitutionIdentity(Base):
    __tablename__ = "institution_identity"

    id = Column(Integer, primary_key=True)
    university_id = Column(Integer, ForeignKey('universities.id'))
    is_hbcu = Column(Boolean)
    is_tribal = Column(Boolean)
    religious_affiliation = Column(Text)
    carnegie_classification = Column(Text)
    control_of_institution = Column(Text)

    university = relationship("University", back_populates="institution_identity")

class DegreeOffering(Base):
    __tablename__ = "degree_offerings"

    id = Column(Integer, primary_key=True)
    university_id = Column(Integer, ForeignKey('universities.id'))
    offers_bachelors = Column(Boolean)
    offers_masters = Column(Boolean)
    offers_doctorate = Column(Boolean)
    offers_year_certificate = Column(Boolean)
    offers_post_bachelors_certificate = Column(Boolean)
    offers_post_masters_certificate = Column(Boolean)
    offers_post_doctorate_certificate = Column(Boolean)
    highest_degree = Column(Text)

    university = relationship("University", back_populates="degree_offerings")

class UserSwipe(Base):
    __tablename__ = "user_swipes"

    id = Column(Integer, primary_key=True)
    university_id = Column(Integer, ForeignKey("universities.id"))
    swipe_direction = Column(String(10))
    swipe_timestamp = Column(TIMESTAMP, default=datetime.utcnow)
    notes = Column(Text)

class UniversityMatch(Base):
    __tablename__ = "university_matches"

    id = Column(Integer, primary_key=True)
    university_id = Column(Integer, ForeignKey("universities.id"))
    match_timestamp = Column(TIMESTAMP, default=datetime.utcnow)

class SwipeRequest(BaseModel):
    university_id: int
    swipe_direction: str
    notes: Optional[str] = None

# Create tables (if they don't exist)
Base.metadata.create_all(bind=engine)

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# API Endpoints
@app.get("/")
def read_root():
    return {"message": "Welcome to the Universities API"}

@app.get("/universities/states")
async def get_all_states(db: Session = Depends(get_db)):
    states = db.query(University.state).distinct().order_by(University.state).all()
    return [state[0] for state in states if state[0] is not None]

@app.get("/universities/", response_model=List[dict])
def get_universities(
    skip: int = 0, 
    limit: int = 100,
    states: str = None,
    sector: str = None,
    offers_bachelors: bool = None,
    offers_masters: bool = None,
    offers_doctorate: bool = None,
    is_hbcu: bool = None,
    is_tribal: bool = None,
    religious_affiliation: str = None,
    control_of_institution: str = None,
    min_sat_math: float = None,
    max_sat_math: float = None,
    min_act_composite: float = None,
    max_act_composite: float = None,
    db: Session = Depends(get_db)
):
    query = db.query(University).join(University.institution_identity)
    
    # Apply state filters if provided
    if states:
        state_list = [state.strip() for state in states.split(',')]
        query = query.filter(University.state.in_(state_list))
    
    # Apply sector filter if provided
    if sector:
        query = query.filter(University.sector == sector)
    
    # Apply degree filters if provided
    if any([offers_bachelors, offers_masters, offers_doctorate]):
        query = query.join(DegreeOffering)
        if offers_bachelors is not None:
            query = query.filter(DegreeOffering.offers_bachelors == offers_bachelors)
        if offers_masters is not None:
            query = query.filter(DegreeOffering.offers_masters == offers_masters)
        if offers_doctorate is not None:
            query = query.filter(DegreeOffering.offers_doctorate == offers_doctorate)
    
    # Apply institution identity filters
    if is_hbcu is not None:
        query = query.filter(InstitutionIdentity.is_hbcu == is_hbcu)
    if is_tribal is not None:
        query = query.filter(InstitutionIdentity.is_tribal == is_tribal)
    if religious_affiliation:
        query = query.filter(InstitutionIdentity.religious_affiliation == religious_affiliation)
    if control_of_institution:
        query = query.filter(InstitutionIdentity.control_of_institution == control_of_institution)
    
    # Apply test score filters
    if min_sat_math is not None:
        query = query.filter(University.sat_math_25 >= min_sat_math)
    if max_sat_math is not None:
        query = query.filter(University.sat_math_75 <= max_sat_math)
    if min_act_composite is not None:
        query = query.filter(University.act_composite_25 >= min_act_composite)
    if max_act_composite is not None:
        query = query.filter(University.act_composite_75 <= max_act_composite)
    
    universities = query.offset(skip).limit(limit).all()
    
    return [{
        "id": u.id,
        "name": u.name,
        "state": u.state,
        "sector": u.sector,
        "zip": u.zip,
        "latitude": u.latitude,
        "longitude": u.longitude,
        "is_hbcu": u.institution_identity.is_hbcu if u.institution_identity else False,
        "is_tribal": u.institution_identity.is_tribal if u.institution_identity else False,
        "religious_affiliation": u.institution_identity.religious_affiliation if u.institution_identity else None,
        "carnegie_classification": u.institution_identity.carnegie_classification if u.institution_identity else '',
        "control_of_institution": u.institution_identity.control_of_institution if u.institution_identity else '',
        # New fields
        "applicants_total": u.applicants_total,
        "admissions_total": u.admissions_total,
        "enrolled_total": u.enrolled_total,
        "pct_submit_sat": u.pct_submit_sat,
        "pct_submit_act": u.pct_submit_act,
        "sat_reading_25": u.sat_reading_25,
        "sat_reading_75": u.sat_reading_75,
        "sat_math_25": u.sat_math_25,
        "sat_math_75": u.sat_math_75,
        "sat_writing_25": u.sat_writing_25,
        "sat_writing_75": u.sat_writing_75,
        "act_composite_25": u.act_composite_25,
        "act_composite_75": u.act_composite_75,
        "description": u.description,
        "website": u.website,
        "phone_number": u.phone_number
    } for u in universities]

@app.get("/universities/{university_id}")
def get_university(university_id: int, db: Session = Depends(get_db)):
    university = db.query(University).filter(University.id == university_id).first()
    if university is None:
        raise HTTPException(status_code=404, detail="University not found")
    
    degrees = db.query(DegreeOffering).filter(DegreeOffering.university_id == university_id).first()
    identity = db.query(InstitutionIdentity).filter(InstitutionIdentity.university_id == university_id).first()
    
    return {
        "university": {
            "id": university.id,
            "name": university.name,
            "state": university.state,
            "sector": university.sector,
            "zip": university.zip,
            "latitude": university.latitude,
            "longitude": university.longitude,
            "is_hbcu": identity.is_hbcu if identity else False,
            "is_tribal": identity.is_tribal if identity else False,
            "religious_affiliation": identity.religious_affiliation if identity else None,
            "carnegie_classification": identity.carnegie_classification if identity else '',
            "control_of_institution": identity.control_of_institution if identity else '',
            # New fields
            "applicants_total": university.applicants_total,
            "admissions_total": university.admissions_total,
            "enrolled_total": university.enrolled_total,
            "pct_submit_sat": university.pct_submit_sat,
            "pct_submit_act": university.pct_submit_act,
            "sat_reading_25": university.sat_reading_25,
            "sat_reading_75": university.sat_reading_75,
            "sat_math_25": university.sat_math_25,
            "sat_math_75": university.sat_math_75,
            "sat_writing_25": university.sat_writing_25,
            "sat_writing_75": university.sat_writing_75,
            "act_composite_25": university.act_composite_25,
            "act_composite_75": university.act_composite_75,
            "description": university.description,
            "website": university.website,
            "phone_number": university.phone_number
        },
        "degrees": {
            "offers_bachelors": degrees.offers_bachelors if degrees else None,
            "offers_masters": degrees.offers_masters if degrees else None,
            "offers_doctorate": degrees.offers_doctorate if degrees else None,
            "offers_year_certificate": degrees.offers_year_certificate if degrees else None,
            "offers_post_bachelors_certificate": degrees.offers_post_bachelors_certificate if degrees else None,
            "offers_post_masters_certificate": degrees.offers_post_masters_certificate if degrees else None,
            "offers_post_doctorate_certificate": degrees.offers_post_doctorate_certificate if degrees else None,
            "highest_degree": degrees.highest_degree if degrees else None
        }
    }

@app.get("/universities/search/{name}")
def search_universities(name: str, db: Session = Depends(get_db)):
    universities = db.query(University).join(University.institution_identity).filter(University.name.ilike(f"%{name}%")).all()
    return [{
        "id": u.id,
        "name": u.name,
        "state": u.state,
        "sector": u.sector,
        "zip": u.zip,
        "latitude": u.latitude,
        "longitude": u.longitude,
        "is_hbcu": u.institution_identity.is_hbcu if u.institution_identity else False,
        "is_tribal": u.institution_identity.is_tribal if u.institution_identity else False,
        "religious_affiliation": u.institution_identity.religious_affiliation if u.institution_identity else None,
        "carnegie_classification": u.institution_identity.carnegie_classification if u.institution_identity else '',
        "control_of_institution": u.institution_identity.control_of_institution if u.institution_identity else ''
    } for u in universities]

@app.get("/universities/state/{state}")
def get_universities_by_state(state: str, db: Session = Depends(get_db)):
    universities = db.query(University).join(University.institution_identity).filter(University.state == state).all()
    return [{
        "id": u.id,
        "name": u.name,
        "state": u.state,
        "sector": u.sector,
        "zip": u.zip,
        "latitude": u.latitude,
        "longitude": u.longitude,
        "is_hbcu": u.institution_identity.is_hbcu if u.institution_identity else False,
        "is_tribal": u.institution_identity.is_tribal if u.institution_identity else False,
        "religious_affiliation": u.institution_identity.religious_affiliation if u.institution_identity else None,
        "carnegie_classification": u.institution_identity.carnegie_classification if u.institution_identity else '',
        "control_of_institution": u.institution_identity.control_of_institution if u.institution_identity else ''
    } for u in universities]

@app.get("/universities/{university_id}/degrees")
def get_university_degrees(university_id: int, db: Session = Depends(get_db)):
    degrees = db.query(DegreeOffering).filter(DegreeOffering.university_id == university_id).first()
    if degrees is None:
        raise HTTPException(status_code=404, detail="Degree offerings not found")
    return {
        "offers_bachelors": degrees.offers_bachelors,
        "offers_masters": degrees.offers_masters,
        "offers_doctorate": degrees.offers_doctorate,
        "offers_year_certificate": degrees.offers_year_certificate,
        "offers_post_bachelors_certificate": degrees.offers_post_bachelors_certificate,
        "offers_post_masters_certificate": degrees.offers_post_masters_certificate,
        "offers_post_doctorate_certificate": degrees.offers_post_doctorate_certificate,
        "highest_degree": degrees.highest_degree
    }

@app.get("/universities/{university_id}/image")
def get_university_image(university_id: int, db: Session = Depends(get_db)):
    """
    Returns a university landmark/campus image from Wikipedia
    """
    try:
        # First get the university name from our database
        university = db.query(University).filter(University.id == university_id).first()
        if not university:
            raise HTTPException(status_code=404, detail="University not found")

        print(f"Searching for images for: {university.name}")

        # Format university name for Wikipedia search
        uni_name = university.name.replace(" ", "%20")
        
        # First, search for the university page
        search_url = f"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={uni_name}&format=json"
        search_response = requests.get(search_url)
        search_response.raise_for_status()
        search_data = search_response.json()
        
        if not search_data['query']['search']:
            print("No search results found")
            return {
                "image_url": "",
                "alt_text": "No image available",
                "attribution": ""
            }
            
        # Get the first search result's page ID
        page_id = search_data['query']['search'][0]['pageid']
        print(f"Found page ID: {page_id}")
        
        # Keywords that typically indicate a campus/landmark image
        landmark_keywords = [
            'campus', 'building', 'hall', 'quad', 'library', 'tower', 'center', 'college', 'university', 'school',
            'academic', 'administration', 'arena', 'auditorium', 'bell', 'chapel', 'clock', 'commons', 'convention',
            'dormitory', 'dorm', 'education', 'faculty', 'field', 'fountain', 'garden', 'gymnasium', 'gym', 'institute',
            'laboratory', 'lab', 'lecture', 'memorial', 'museum', 'observatory', 'pavilion', 'plaza', 'research',
            'residence', 'science', 'stadium', 'student', 'theater', 'theatre', 'union', 'walk', 'walkway', 'wing'
        ]
        
        all_images = []
        
        # 1. Get images from the main page
        images_url = f"https://en.wikipedia.org/w/api.php?action=query&prop=images&pageids={page_id}&format=json"
        images_response = requests.get(images_url)
        images_response.raise_for_status()
        images_data = images_response.json()
        
        if 'images' in images_data['query']['pages'][str(page_id)]:
            main_images = images_data['query']['pages'][str(page_id)]['images']
            print(f"Found {len(main_images)} images on main page")
            all_images.extend(main_images)
        
        # 2. Get images from Commons category
        commons_url = f"https://commons.wikimedia.org/w/api.php?action=query&list=categorymembers&cmtitle=Category:{uni_name}&cmtype=file&format=json"
        commons_response = requests.get(commons_url)
        if commons_response.status_code == 200:
            commons_data = commons_response.json()
            if 'query' in commons_data and 'categorymembers' in commons_data['query']:
                commons_images = [{'title': img['title']} for img in commons_data['query']['categorymembers']]
                print(f"Found {len(commons_images)} images in Commons")
                all_images.extend(commons_images)
        
        # 3. Get images from related pages (like "List of buildings at X University")
        related_url = f"https://en.wikipedia.org/w/api.php?action=query&generator=search&gsrsearch={uni_name}+buildings&gsrlimit=5&prop=images&format=json"
        related_response = requests.get(related_url)
        if related_response.status_code == 200:
            related_data = related_response.json()
            if 'query' in related_data and 'pages' in related_data['query']:
                related_images = []
                for page in related_data['query']['pages'].values():
                    if 'images' in page:
                        related_images.extend(page['images'])
                print(f"Found {len(related_images)} images in related pages")
                all_images.extend(related_images)
        
        print(f"Total images found: {len(all_images)}")
        
        # Filter images by title and filename keywords
        landmark_images = []
        for img in all_images:
            title = img['title'].lower()
            filename = title.split(':')[-1].lower()
            matches = [k for k in landmark_keywords if k in title or k in filename]
            if matches:
                print(f"Found landmark image: {title} (matches: {matches})")
                landmark_images.append(img)
        
        print(f"Found {len(landmark_images)} landmark images")
        
        # If no landmark images found, use all images
        images_to_check = landmark_images if landmark_images else all_images
        
        # Get detailed info for each image to find the best one
        for image in images_to_check:
            image_title = image['title']
            print(f"Checking image: {image_title}")
            
            # Only use web-friendly formats
            web_formats = ['.jpg', '.jpeg', '.png', '.gif', '.webp']
            if not any(image_title.lower().endswith(ext) for ext in web_formats):
                print(f"Skipping {image_title} - not a web-friendly format")
                continue
                
            image_url = f"https://en.wikipedia.org/w/api.php?action=query&titles={image_title}&prop=imageinfo&iiprop=url|extmetadata&format=json"
            image_response = requests.get(image_url)
            image_response.raise_for_status()
            image_data = image_response.json()
            
            # Extract the actual image URL and metadata
            page = next(iter(image_data['query']['pages'].values()))
            if 'imageinfo' in page:
                image_info = page['imageinfo'][0]
                image_url = image_info['url']
                
                # Check if this is a good image to use
                if 'extmetadata' in image_info:
                    metadata = image_info['extmetadata']
                    # Skip if it's a logo or icon
                    if any(keyword in image_title.lower() for keyword in ['logo', 'icon', 'seal', 'shield']):
                        print(f"Skipping {image_title} - identified as logo/icon")
                        continue
                    # Skip if it's a person's photo
                    if 'ObjectName' in metadata and 'portrait' in metadata['ObjectName'].get('value', '').lower():
                        print(f"Skipping {image_title} - identified as portrait")
                        continue
                        
                print(f"Selected image: {image_title}")
                return {
                    "image_url": image_url,
                    "alt_text": f"Campus of {university.name}",
                    "attribution": "Image from Wikipedia"
                }
        
        print("No suitable image found")
        return {
            "image_url": "",
            "alt_text": "No image available",
            "attribution": ""
        }

    except requests.exceptions.RequestException as e:
        print(f"Error making request to Wikipedia: {e}")
        return {
            "image_url": "",
            "alt_text": "No image available",
            "attribution": ""
        }
    except Exception as e:
        print(f"Unexpected error: {e}")
        return {
            "image_url": "",
            "alt_text": "No image available",
            "attribution": ""
        }

@app.post("/swipes/")
def create_swipe(
    swipe_request: SwipeRequest = Body(...),
    db: Session = Depends(get_db)
):
    # If it's a right swipe, create a match
    if swipe_request.swipe_direction == "right":
        match = UniversityMatch(university_id=swipe_request.university_id)
        db.add(match)
        db.commit()
        db.refresh(match)

    return {"message": "Swipe processed successfully"}

@app.get("/matches")
def get_matches(db: Session = Depends(get_db)):
    matches = db.query(UniversityMatch).order_by(UniversityMatch.match_timestamp.desc()).all()
    return [{
        "id": match.id,
        "university_id": match.university_id,
        "match_timestamp": match.match_timestamp.isoformat()
    } for match in matches]

@app.delete("/matches/{match_id}")
def delete_match(match_id: int, db: Session = Depends(get_db)):
    match = db.query(UniversityMatch).filter(UniversityMatch.id == match_id).first()
    if not match:
        raise HTTPException(status_code=404, detail="Match not found")
    
    db.delete(match)
    db.commit()
    return {"message": "Match deleted successfully"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 