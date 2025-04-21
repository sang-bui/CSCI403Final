from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, text
from typing import List, Optional
import os

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Database connection
DATABASE_URL = "postgres://sang_bui@ada.mines.edu/csci403"
engine = create_engine(DATABASE_URL)

@app.get("/universities/")
async def get_universities(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    search: Optional[str] = None,
    min_score: Optional[float] = None,
    max_students: Optional[int] = None,
    country: Optional[str] = None,
):
    query = """
        SELECT name, country, teaching, international, research, 
               citations, income, total_score, num_students, 
               student_staff_ratio, international_students, female_male_ratio
        FROM universities
        WHERE 1=1
    """
    params = {}
    
    if search:
        query += " AND name ILIKE :search"
        params["search"] = f"%{search}%"
    
    if country:
        query += " AND country = :country"
        params["country"] = country
    
    if min_score is not None:
        query += " AND total_score >= :min_score"
        params["min_score"] = min_score
    
    if max_students is not None:
        query += " AND num_students <= :max_students"
        params["max_students"] = max_students
    
    query += " ORDER BY total_score DESC LIMIT :limit OFFSET :skip"
    params["limit"] = limit
    params["skip"] = skip
    
    try:
        with engine.connect() as conn:
            result = conn.execute(text(query), params)
            universities = [dict(row) for row in result]
            return universities
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/universities/{name}")
async def get_university(name: str):
    query = """
        SELECT name, country, teaching, international, research, 
               citations, income, total_score, num_students, 
               student_staff_ratio, international_students, female_male_ratio
        FROM universities
        WHERE name = :name
    """
    try:
        with engine.connect() as conn:
            result = conn.execute(text(query), {"name": name})
            university = result.first()
            if university is None:
                raise HTTPException(status_code=404, detail="University not found")
            return dict(university)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/countries/")
async def get_countries():
    query = """
        SELECT DISTINCT country 
        FROM universities 
        WHERE country IS NOT NULL 
        ORDER BY country
    """
    try:
        with engine.connect() as conn:
            result = conn.execute(text(query))
            countries = [row[0] for row in result]
            return countries
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/stats/")
async def get_stats():
    query = """
        SELECT 
            COUNT(*) as total_universities,
            AVG(total_score) as avg_score,
            MAX(total_score) as max_score,
            MIN(total_score) as min_score,
            AVG(num_students) as avg_students,
            COUNT(DISTINCT country) as total_countries
        FROM universities
    """
    try:
        with engine.connect() as conn:
            result = conn.execute(text(query))
            stats = dict(result.first())
            return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 