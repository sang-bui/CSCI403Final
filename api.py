from fastapi import FastAPI, HTTPException, Query, Depends
from sqlalchemy import create_engine, Column, Integer, String, Float, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from typing import List, Optional
from pydantic import BaseModel

# Database connection
DATABASE_URL = "postgresql://thai_tran:Grayravnes.1265@ada.mines.edu:5432/csci403"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# SQLAlchemy Model
class University(Base):
    __tablename__ = "University_Merged"

    name = Column(String, primary_key=True)
    country = Column(String)
    teaching = Column(Float)
    international = Column(Float)
    research = Column(Float)
    citations = Column(Float)
    income = Column(Float)
    total_score = Column(Float)
    num_students = Column(Integer)
    student_staff_ratio = Column(Float)
    international_students = Column(Float)
    female_male_ratio = Column(Float)

# Pydantic model for response
class UniversityResponse(BaseModel):
    name: str
    country: Optional[str]
    teaching: Optional[float]
    international: Optional[float]
    research: Optional[float]
    citations: Optional[float]
    income: Optional[float]
    total_score: Optional[float]
    num_students: Optional[int]
    student_staff_ratio: Optional[float]
    international_students: Optional[float]
    female_male_ratio: Optional[float]

    class Config:
        orm_mode = True

app = FastAPI()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def read_root():
    return {"message": "College Search API"}

@app.get("/universities/", response_model=List[UniversityResponse])
def read_universities(
    skip: int = 0,
    limit: int = 10,
    search: Optional[str] = None,
    min_score: Optional[float] = None,
    max_students: Optional[int] = None,
    country: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(University)
    
    if search:
        query = query.filter(University.name.ilike(f"%{search}%"))
    if min_score:
        query = query.filter(University.total_score >= min_score)
    if max_students:
        query = query.filter(University.num_students <= max_students)
    if country:
        query = query.filter(University.country == country)
    
    universities = query.offset(skip).limit(limit).all()
    return universities

@app.get("/universities/{university_name}", response_model=UniversityResponse)
def read_university(university_name: str, db: Session = Depends(get_db)):
    university = db.query(University).filter(University.name == university_name).first()
    if university is None:
        raise HTTPException(status_code=404, detail="University not found")
    return university

@app.get("/countries/")
def read_countries(db: Session = Depends(get_db)):
    countries = db.query(University.country).distinct().all()
    return [country[0] for country in countries if country[0]]

@app.get("/stats/")
def get_stats(db: Session = Depends(get_db)):
    total_universities = db.query(University).count()
    avg_score = db.query(func.avg(University.total_score)).scalar()
    avg_students = db.query(func.avg(University.num_students)).scalar()
    
    return {
        "total_universities": total_universities,
        "average_score": round(avg_score, 2) if avg_score else None,
        "average_students": round(avg_students, 2) if avg_students else None
    }





