# evaluacionu3

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Paquexpress – App Móvil para Repartidores

Aplicación móvil desarrollada en **Flutter**, diseñada para que los repartidores puedan consultar sus paquetes asignados, registrar entregas con **foto**, **coordenadas GPS** y enviarlas a un servidor mediante una API en FastAPI.

---

## 📑 Tabla de Contenido
- [Características](#-características)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación](#-instalación)
- [Configuración Android](#-configuración-android)
- [Ejecución del Proyecto](#-ejecución-del-proyecto)
- [Configuración del Servidor (API)](#-configuración-del-servidor-api)
- [Flujo de Uso](#-flujo-de-uso)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Problemas Comunes](#-problemas-comunes)
- [Licencia](#-licencia)

---

## 🚀 Características

- Inicio de sesión con correo y contraseña  
- Consulta de paquetes asignados a un usuario  
- Toma de foto desde la cámara  
- Obtención de ubicación GPS usando Geolocator  
- Vista previa antes de confirmar entrega (foto + mapa)  
- Integración con **Flutter Map** + MapTiler  
- Envío de foto + coordenadas mediante **multipart/form-data**  
- Notificaciones mediante SnackBars  
- Manejo de permisos (cámara y ubicación)

---

## 🛠 Requisitos Previos

Antes de instalar, asegúrate de tener:

### 🔧 Software necesario
- **Flutter 3.x o superior**
- **Visual Studio Code**
- **Dart SDK** (incluido con Flutter)
- Dispositivo Android físico (recomendado)
- Conexión a la misma red donde corre el servidor

### 🔌 Requisitos del backend
La API debe estar disponible en: http://192.168.X.X:8000/ 
Cambia por tu direccion, dicha direccion se puede consultar accediendo al **cmd** en **windows** y colocando
el comando **ipconfig**

## Instalación

#### 1️⃣ Clona el repositorio
```bash
git clone https://github.com/EvelynMi27/paquexpress.git
cd paquexpress
```
#### 2️⃣ Instala dependencias
```bash
flutter pub get
```
#### 📱 Configuracion en android
Accede al archivo de **androidManifest** ubicado en: android/app/src/main/AndroidManifest.xml
Y dentro coloca los siguientes permisos:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### ▶️ Ejecución del Proyecto
```bash
flutter run
```
### 🖥 Configuración del Servidor (API)
```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```
### 📲 Flujo de Uso
#### 1️⃣ Iniciar sesión
El repartidor ingresa:
**- Correo**
**- Contraseña**
Si es válido, la app redirige a Ver Paquetes.

#### 2️⃣ Ver paquetes asignados
Se muestran:
**- ID**
**- Nombre del paquete**
**- Dirección**
**- Botón de cámara para iniciar entrega**

#### 3️⃣ Tomar evidencia de entrega
La app:
**- Abre la cámara**
**- Permite capturar la fotografía**
Solicita permisos si es necesario

#### 4️⃣ Obtener ubicación GPS
El sistema obtiene:
**- Latitud**
**- Longitud**

#### 5️⃣ Vista previa
Antes de enviar, se muestra:
**- Foto tomada**
**- Mapa con marcador en la ubicación actual**
**- Botón: Confirmar entrega**

#### 6️⃣ Enviar entrega
Se envía al servidor:
**- Foto**
**- Coordenadas**
**- ID del paquete**
**- Si es exitoso, se muestra mensaje y se refresca la lista.**

### 🐞 Problemas Comunes
#### ❌ Error de conexión
**-Verifica IP del servidor**
**-Ambos dispositivos deben estar en la misma red**
**-Servidor FastAPI debe estar activo**

#### ❌ Cámara no abre
**-Revisa permisos de cámara en Android**
**-Prueba en un dispositivo físico**

#### ❌ GPS no obtiene ubicación
**-Activa ubicación del dispositivo**
**-Permite acceso a ubicación al abrir la app**

## Licencia
Proyecto de uso académico y personal.
No destinado para distribución comercial sin permisos.