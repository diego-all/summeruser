-- --------------------------------------------------------
-- Host:                 summer.c87semo4ses5.us-east-1.rds.amazonaws.com
-- Versión del servidor: 8.0.45 - Source distribution
-- SO del servidor:      Linux
-- Base de Datos:        summer
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Volcando estructura de base de datos para summer
CREATE DATABASE IF NOT EXISTS `summer` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `summer`;

-- Volcando estructura para tabla summer.addresses
CREATE TABLE IF NOT EXISTS `addresses` (
  `Add_Id` int unsigned NOT NULL AUTO_INCREMENT,
  `Add_UserID` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `Add_Address` varchar(100) DEFAULT NULL,
  `Add_City` varchar(50) DEFAULT NULL,
  `Add_State` varchar(50) DEFAULT NULL,
  `Add_PostalCode` varchar(10) DEFAULT NULL,
  `Add_Phone` varchar(40) DEFAULT NULL,
  `Add_Title` varchar(50) DEFAULT NULL,
  `Add_Name` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`Add_Id`),
  KEY `Add_UserID` (`Add_UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla summer.category
CREATE TABLE IF NOT EXISTS `category` (
  `Categ_Id` int unsigned NOT NULL AUTO_INCREMENT,
  `Categ_Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `Categ_Path` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`Categ_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla summer.orders
CREATE TABLE IF NOT EXISTS `orders` (
  `Order_Id` int unsigned NOT NULL AUTO_INCREMENT,
  `Order_UserUUID` char(36) DEFAULT NULL,
  `Order_AddId` int unsigned DEFAULT NULL,
  `Order_Date` datetime DEFAULT CURRENT_TIMESTAMP,
  `Order_Total` decimal(20,2) DEFAULT '0.00',
  PRIMARY KEY (`Order_Id`) USING BTREE,
  KEY `Order_Date` (`Order_Date`),
  KEY `Order_UserId` (`Order_UserUUID`) USING BTREE,
  KEY `Order_AddId` (`Order_AddId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla summer.orders_detail
CREATE TABLE IF NOT EXISTS `orders_detail` (
  `OD_Id` int unsigned NOT NULL AUTO_INCREMENT,
  `OD_OrderId` int unsigned NOT NULL,
  `OD_ProdId` int unsigned NOT NULL,
  `OD_Quantity` mediumint unsigned NOT NULL DEFAULT '0',
  `OD_Price` decimal(20,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`OD_Id`) USING BTREE,
  KEY `ODetail_OrderId` (`OD_OrderId`),
  KEY `OD_ProdId` (`OD_ProdId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla summer.products
CREATE TABLE IF NOT EXISTS `products` (
  `Prod_Id` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID del Producto',
  `Prod_Title` varchar(100) NOT NULL COMMENT 'Titulo del producto, se mostrará como nombre del producto',
  `Prod_Description` varchar(6500) DEFAULT NULL COMMENT 'Descripción del producto, detalle de las características del Producto',
  `Prod_CreatedAt` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación',
  `Prod_Updated` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de actualización',
  `Prod_Price` decimal(20,2) NOT NULL DEFAULT '0.00' COMMENT 'Precio del producto',
  `Prod_Path` varchar(100) DEFAULT NULL,
  `Prod_CategoryId` mediumint DEFAULT NULL,
  `Prod_Stock` int DEFAULT '0',
  PRIMARY KEY (`Prod_Id`),
  KEY `Prod_CreatedAt` (`Prod_CreatedAt`),
  KEY `Prod_Updated` (`Prod_Updated`),
  KEY `Prod_CategoryId` (`Prod_CategoryId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla summer.users
CREATE TABLE IF NOT EXISTS `users` (
  `User_UUID` char(36) NOT NULL,
  `User_Email` varchar(100) NOT NULL DEFAULT '',
  `User_FirstName` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `User_LastName` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `User_Status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '''0'' Admin',
  `User_DateAdd` datetime NOT NULL,
  `User_DateUpg` datetime DEFAULT NULL,
  PRIMARY KEY (`User_UUID`),
  UNIQUE KEY `User_Email` (`User_Email`),
  KEY `User_DateAdd` (`User_DateAdd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- La exportación de datos fue deseleccionada.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;