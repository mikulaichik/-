-- Магазин обуви «Лапа»: схема и данные (MySQL 8)
CREATE SCHEMA IF NOT EXISTS `lapa_shoes` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `lapa_shoes`;

CREATE TABLE IF NOT EXISTS `lapa_shoes`.`categories` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `lapa_shoes`.`manufacturers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `lapa_shoes`.`suppliers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `lapa_shoes`.`roles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `lapa_shoes`.`orderstatus` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `lapa_shoes`.`users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(60) NOT NULL,
  `login` VARCHAR(50) NOT NULL,
  `password` VARCHAR(30) NOT NULL,
  `role_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_users_role_idx` (`role_id` ASC) VISIBLE,
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `lapa_shoes`.`roles` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `lapa_shoes`.`pvz` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `postcode` CHAR(6) NOT NULL,
  `city` VARCHAR(30) NOT NULL,
  `street` VARCHAR(30) NOT NULL,
  `house` VARCHAR(5) NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `lapa_shoes`.`products` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `article` VARCHAR(10) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `unit` VARCHAR(10) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `discount` INT NOT NULL,
  `stock_qty` INT NOT NULL,
  `description` VARCHAR(255) NULL,
  `photo` VARCHAR(50) NULL,
  `category_id` INT NOT NULL,
  `manufacturer_id` INT NOT NULL,
  `supplier_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_products_category_idx` (`category_id` ASC) VISIBLE,
  INDEX `fk_products_manufacturer_idx` (`manufacturer_id` ASC) VISIBLE,
  INDEX `fk_products_supplier_idx` (`supplier_id` ASC) VISIBLE,
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `lapa_shoes`.`categories` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_products_manufacturer` FOREIGN KEY (`manufacturer_id`) REFERENCES `lapa_shoes`.`manufacturers` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_products_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `lapa_shoes`.`suppliers` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `lapa_shoes`.`orders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_date` DATETIME NOT NULL,
  `delivery_date` DATETIME NULL,
  `pvz_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `receive_code` VARCHAR(10) NOT NULL,
  `status_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_orders_pvz_idx` (`pvz_id` ASC) VISIBLE,
  INDEX `fk_orders_user_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_orders_status_idx` (`status_id` ASC) VISIBLE,
  CONSTRAINT `fk_orders_pvz` FOREIGN KEY (`pvz_id`) REFERENCES `lapa_shoes`.`pvz` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `lapa_shoes`.`users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_status` FOREIGN KEY (`status_id`) REFERENCES `lapa_shoes`.`orderstatus` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `lapa_shoes`.`prodorders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `qty` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_prodorders_order_idx` (`order_id` ASC) VISIBLE,
  INDEX `fk_prodorders_product_idx` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_prodorders_order` FOREIGN KEY (`order_id`) REFERENCES `lapa_shoes`.`orders` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_prodorders_product` FOREIGN KEY (`product_id`) REFERENCES `lapa_shoes`.`products` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;
