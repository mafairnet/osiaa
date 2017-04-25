-- MySQL Script generated by MySQL Workbench
-- 04/25/17 17:55:11
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema osiaa_epm
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema osiaa_epm
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `osiaa_epm` DEFAULT CHARACTER SET utf8 ;
USE `osiaa_epm` ;

-- -----------------------------------------------------
-- Table `osiaa_epm`.`brand`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `osiaa_epm`.`brand` (
  `id` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `osiaa_epm`.`model`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `osiaa_epm`.`model` (
  `id` INT NOT NULL,
  `brand` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`, `brand`),
  INDEX `fk_model_brand_idx` (`brand` ASC),
  CONSTRAINT `fk_model_brand`
    FOREIGN KEY (`brand`)
    REFERENCES `osiaa_epm`.`brand` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `osiaa_epm`.`technology`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `osiaa_epm`.`technology` (
  `id` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `osiaa_epm`.`phone`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `osiaa_epm`.`phone` (
  `id` INT NOT NULL,
  `model` INT NOT NULL,
  `brand` INT NOT NULL,
  `technology` INT NOT NULL,
  `mac` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_phone_model1_idx` (`model` ASC, `brand` ASC),
  INDEX `fk_phone_technology1_idx` (`technology` ASC),
  CONSTRAINT `fk_phone_model1`
    FOREIGN KEY (`model` , `brand`)
    REFERENCES `osiaa_epm`.`model` (`id` , `brand`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_phone_technology1`
    FOREIGN KEY (`technology`)
    REFERENCES `osiaa_epm`.`technology` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `osiaa_epm`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `osiaa_epm`.`user` (
  `id` INT NOT NULL,
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `osiaa_epm`.`pbx`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `osiaa_epm`.`pbx` (
  `id` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `pbx_ip` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `osiaa_epm`.`line`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `osiaa_epm`.`line` (
  `id` INT NOT NULL,
  `extension` VARCHAR(45) NOT NULL,
  `description` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `pbx_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_line_pbx1_idx` (`pbx_id` ASC),
  CONSTRAINT `fk_line_pbx1`
    FOREIGN KEY (`pbx_id`)
    REFERENCES `osiaa_epm`.`pbx` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `osiaa_epm`.`sccp_line`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `osiaa_epm`.`sccp_line` (
  `id` INT NOT NULL,
  `line` INT NOT NULL,
  `callgroup` VARCHAR(45) NULL,
  `pickupgroup` VARCHAR(45) NULL,
  `namedcallgroup` VARCHAR(45) NULL,
  `namedpickupgroup` VARCHAR(45) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_sccp_line_line1_idx` (`line` ASC),
  CONSTRAINT `fk_sccp_line_line1`
    FOREIGN KEY (`line`)
    REFERENCES `osiaa_epm`.`line` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `osiaa_epm`.`phone_line`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `osiaa_epm`.`phone_line` (
  `phone_id` INT NOT NULL,
  `line_id` INT NOT NULL,
  PRIMARY KEY (`phone_id`, `line_id`),
  INDEX `fk_phone_has_line_line1_idx` (`line_id` ASC),
  INDEX `fk_phone_has_line_phone1_idx` (`phone_id` ASC),
  CONSTRAINT `fk_phone_has_line_phone1`
    FOREIGN KEY (`phone_id`)
    REFERENCES `osiaa_epm`.`phone` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_phone_has_line_line1`
    FOREIGN KEY (`line_id`)
    REFERENCES `osiaa_epm`.`line` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
