from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import secrets

app = FastAPI()

USERS = {
    "admin": "admin",
    "user@gmail.com": "user"
}

SESSIONS = {}

class AuthRequest(BaseModel):
    email: str
    password: str

@app.get("/")
def root():
    return {"ok": True, "message": "Backend działa"}

@app.post("/register")
def register(body: AuthRequest):
    email = body.email.strip().lower()
    password = body.password

    if not email or not password:
        raise HTTPException(status_code=400, detail="Brak email lub hasła")

    if email in USERS:
        raise HTTPException(status_code=409, detail="Taki uzytkownik już istnieje")

    USERS[email] = password
    return {"ok": True}

@app.post("/login")
def login(body: AuthRequest):
    email = body.email.strip().lower()
    password = body.password

    if email not in USERS or USERS[email] != password:
        raise HTTPException(status_code=401, detail="Niepoprawny email lub hasło")

    token = secrets.token_hex(16)
    SESSIONS[token] = email
    return {"token": token}