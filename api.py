from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy import create_engine, Column, Integer, String, Boolean, Float, Text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from typing import List, Optional
import pandas as pd
import os
import requests
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware

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

    degree_offerings = relationship("DegreeOffering", back_populates="university")

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
    db: Session = Depends(get_db)
):
    query = db.query(University)
    
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
    
    universities = query.offset(skip).limit(limit).all()
    
    return [{
        "id": u.id,
        "name": u.name,
        "state": u.state,
        "sector": u.sector,
        "zip": u.zip,
        "latitude": u.latitude,
        "longitude": u.longitude
    } for u in universities]

@app.get("/universities/{university_id}")
def get_university(university_id: int, db: Session = Depends(get_db)):
    university = db.query(University).filter(University.id == university_id).first()
    if university is None:
        raise HTTPException(status_code=404, detail="University not found")
    
    degrees = db.query(DegreeOffering).filter(DegreeOffering.university_id == university_id).first()
    return {
        "university": {
            "id": university.id,
            "name": university.name,
            "state": university.state,
            "sector": university.sector,
            "zip": university.zip,
            "latitude": university.latitude,
            "longitude": university.longitude
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
    universities = db.query(University).filter(University.name.ilike(f"%{name}%")).all()
    return [{
        "id": u.id,
        "name": u.name,
        "state": u.state,
        "sector": u.sector,
        "zip": u.zip,
        "latitude": u.latitude,
        "longitude": u.longitude
    } for u in universities]

@app.get("/universities/state/{state}")
def get_universities_by_state(state: str, db: Session = Depends(get_db)):
    universities = db.query(University).filter(University.state == state).all()
    return [{
        "id": u.id,
        "name": u.name,
        "state": u.state,
        "sector": u.sector,
        "zip": u.zip,
        "latitude": u.latitude,
        "longitude": u.longitude
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
    Returns a single university image from Wikipedia, focusing on campus buildings
    """
    try:
        # First get the university name from our database
        university = db.query(University).filter(University.id == university_id).first()
        if not university:
            raise HTTPException(status_code=404, detail="University not found")

        # Search Wikipedia for the university
        search_url = "https://en.wikipedia.org/w/api.php"
        
        # First try to find the main campus image
        params = {
            "action": "query",
            "format": "json",
            "list": "search",
            "srsearch": f"{university.name} campus building main",
            "srlimit": 1
        }
        
        search_response = requests.get(search_url, params=params)
        search_response.raise_for_status()
        search_data = search_response.json()
        
        if not search_data.get("query", {}).get("search"):
            # If no campus image found, try a broader search
            params["srsearch"] = f"{university.name} university building"
            search_response = requests.get(search_url, params=params)
            search_response.raise_for_status()
            search_data = search_response.json()
            
            if not search_data.get("query", {}).get("search"):
                return {"image_url": "", "alt_text": "No image available"}
        
        page_title = search_data["query"]["search"][0]["title"]
        
        # Get images from the Wikipedia page
        image_params = {
            "action": "query",
            "format": "json",
            "prop": "images",
            "titles": page_title,
            "imlimit": 50  # Get more images to find the best one
        }
        
        image_response = requests.get(search_url, params=image_params)
        image_response.raise_for_status()
        image_data = image_response.json()
        
        # Get the page ID
        pages = image_data.get("query", {}).get("pages", {})
        if not pages:
            return {"image_url": "", "alt_text": "No image available"}
            
        page_id = list(pages.keys())[0]
        images = pages[page_id].get("images", [])
        
        if not images:
            return {"image_url": "", "alt_text": "No image available"}
            
        # Filter images to find the best campus/building photo
        building_keywords = ['campus', 'building', 'hall', 'library', 'main', 'center', 'university']
        filtered_images = [
            img for img in images 
            if any(keyword in img["title"].lower() for keyword in building_keywords)
        ]
        
        # If no building images found, use the first image
        target_image = filtered_images[0] if filtered_images else images[0]
            
        # Get the image URL
        image_url_params = {
            "action": "query",
            "format": "json",
            "prop": "imageinfo",
            "iiprop": "url",
            "titles": target_image["title"]
        }
        
        url_response = requests.get(search_url, params=image_url_params)
        url_response.raise_for_status()
        url_data = url_response.json()
        
        url_pages = url_data.get("query", {}).get("pages", {})
        if not url_pages:
            return {"image_url": "", "alt_text": "No image available"}
            
        url_page_id = list(url_pages.keys())[0]
        image_url = url_pages[url_page_id]["imageinfo"][0]["url"]
        
        return {
            "image_url": image_url,
            "alt_text": target_image["title"]
        }
    except requests.exceptions.RequestException as e:
        print(f"Error making request to Wikipedia: {e}")
        raise HTTPException(status_code=500, detail=f"Error fetching image from Wikipedia: {str(e)}")
    except Exception as e:
        print(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 