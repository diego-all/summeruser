SET NAMES utf8mb4;
USE `summer`;

-- ----------------------------------------------------------
-- Categorías
-- ----------------------------------------------------------
INSERT INTO category (Categ_Id, Categ_Name, Categ_Path) VALUES
  (1, 'Categoría A', 'categoria-a'),
  (2, 'Categoría B', 'categoria-b'),
  (3, 'Categoría C', 'categoria-c'),
  (4, 'Categoría D', 'categoria-d')
ON DUPLICATE KEY UPDATE
  Categ_Name = VALUES(Categ_Name),
  Categ_Path = VALUES(Categ_Path);

-- ----------------------------------------------------------
-- Productos
-- ----------------------------------------------------------
INSERT INTO products
  (Prod_Id, Prod_Title, Prod_Description, Prod_Price, Prod_Path, Prod_CategoryId, Prod_Stock)
VALUES
  (1,  'Producto 1',  'Descripción de ejemplo del producto 1.',  10000.00, 'producto-1',  1, 10),
  (2,  'Producto 2',  'Descripción de ejemplo del producto 2.',  20000.00, 'producto-2',  1, 20),
  (3,  'Producto 3',  'Descripción de ejemplo del producto 3.',  30000.00, 'producto-3',  1, 30),
  (4,  'Producto 4',  'Descripción de ejemplo del producto 4.',  40000.00, 'producto-4',  2, 15),
  (5,  'Producto 5',  'Descripción de ejemplo del producto 5.',  50000.00, 'producto-5',  2, 25),
  (6,  'Producto 6',  'Descripción de ejemplo del producto 6.',  60000.00, 'producto-6',  2, 35),
  (7,  'Producto 7',  'Descripción de ejemplo del producto 7.',  70000.00, 'producto-7',  3, 12),
  (8,  'Producto 8',  'Descripción de ejemplo del producto 8.',  80000.00, 'producto-8',  3, 22),
  (9,  'Producto 9',  'Descripción de ejemplo del producto 9.',  90000.00, 'producto-9',  3, 32),
  (10, 'Producto 10', 'Descripción de ejemplo del producto 10.', 100000.00, 'producto-10', 4, 8),
  (11, 'Producto 11', 'Descripción de ejemplo del producto 11.', 110000.00, 'producto-11', 4, 18),
  (12, 'Producto 12', 'Descripción de ejemplo del producto 12.', 120000.00, 'producto-12', 4, 28)
ON DUPLICATE KEY UPDATE
  Prod_Title       = VALUES(Prod_Title),
  Prod_Description = VALUES(Prod_Description),
  Prod_Price       = VALUES(Prod_Price),
  Prod_Path        = VALUES(Prod_Path),
  Prod_CategoryId  = VALUES(Prod_CategoryId),
  Prod_Stock       = VALUES(Prod_Stock);