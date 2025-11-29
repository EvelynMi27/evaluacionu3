CREATE DATABASE  IF NOT EXISTS `evaluacionu3` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `evaluacionu3`;
-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: evaluacionu3
-- ------------------------------------------------------
-- Server version	9.3.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `entregas`
--

DROP TABLE IF EXISTS `entregas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entregas` (
  `id_en` int NOT NULL AUTO_INCREMENT,
  `en_foto` varchar(255) DEFAULT NULL,
  `en_latitud` decimal(11,8) DEFAULT NULL,
  `en_longitud` decimal(11,8) DEFAULT NULL,
  `id_paq` int DEFAULT NULL,
  `en_address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_en`),
  KEY `id_paq` (`id_paq`),
  CONSTRAINT `entregas_ibfk_1` FOREIGN KEY (`id_paq`) REFERENCES `paquetes` (`id_paq`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entregas`
--

LOCK TABLES `entregas` WRITE;
/*!40000 ALTER TABLE `entregas` DISABLE KEYS */;
INSERT INTO `entregas` VALUES (1,'uploads/entrega_1764434259710.jpg',20.59245840,-100.40320550,2,'Calle Jaime Nunó, Centro, Delegación Centro Histórico, Santiago de Querétaro, Municipio de Querétaro, Querétaro, 76000, México'),(2,'uploads/entrega_1764434770303.jpg',20.59244760,-100.40319490,1,'Calle Jaime Nunó, Centro, Delegación Centro Histórico, Santiago de Querétaro, Municipio de Querétaro, Querétaro, 76000, México'),(3,'uploads/entrega_1764438059939.jpg',20.59244770,-100.40319990,1,'Calle Jaime Nunó, Centro, Delegación Centro Histórico, Santiago de Querétaro, Municipio de Querétaro, Querétaro, 76000, México');
/*!40000 ALTER TABLE `entregas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paquetes`
--

DROP TABLE IF EXISTS `paquetes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paquetes` (
  `id_paq` int NOT NULL AUTO_INCREMENT,
  `paq_dir` varchar(100) NOT NULL,
  `paq_nom` varchar(100) NOT NULL,
  `id_us` int NOT NULL,
  PRIMARY KEY (`id_paq`),
  KEY `id_us` (`id_us`),
  CONSTRAINT `paquetes_ibfk_1` FOREIGN KEY (`id_us`) REFERENCES `usuarios` (`id_us`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paquetes`
--

LOCK TABLES `paquetes` WRITE;
/*!40000 ALTER TABLE `paquetes` DISABLE KEYS */;
INSERT INTO `paquetes` VALUES (1,'Jose Maria Morelos 202','Revistas de divulgacion cientifica',2),(2,'Mariano Escobedo 185','Silla gamer',1);
/*!40000 ALTER TABLE `paquetes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_us` int NOT NULL AUTO_INCREMENT,
  `us_nom` varchar(100) NOT NULL,
  `us_correo` varchar(100) NOT NULL,
  `us_password_hash` varchar(100) NOT NULL,
  PRIMARY KEY (`id_us`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Arturo','arturo@example.com','827ccb0eea8a706c4c34a16891f84e7b'),(2,'Gonzalo','gonzalo@example.com','c37bf859faf392800d739a41fe5af151');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-29 11:59:39
