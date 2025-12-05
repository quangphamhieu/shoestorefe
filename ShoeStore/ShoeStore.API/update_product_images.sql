SET QUOTED_IDENTIFIER ON;
GO

-- Nike Air Max 90 (IDs: 2, 8, 9, 10)
UPDATE Products 
SET ImageUrl = 'https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/zwxes8uud05rkuei1mpt/air-max-90-shoes-kRsBnD.png'
WHERE Id IN (2, 8, 9, 10);

-- Nike Air Force 1 (IDs: 3, 11, 12)
UPDATE Products 
SET ImageUrl = 'https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/b7d9211c-26e7-431a-ac24-b0540fb3c00f/air-force-1-07-shoes-WrLlWX.png'
WHERE Id IN (3, 11, 12);

-- Adidas Ultraboost (IDs: 4, 13, 14)
UPDATE Products 
SET ImageUrl = 'https://assets.adidas.com/images/h_840,f_auto,q_auto,fl_lossy,c_fill,g_auto/fbaf991a78bc4896a3e9ad7800abcec6_9366/Ultraboost_Light_Shoes_White_GY9350_01_standard.jpg'
WHERE Id IN (4, 13, 14);

-- Adidas Stan Smith (ID: 5)
UPDATE Products 
SET ImageUrl = 'https://assets.adidas.com/images/h_840,f_auto,q_auto,fl_lossy,c_fill,g_auto/5f41f5aad4984da7a0c4a8bf01187e0c_9366/Stan_Smith_Shoes_White_FX5500_01_standard.jpg'
WHERE Id = 5;

-- Puma RS-X (ID: 6)
UPDATE Products 
SET ImageUrl = 'https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_600,h_600/global/380462/01/sv01/fnd/PNA/fmt/png/RS-X-Efekt-Prm-Sneakers'
WHERE Id = 6;

-- Puma Suede Classic (ID: 7)
UPDATE Products 
SET ImageUrl = 'https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_600,h_600/global/374915/01/sv01/fnd/PNA/fmt/png/Suede-Classic-XXI-Sneakers'
WHERE Id = 7;

GO

-- Verify updates
SELECT Id, Name, 
       CASE 
           WHEN LEN(ImageUrl) > 60 THEN LEFT(ImageUrl, 60) + '...'
           ELSE ImageUrl 
       END as ImageUrl
FROM Products 
WHERE Id BETWEEN 2 AND 14 
ORDER BY Id;
