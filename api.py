from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy import create_engine, Column, Integer, String, Boolean, Float, Text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from typing import List
import pandas as pd
import os
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

@app.get("/universities/", response_model=List[dict])
def get_universities(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    universities = db.query(University).offset(skip).limit(limit).all()
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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 