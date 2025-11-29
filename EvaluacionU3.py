from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy import(
    create_engine,
    Column,
    Integer,
    String,
    TIMESTAMP,
    ForeignKey,
    DECIMAL,
)
from typing import List
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, Session
from pydantic import BaseModel
import hashlib
import requests
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import shutil
import os

app = FastAPI()
os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
DATABASE_URL="mysql+mysqlconnector://root:Holamun@localhost:3306/evaluacionu3"
engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(bind=engine)

Base = declarative_base()

class User(Base):
    __tablename__ = "usuarios"
    id_us=Column(Integer, primary_key=True)
    us_nom=Column(String(100))
    us_correo=Column(String(100))
    us_password_hash = Column(String(100))
class Entregas(Base):
    __tablename__ = "entregas"
    id_en = Column(Integer, primary_key=True)
    en_foto = Column(String(255), nullable=False)
    en_latitud = Column(DECIMAL(11,8), nullable=False)
    en_longitud = Column(DECIMAL(11,8), nullable=False)
    en_address= Column(String(255), nullable=False)
    id_paq=Column(Integer, ForeignKey("paquetes.id_paq"))
class Paquete(Base):
    __tablename__ = "paquetes"
    id_paq=Column(Integer, primary_key=True)
    paq_dir=Column(String(100), nullable=False)
    paq_nom=Column(String(100), nullable=False)
    id_us=Column(Integer, ForeignKey("usuarios.id_us"))

Base.metadata.create_all(bind=engine)
class UserSchema(BaseModel):
    us_nom:str
    us_correo:str
    us_password:str
class LoginSchema(BaseModel):
    us_correo: str
    us_password: str
class RegistroUserSchema(BaseModel):
    us_nom:str
    us_correo:str
    us_password_hash:str
class EntregasSchema(BaseModel):
    en_foto:str
    en_latitud:float
    en_longitud:float
    en_address:str
    id_paq:int
class PaquetesSchema(BaseModel):
    paq_dir:str
    paq_nom:str
    id_us:int
class UserOut(BaseModel):
    id_us:int
    us_nom:str
    us_correo:str
    us_password_hash:str
    class Config:
        from_attributes = True
class EntregasOut(BaseModel):
    id_en:int
    en_foto:str
    en_latitud:float
    en_longitud:float
    en_address:str
    id_paq:int
    class Config:
        from_attributes = True
class PaqueteOut(BaseModel):
    id_paq:int
    paq_dir:str
    paq_nom:str
    id_us:int
    class Config:
        from_attributes = True
#Dependencia DB
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

#Funcion para encriptar con MD5
def md5_hash(us_password: str) -> str:
    return hashlib.md5(us_password.encode()).hexdigest()
@app.post("/registro/paquetes", response_model=PaqueteOut)
def crear_paquetes(datos: PaquetesSchema, db: Session=Depends(get_db)):
    nuevo = Paquete(**datos.dict())
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo
@app.get("/mostrar/paquetes/{id_us}", response_model=List[PaqueteOut])
def mostrar_paquetes(id_us: int, db: Session=Depends(get_db)):
    resultado = db.query(Paquete).filter(Paquete.id_us == id_us).all()
    if not resultado:
        raise HTTPException(status_code=404, detail="No se encontraron paquetes para este usuario")
    return resultado
@app.post("/registro/usuario", response_model=UserOut)
def crear_usuario(datos: UserSchema, db:Session=Depends(get_db)):
    existe=db.query(User).filter(User.us_correo == datos.us_correo).first()
    if existe:
        raise HTTPException(status_code=400, detail="El correo ya esta registrado")
    password_hash = md5_hash(datos.us_password)
    nuevo = User(
        us_nom=datos.us_nom,
        us_correo=datos.us_correo,
        us_password_hash=password_hash,
    )
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo
@app.get("/mostrar/usuario/{id_us}", response_model=UserOut)
def mostrar_usuario(id_us: int, db:Session=Depends(get_db)):
    resultado = db.query(User).filter(User.id_us == id_us).all()
    if not resultado:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return resultado
@app.put("/registro/usuario/{id_us}", response_model=UserOut)
def actualizar_usuario(id_us: int, datos: UserSchema, db:Session=Depends(get_db)):
    usuario = db.query(User).filter(User.id_us == id_us).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    password_hash = md5_hash(datos.us_password)
    datos_actualizados= {
        'us_nom': datos.us_nom,
        'us_correo': datos.us_correo,
        'us_password_hash':password_hash
    }
    for key, value in datos_actualizados.items():
        setattr(usuario, key, value)
    db.commit()
    db.refresh(usuario)
    return usuario
@app.post("/login")
def login(datos: LoginSchema, db: Session=Depends(get_db)):
    password_hash = md5_hash(datos.us_password)
    usuario=db.query(User).filter(
        User.us_correo == datos.us_correo,
        User.us_password_hash == password_hash
    ).first()
    if not usuario:
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")
    return{
        "mensaje":"Login exitoso",
        "usuario":{
            "id_us":usuario.id_us,
            "us_nom":usuario.us_nom,
            "us_correo":usuario.us_correo
        }
    }
@app.post("/registro/entrega")
async def crear_entrega(
        id_paq: int = Form(...),
        en_latitud:float=Form(...),
        en_longitud:float=Form(...),
        file:UploadFile=File(...),
        db:Session=Depends(get_db),
):
    try:
        paquete=db.query(Paquete).filter(Paquete.id_paq == id_paq).first()
        if not paquete:
            raise HTTPException(status_code=404, detail="Paquete no encontrado")
        dir=f"uploads/{file.filename}"
        os.makedirs("uploads", exist_ok=True)
        with open(dir, "wb") as f:
            shutil.copyfileobj(file.file, f)
        url=f"https://nominatim.openstreetmap.org/reverse?format=json&lat={en_latitud}&lon={en_longitud}"
        headers = {"User-Agent":"FastAPIApp/1.0"}
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            result=response.json()
            en_address=result.get("display_name", "Direccion no disponible")
        else:
            en_address="Error al obtener direccion"
        nueva_en=Entregas(
            en_foto=dir,
            en_latitud=en_latitud,
            en_longitud=en_longitud,
            en_address=en_address,
            id_paq=id_paq
        )
        db.add(nueva_en)
        db.commit()
        db.refresh(nueva_en)
        return{
            "mensaje":"Entrega registrada exitosamente",
            "entrega":{
                "id_en":nueva_en.id_en,
                "en_foto":nueva_en.en_foto,
                "en_latitud":float(nueva_en.en_latitud),
                "en_longitud":float(nueva_en.en_longitud),
                "en_address":nueva_en.en_address,
                "id_paq":nueva_en.id_paq
            }
        }
    except HTTPException as he:
        raise he
    except Exception as e:
        print("Error interno:",str(e))
        raise HTTPException(status_code=500, detail=f"Error interno:{str(e)}")

@app.get("/listar/entregas/")
def listar_entregas(db:Session=Depends(get_db)):
    resultado = db.query(Entregas).all()
    if not resultado:
        raise HTTPException(status_code=404, detail="No hay entregas")
    return resultado