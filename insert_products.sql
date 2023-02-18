INSERT INTO brand.brands VALUES ('AKKO');
INSERT INTO brand.brands VALUES ('Royal Kludge');
INSERT INTO brand.brands VALUES ('Razer');
INSERT INTO brand.brands VALUES ('Logitech');

INSERT INTO product.general_specs VALUES ('3456 x 2160', 'display_resolution', '3456_2160', 'Quad HD+ (3.5K)', 'Laptop', 36);
INSERT INTO product.general_specs VALUES ('Intel® Core™ i7', 'cpu_model', 'i7_1355u', 'i7 - 1355U, 10C/12T, 3.70GHz up to 5.00GHz, 12MB Cache, 12W', 'Laptop', 37);
INSERT INTO product.general_specs VALUES ('1920 x 1080', 'display_resolution', '1920_1080', 'Full HD (1080p)', 'Monitor', 38);
INSERT INTO product.general_specs VALUES ('2560_1440', 'display_resolution', '2560_1440', 'Quad HD+ (2K)', 'Monitor', 39);
INSERT INTO product.general_specs VALUES ('3840 x 2160', 'display_resolution', '3840_2160', 'Ultra HD (4K)', 'Monitor', 40);
INSERT INTO product.general_specs VALUES ('18 inch', 'display_size', '18_inch', '18 inch', 'Monitor', 41);
INSERT INTO product.general_specs VALUES ('24 inch', 'display_size', '24_inch', '24 inch', 'Monitor', 42);
INSERT INTO product.general_specs VALUES ('Cherry MX Red', 'switch_type', 'cherry_mx_red', 'Cherry MX Red', 'Keyboard', 43);
INSERT INTO product.general_specs VALUES ('Cherry MX Blue', 'switch_type', 'cherry_mx_blue', 'Cherry MX Blue', 'Keyboard', 44);
INSERT INTO product.general_specs VALUES ('Cherry MX Brown', 'switch_type', 'cherry_mx_brown', 'Cherry MX Brown', 'Keyboard', 45);
INSERT INTO product.general_specs VALUES ('2 kg', 'weight', '2_kg', '2 kg', 'Keyboard', 46);
INSERT INTO product.general_specs values ('3 kg', 'weight', '3_kg', '3 kg', 'Keyboard', 47);
INSERT INTO product.general_specs VALUES ('Black', 'color', 'black', 'Black', 'Keyboard', 48);
INSERT INTO product.general_specs VALUES ('White', 'color', 'white', 'White', 'Keyboard', 49);
INSERT INTO product.general_specs VALUES ('Wired', 'connection_type', 'wired', 'Wired', 'Keyboard', 50);
INSERT INTO product.general_specs VALUES ('Bluetooth', 'connection_type', 'bluetooth', 'Bluetooth', 'Keyboard', 51);
INSERT INTO product.general_specs VALUES ('USB', 'connection_type', 'usb', 'USB', 'Keyboard', 52);
INSERT INTO product.general_specs VALUES ('Bluetooth', 'connection_type', 'bluetooth', 'Bluetooth', 'Mouse', 53);
INSERT INTO product.general_specs VALUES ('USB', 'connection_type', 'usb', 'USB', 'Mouse', 54);
INSERT INTO product.general_specs VALUES ('Wired', 'connection_type', 'wired', 'Wired', 'Mouse', 55);
INSERT INTO product.general_specs VALUES ('Black', 'color', 'black', 'Black', 'Mouse', 56);
INSERT INTO product.general_specs VALUES ('White', 'color', 'white', 'White', 'Mouse', 57);
INSERT INTO product.general_specs VALUES ('20 hours', 'battery_life', '20_hours', '20 hours', 'Mouse', 58);
INSERT INTO product.general_specs VALUES ('30 hours', 'battery_life', '30_hours', '30 hours', 'Mouse', 59);


INSERT INTO product.products VALUES (1, 'Dell', 'Inspiron 3593', 'Laptop', 21790000, NULL, NULL);
INSERT INTO product.products VALUES (2, 'Dell', 'Vostro 3520', 'Laptop', 13490000, NULL, NULL);
INSERT INTO product.products VALUES (3, 'Dell', 'XPS 13', 'Laptop', 57990000, NULL, NULL);
INSERT INTO product.products VALUES (4, 'Dell', 'Inspiron 5620', 'Laptop', 27990000, NULL, NULL);
INSERT INTO product.products VALUES (5, 'Dell', 'Vostro 5320', 'Laptop', 19990000, NULL, NULL);
INSERT INTO product.products VALUES (6, 'Acer', 'Aspire A315', 'Laptop', 11990000, NULL, NULL);
INSERT INTO product.products VALUES (7, 'Acer', 'Swift F314', 'Laptop', 20990000, NULL, NULL);
INSERT INTO product.products VALUES (8, 'HP', 'Pavillion 1456', 'Laptop', 16990000, NULL, NULL);
INSERT INTO product.products VALUES (9, 'HP', 'Envy 1536', 'Laptop', 21990000, NULL, NULL);
INSERT INTO product.products VALUES (10, 'Asus', 'VA24DQLB', 'Monitor', 4490000, NULL, NULL);
INSERT INTO product.products VALUES (11, 'Samsung', 'LS2580', 'Monitor', 9150000, NULL, NULL);
INSERT INTO product.products VALUES (12, 'AKKO', 'ACR 68', 'Keyboard', 2550000, NULL, NULL);
INSERT INTO product.products VALUES (13, 'Royal Kludge', 'RK A30', 'Keyboard', 1090000, NULL, NULL);
INSERT INTO product.products VALUES (14, 'Razer', 'Deathadder', 'Mouse', 500000, NULL, NULL);
INSERT INTO product.products VALUES (15, 'Logitech', 'G1106', 'Mouse', 950000, NULL, NULL);



INSERT INTO product.product_specs VALUES (2, 6);
INSERT INTO product.product_specs VALUES (2, 13);
INSERT INTO product.product_specs VALUES (2, 15);
INSERT INTO product.product_specs VALUES (2, 19);
INSERT INTO product.product_specs VALUES (2, 25);

INSERT INTO product.product_specs VALUES (3, 4);
INSERT INTO product.product_specs VALUES (3, 36);
INSERT INTO product.product_specs VALUES (3, 16);
INSERT INTO product.product_specs VALUES (3, 20);
INSERT INTO product.product_specs VALUES (3, 31);

INSERT INTO product.product_specs VALUES (4, 7);
INSERT INTO product.product_specs VALUES (4, 13);
INSERT INTO product.product_specs VALUES (4, 16);
INSERT INTO product.product_specs VALUES (4, 19);
INSERT INTO product.product_specs VALUES (4, 31);

INSERT INTO product.product_specs VALUES (5, 4);
INSERT INTO product.product_specs VALUES (5, 11);
INSERT INTO product.product_specs VALUES (5, 15);
INSERT INTO product.product_specs VALUES (5, 19);
INSERT INTO product.product_specs VALUES (5, 28);

INSERT INTO product.product_specs VALUES (6, 5);
INSERT INTO product.product_specs VALUES (6, 10);
INSERT INTO product.product_specs VALUES (6, 15);
INSERT INTO product.product_specs VALUES (6, 18);
INSERT INTO product.product_specs VALUES (6, 25);

INSERT INTO product.product_specs VALUES (7, 6);
INSERT INTO product.product_specs VALUES (7, 9);
INSERT INTO product.product_specs VALUES (7, 15);
INSERT INTO product.product_specs VALUES (7, 19);
INSERT INTO product.product_specs VALUES (7, 28);

INSERT INTO product.product_specs VALUES (8, 5);
INSERT INTO product.product_specs VALUES (8, 11);
INSERT INTO product.product_specs VALUES (8, 15);
INSERT INTO product.product_specs VALUES (8, 20);
INSERT INTO product.product_specs VALUES (8, 37);

INSERT INTO product.product_specs VALUES (9, 6);
INSERT INTO product.product_specs VALUES (9, 11);
INSERT INTO product.product_specs VALUES (9, 15);
INSERT INTO product.product_specs VALUES (9, 19);
INSERT INTO product.product_specs VALUES (9, 37);

INSERT INTO product.product_specs VALUES (10, 38);
INSERT INTO product.product_specs VALUES (10, 41);

INSERT INTO product.product_specs VALUES (11, 39);
INSERT INTO product.product_specs VALUES (11, 42);

INSERT INTO product.product_specs VALUES (12, 43);
INSERT INTO product.product_specs VALUES (12, 46);
INSERT INTO product.product_specs VALUES (12, 48);
INSERT INTO product.product_specs VALUES (12, 50);

INSERT INTO product.product_specs VALUES (13, 45);
INSERT INTO product.product_specs VALUES (13, 47);
INSERT INTO product.product_specs VALUES (13, 49);
INSERT INTO product.product_specs VALUES (13, 51);

INSERT INTO product.product_specs VALUES (14, 53);
INSERT INTO product.product_specs VALUES (14, 56);
INSERT INTO product.product_specs VALUES (14, 58);

INSERT INTO product.product_specs VALUES (15, 54);
INSERT INTO product.product_specs VALUES (15, 57);
INSERT INTO product.product_specs VALUES (15, 59);



