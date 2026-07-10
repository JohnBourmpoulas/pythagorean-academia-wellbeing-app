-- MySQL dump 10.13  Distrib 9.6.0, for macos26.4 (arm64)
--
-- Host: localhost    Database: pythagorean_academia
-- ------------------------------------------------------
-- Server version	9.6.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '7b12c4c4-6fd6-11f1-beb8-2af13b51e487:1-1079';

--
-- Current Database: `pythagorean_academia`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `pythagorean_academia` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `pythagorean_academia`;

--
-- Table structure for table `admin_profiles`
--

DROP TABLE IF EXISTS `admin_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_profiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `position` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `admin_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_profiles`
--

LOCK TABLES `admin_profiles` WRITE;
/*!40000 ALTER TABLE `admin_profiles` DISABLE KEYS */;
INSERT INTO `admin_profiles` VALUES (1,1,'System Administrator','2026-06-24 17:13:47'),(2,2,'Program Manager','2026-06-24 17:13:47');
/*!40000 ALTER TABLE `admin_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_programs`
--

DROP TABLE IF EXISTS `admin_programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_programs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int NOT NULL,
  `program_id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_admin_program` (`admin_id`,`program_id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `admin_programs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `admin_programs_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_programs`
--

LOCK TABLES `admin_programs` WRITE;
/*!40000 ALTER TABLE `admin_programs` DISABLE KEYS */;
INSERT INTO `admin_programs` VALUES (1,1,1,'2026-06-24 17:13:47'),(2,1,2,'2026-06-24 17:13:47'),(3,2,3,'2026-06-24 17:13:47'),(4,1,4,'2026-06-24 19:15:27'),(5,1,5,'2026-06-26 21:49:49'),(6,1,6,'2026-06-28 18:27:28');
/*!40000 ALTER TABLE `admin_programs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assessment_answers`
--

DROP TABLE IF EXISTS `assessment_answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assessment_answers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assessment_result_id` int NOT NULL,
  `question_id` int NOT NULL,
  `answer_value` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `assessment_result_id` (`assessment_result_id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `assessment_answers_ibfk_1` FOREIGN KEY (`assessment_result_id`) REFERENCES `assessment_results` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assessment_answers_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `assessment_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessment_answers`
--

LOCK TABLES `assessment_answers` WRITE;
/*!40000 ALTER TABLE `assessment_answers` DISABLE KEYS */;
INSERT INTO `assessment_answers` VALUES (1,1,11,'3'),(2,1,12,'3'),(3,1,13,'3'),(4,1,14,'3'),(5,1,15,'3'),(6,2,11,'3'),(7,2,12,'3'),(8,2,13,'3'),(9,2,14,'3'),(10,2,15,'3'),(11,3,11,'3'),(12,3,12,'3'),(13,3,13,'3'),(14,3,14,'3'),(15,3,15,'3'),(16,4,11,'5'),(17,4,12,'2'),(18,4,13,'3'),(19,4,14,'1'),(20,4,15,'5'),(21,5,11,'5'),(22,5,12,'5'),(23,5,13,'3'),(24,5,14,'3'),(25,5,15,'5'),(26,6,11,'3'),(27,6,12,'1'),(28,6,13,'1'),(29,6,14,'3'),(30,6,15,'2'),(31,7,11,'5'),(32,7,12,'5'),(33,7,13,'5'),(34,7,14,'5'),(35,7,15,'5'),(36,8,11,'3'),(37,8,12,'3'),(38,8,13,'3'),(39,8,14,'3'),(40,8,15,'3'),(41,9,16,'3'),(42,9,17,'1'),(43,9,18,'5'),(44,9,19,'2'),(45,9,20,'5'),(46,10,21,'5'),(47,10,22,'5'),(48,10,23,'3'),(49,10,24,'3'),(50,10,25,'5'),(51,11,16,'3'),(52,11,17,'3'),(53,11,18,'3'),(54,11,19,'3'),(55,11,20,'3'),(56,12,21,'3'),(57,12,22,'3'),(58,12,23,'3'),(59,12,24,'3'),(60,12,25,'3'),(61,13,16,'5'),(62,13,17,'2'),(63,13,18,'4'),(64,13,19,'4'),(65,13,20,'5'),(66,14,21,'5'),(67,14,22,'2'),(68,14,23,'5'),(69,14,24,'4'),(70,14,25,'5'),(71,15,11,'2'),(72,15,12,'3'),(73,15,13,'3'),(74,15,14,'3'),(75,15,15,'3');
/*!40000 ALTER TABLE `assessment_answers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assessment_questions`
--

DROP TABLE IF EXISTS `assessment_questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assessment_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assessment_type` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `question_text` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessment_questions`
--

LOCK TABLES `assessment_questions` WRITE;
/*!40000 ALTER TABLE `assessment_questions` DISABLE KEYS */;
INSERT INTO `assessment_questions` VALUES (1,'wellness','How would you rate your mood today?',1),(2,'wellness','How stressed do you feel today?',2),(3,'wellness','How much energy do you have today?',3),(4,'wellness','How well did you sleep last night?',4),(5,'stress','How often did you feel overwhelmed this week?',1),(6,'stress','How difficult was it to relax?',2),(7,'stress','How often did stress affect your daily activities?',3),(8,'sleep','How many hours did you sleep last night?',1),(9,'sleep','How would you rate your sleep quality?',2),(10,'sleep','Did you wake up feeling rested?',3),(11,'wellness','How would you rate your overall wellbeing today?',1),(12,'wellness','How manageable was your stress level recently?',2),(13,'wellness','How satisfied are you with your sleep quality?',3),(14,'wellness','How motivated do you feel to continue the program?',4),(15,'wellness','How balanced do you feel physically and mentally?',5),(16,'sleep','How would you rate your overall wellbeing today?',1),(17,'sleep','How manageable was your stress level recently?',2),(18,'sleep','How satisfied are you with your sleep quality?',3),(19,'sleep','How motivated do you feel to continue the program?',4),(20,'sleep','How balanced do you feel physically and mentally?',5),(21,'stress','How would you rate your overall wellbeing today?',1),(22,'stress','How manageable was your stress level recently?',2),(23,'stress','How satisfied are you with your sleep quality?',3),(24,'stress','How motivated do you feel to continue the program?',4),(25,'stress','How balanced do you feel physically and mentally?',5);
/*!40000 ALTER TABLE `assessment_questions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assessment_results`
--

DROP TABLE IF EXISTS `assessment_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assessment_results` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_id` int NOT NULL,
  `assessment_type` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `score` int NOT NULL,
  `result_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `participant_id` (`participant_id`),
  CONSTRAINT `assessment_results_ibfk_1` FOREIGN KEY (`participant_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessment_results`
--

LOCK TABLES `assessment_results` WRITE;
/*!40000 ALTER TABLE `assessment_results` DISABLE KEYS */;
INSERT INTO `assessment_results` VALUES (1,3,'wellness',60,'2026-06-27 22:50:58'),(2,3,'wellness',60,'2026-06-27 23:00:39'),(3,3,'wellness',60,'2026-06-27 23:08:51'),(4,3,'wellness',64,'2026-06-27 23:09:03'),(5,3,'wellness',84,'2026-06-27 23:09:20'),(6,3,'wellness',40,'2026-06-27 23:11:24'),(7,3,'wellness',100,'2026-06-27 23:11:38'),(8,3,'wellness',60,'2026-06-27 23:13:11'),(9,3,'sleep',64,'2026-06-27 23:14:29'),(10,3,'stress',84,'2026-06-27 23:14:38'),(11,6,'sleep',60,'2026-06-30 19:00:42'),(12,6,'stress',60,'2026-06-30 19:04:16'),(13,5,'sleep',80,'2026-07-02 19:20:17'),(14,5,'stress',84,'2026-07-02 19:21:13'),(15,5,'wellness',56,'2026-07-02 19:23:20');
/*!40000 ALTER TABLE `assessment_results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `action` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` int DEFAULT NULL,
  `details` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,1,'create_program','program',4,'{\"title\": \"estt\"}','2026-06-24 19:15:27'),(2,1,'delete_program','program',4,'[]','2026-06-24 19:15:38'),(3,1,'reject_application','program_application',1,'[]','2026-06-25 18:47:04'),(4,1,'reject_application','program_application',3,'[]','2026-06-25 18:56:43'),(5,1,'reject_application','program_application',2,'[]','2026-06-25 18:57:42'),(6,1,'approve_application','program_application',6,'[]','2026-06-25 21:52:25'),(7,1,'approve_application','program_application',7,'[]','2026-06-26 12:16:41'),(8,1,'update_library_item','library_item',1,'[]','2026-06-26 19:26:42'),(9,1,'update_library_item','library_item',1,'[]','2026-06-26 19:26:50'),(10,1,'update_library_item','library_item',2,'[]','2026-06-26 19:34:34'),(11,1,'create_library_item','library_item',6,'[]','2026-06-26 19:49:00'),(12,1,'create_program','program',5,'{\"title\": \"test 1\"}','2026-06-26 21:49:49'),(13,1,'approve_application','program_application',11,'[]','2026-06-26 21:51:32'),(14,1,'create_program','program',6,'{\"title\": \"sjjfi\"}','2026-06-28 18:27:28'),(15,1,'approve_application','program_application',12,'[]','2026-06-28 18:35:55'),(16,1,'approve_application','program_application',18,'[]','2026-06-28 21:41:04'),(17,1,'approve_application','program_application',19,'[]','2026-06-30 18:41:54');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_tasks`
--

DROP TABLE IF EXISTS `daily_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_id` int NOT NULL,
  `program_activity_id` int DEFAULT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `scheduled_time` time DEFAULT NULL,
  `task_date` date NOT NULL,
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `completed_at` datetime DEFAULT NULL,
  `status` enum('pending','completed','missed','skipped') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `task_type` enum('video','audio','article','pdf','reflection','assessment','walking','meditation','breathing','exercise','custom') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'custom',
  `library_item_id` int DEFAULT NULL,
  `duration_minutes` int DEFAULT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT '1',
  `points` int NOT NULL DEFAULT '10',
  `due_date` date DEFAULT NULL,
  `instructions` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `program_activity_id` (`program_activity_id`),
  KEY `idx_daily_tasks_participant_date` (`participant_id`,`task_date`),
  CONSTRAINT `daily_tasks_ibfk_1` FOREIGN KEY (`participant_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `daily_tasks_ibfk_2` FOREIGN KEY (`program_activity_id`) REFERENCES `program_activities` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_tasks`
--

LOCK TABLES `daily_tasks` WRITE;
/*!40000 ALTER TABLE `daily_tasks` DISABLE KEYS */;
INSERT INTO `daily_tasks` VALUES (1,1,5,'Biological Age Assessment','Track and assess biological age indicators.',NULL,'2026-06-25',0,'2026-06-25 22:13:58','completed','custom',NULL,NULL,1,10,NULL,NULL),(2,1,6,'Lifestyle Plan','Personalized lifestyle improvement plan.',NULL,'2026-06-25',0,'2026-06-25 22:14:12','completed','custom',NULL,NULL,1,10,NULL,NULL),(4,2,1,'Daily Meditation','Guided daily meditation practice.',NULL,'2026-06-26',0,'2026-06-26 12:28:57','completed','custom',NULL,NULL,1,10,NULL,NULL),(5,2,2,'Breathing Exercises','Guided breathing and relaxation exercises.',NULL,'2026-06-26',0,'2026-06-26 12:30:17','completed','custom',NULL,NULL,1,10,NULL,NULL),(6,2,3,'Progress Tracking','Track weekly and monthly wellbeing progress.',NULL,'2026-06-26',0,NULL,'pending','custom',NULL,NULL,1,10,NULL,NULL),(7,2,4,'Wellness Library','Access educational articles, videos and audio guides.',NULL,'2026-06-26',0,NULL,'pending','custom',NULL,NULL,1,10,NULL,NULL),(11,5,1,'Daily Meditation','Guided daily meditation practice.',NULL,'2026-06-28',0,NULL,'pending','custom',NULL,NULL,1,10,NULL,NULL),(12,5,2,'Breathing Exercises','Guided breathing and relaxation exercises.',NULL,'2026-06-28',0,NULL,'pending','custom',NULL,NULL,1,10,NULL,NULL),(13,5,3,'Progress Tracking','Track weekly and monthly wellbeing progress.',NULL,'2026-06-28',0,NULL,'pending','custom',NULL,NULL,1,10,NULL,NULL),(14,5,4,'Wellness Library','Access educational articles, videos and audio guides.',NULL,'2026-06-28',0,NULL,'pending','custom',NULL,NULL,1,10,NULL,NULL),(18,6,1,'Daily Meditation','Guided daily meditation practice.',NULL,'2026-06-30',0,NULL,'pending','custom',NULL,NULL,1,10,NULL,NULL),(19,6,2,'Breathing Exercises','Guided breathing and relaxation exercises.',NULL,'2026-06-30',0,NULL,'pending','custom',NULL,NULL,1,10,NULL,NULL),(20,6,3,'Progress Tracking','Track weekly and monthly wellbeing progress.',NULL,'2026-06-30',0,NULL,'pending','custom',NULL,NULL,1,10,NULL,NULL),(21,6,4,'Wellness Library','Access educational articles, videos and audio guides.',NULL,'2026-06-30',0,NULL,'pending','custom',NULL,NULL,1,10,NULL,NULL);
/*!40000 ALTER TABLE `daily_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `interested_profiles`
--

DROP TABLE IF EXISTS `interested_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interested_profiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `age` int DEFAULT NULL,
  `profession` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `height_cm` decimal(6,2) DEFAULT NULL,
  `weight_kg` decimal(6,2) DEFAULT NULL,
  `neck_cm` decimal(6,2) DEFAULT NULL,
  `waist_cm` decimal(6,2) DEFAULT NULL,
  `bmi` decimal(6,2) DEFAULT NULL,
  `nutrition_habits` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `smoking_habits` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `physical_activity` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sleep_quality` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `goals` json DEFAULT NULL,
  `onboarding_completed` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `profile_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `interested_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `interested_profiles`
--

LOCK TABLES `interested_profiles` WRITE;
/*!40000 ALTER TABLE `interested_profiles` DISABLE KEYS */;
INSERT INTO `interested_profiles` VALUES (1,3,30,'software engineer',185.00,80.00,NULL,NULL,23.37,'keto','non-smoker','high','good','\"\\\"stress management\\\"\"',1,'2026-06-24 19:51:58','2026-06-24 21:11:14',NULL),(9,5,30,'software',170.00,75.00,NULL,NULL,25.95,'keto','non','low','poor','\"stress\"',1,'2026-06-24 21:22:19','2026-06-24 21:22:58',NULL),(13,6,30,'software',185.00,90.00,NULL,NULL,26.30,'keto','non smoker','moderate','average','\"\\\"stress management\\\"\"',1,'2026-06-25 11:54:17','2026-06-28 18:54:36',NULL),(19,7,30,'software',180.00,75.00,NULL,NULL,23.15,'keto','daily','low','poor','\"stress management\"',1,'2026-06-26 12:09:09','2026-06-26 12:11:29',NULL),(22,8,20,'developer software',165.00,70.00,NULL,NULL,25.71,'vegatarian','non-smoker','low','poor','\"stress management\"',1,'2026-06-28 21:37:11','2026-06-28 21:38:03',NULL),(24,9,40,'Mechanical Engineer',175.00,72.00,NULL,NULL,23.51,'Balance diet','daily','low','average','\"stress management\"',1,'2026-06-30 18:28:55','2026-06-30 18:38:38',NULL),(26,11,30,'software',170.00,82.00,NULL,NULL,28.37,'vegetarian','non smoker','moderate','average','\"stress management\"',1,'2026-07-02 18:23:22','2026-07-02 18:25:57',NULL);
/*!40000 ALTER TABLE `interested_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `library_items`
--

DROP TABLE IF EXISTS `library_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `library_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `program_id` int DEFAULT NULL,
  `type` enum('article','video','audio','meditation','pdf') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `content` longtext COLLATE utf8mb4_unicode_ci,
  `external_url` text COLLATE utf8mb4_unicode_ci,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thumbnail_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int NOT NULL DEFAULT '0',
  `created_by_admin_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_library_program` (`program_id`),
  KEY `fk_library_admin` (`created_by_admin_id`),
  CONSTRAINT `fk_library_admin` FOREIGN KEY (`created_by_admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_library_program` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library_items`
--

LOCK TABLES `library_items` WRITE;
/*!40000 ALTER TABLE `library_items` DISABLE KEYS */;
INSERT INTO `library_items` VALUES (1,NULL,'article','Introduction to PSAI','Basic introduction to Pythagorean Self-Awareness.','This article introduces the basic principles of PSAI and daily self-observation.',NULL,NULL,NULL,NULL,1,1,1,NULL,'2026-06-26 18:37:46','2026-06-26 19:26:50'),(2,NULL,'pdf','relax music video','testing youtube',NULL,'https://www.youtube.com/watch?v=wTwsSBEqaxg',NULL,NULL,0,1,1,2,NULL,'2026-06-26 18:37:46','2026-06-26 19:34:34'),(3,NULL,'audio','Relaxation Audio','Short audio guide for relaxation.',NULL,'https://example.com/audio/relaxation.mp3',NULL,NULL,NULL,0,1,3,NULL,'2026-06-26 18:37:46',NULL),(4,NULL,'meditation','Morning Meditation','Guided morning meditation practice.',NULL,'https://example.com/audio/morning-meditation.mp3',NULL,NULL,NULL,0,1,4,NULL,'2026-06-26 18:37:46',NULL),(5,NULL,'pdf','PSAI Guide PDF','PDF guide for the PSAI technique.',NULL,'https://example.com/files/psai-guide.pdf',NULL,NULL,NULL,0,1,5,NULL,'2026-06-26 18:37:46',NULL),(6,NULL,'video','testing video','testing 1',NULL,'https://www.youtube.com/watch?v=-a_KuccbEVQ',NULL,NULL,120,1,1,1,1,'2026-06-26 19:49:00',NULL);
/*!40000 ALTER TABLE `library_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `media_categories`
--

DROP TABLE IF EXISTS `media_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `media_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `media_categories`
--

LOCK TABLES `media_categories` WRITE;
/*!40000 ALTER TABLE `media_categories` DISABLE KEYS */;
INSERT INTO `media_categories` VALUES (2,'Biological Age'),(3,'Memory Enhancement'),(4,'Relaxation'),(1,'Stress Management');
/*!40000 ALTER TABLE `media_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `media_items`
--

DROP TABLE IF EXISTS `media_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `media_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int DEFAULT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('article','video','audio') COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `content_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `body` longtext COLLATE utf8mb4_unicode_ci,
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `idx_media_type` (`type`),
  CONSTRAINT `media_items_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `media_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `media_items`
--

LOCK TABLES `media_items` WRITE;
/*!40000 ALTER TABLE `media_items` DISABLE KEYS */;
INSERT INTO `media_items` VALUES (1,1,'Managing Stress Through Mindfulness','article','5 min read','Article about mindfulness and stress management.',NULL,'Educational article content.','active','2026-06-24 17:13:47'),(2,2,'The Science of Biological Age','article','5 min read','Article about biological age.',NULL,'Educational article content.','active','2026-06-24 17:13:47'),(3,3,'Memory Enhancement Techniques','article','5 min read','Article about memory improvement.',NULL,'Educational article content.','active','2026-06-24 17:13:47'),(4,4,'Guided Meditation Session','video','15 min','Guided meditation video session.',NULL,NULL,'active','2026-06-24 17:13:47'),(5,4,'Breathing Techniques','video','8 min','Video for breathing techniques.',NULL,NULL,'active','2026-06-24 17:13:47'),(6,4,'Sleep Meditation','audio','20 min','Audio sleep meditation guide.',NULL,NULL,'active','2026-06-24 17:13:47'),(7,4,'Focus Enhancement','audio','10 min','Audio guide for focus enhancement.',NULL,NULL,'active','2026-06-24 17:13:47'),(8,4,'Anxiety Relief','audio','15 min','Audio guide for anxiety relief.',NULL,NULL,'active','2026-06-24 17:13:47');
/*!40000 ALTER TABLE `media_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender_user_id` int NOT NULL,
  `receiver_user_id` int NOT NULL,
  `subject` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_messages_sender` (`sender_user_id`),
  KEY `fk_messages_receiver` (`receiver_user_id`),
  CONSTRAINT `fk_messages_receiver` FOREIGN KEY (`receiver_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (10,1,6,'Message from program team','hi there',1,'2026-06-28 18:28:47'),(11,6,1,'Re: Message from program team','ho',0,'2026-06-28 18:30:53'),(12,1,9,'Message from program team','geia soy manoli',0,'2026-06-30 18:47:04'),(13,1,8,'Message from program team','hello, welcome to Pythagorean Academia',1,'2026-07-02 19:05:16'),(14,8,1,'Re: Message from program team','HI! I can\'t wait to get started with the program!',0,'2026-07-02 19:53:14');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,6,'Application approved','Your application has been approved. You now have access to your participant dashboard.',NULL,0,'2026-06-25 21:52:25'),(2,7,'Application approved','Your application has been approved. You now have access to your participant dashboard.',NULL,0,'2026-06-26 12:16:41'),(3,6,'Application approved','Your application has been approved. You now have access to your participant dashboard.',NULL,0,'2026-06-26 21:51:32'),(4,6,'Application approved','Your application has been approved. You now have access to your participant dashboard.',NULL,0,'2026-06-28 18:35:55'),(5,8,'Application approved','Your application has been approved. You now have access to your participant dashboard.',NULL,0,'2026-06-28 21:41:04'),(6,9,'Application approved','Your application has been approved. You now have access to your participant dashboard.',NULL,0,'2026-06-30 18:41:54');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_activity_completions`
--

DROP TABLE IF EXISTS `participant_activity_completions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_activity_completions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_id` int DEFAULT NULL,
  `program_activity_id` int DEFAULT NULL,
  `completed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `program_daily_task_id` int DEFAULT NULL,
  `participant_profile_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `points_earned` int NOT NULL DEFAULT '0',
  `metadata` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_activity_completion` (`participant_id`,`program_activity_id`),
  UNIQUE KEY `unique_participant_program_task` (`participant_profile_id`,`program_daily_task_id`),
  KEY `program_activity_id` (`program_activity_id`),
  KEY `idx_program_daily_task_id` (`program_daily_task_id`),
  KEY `idx_participant_profile_id` (`participant_profile_id`),
  CONSTRAINT `fk_completion_program_daily_task` FOREIGN KEY (`program_daily_task_id`) REFERENCES `program_daily_tasks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_activity_completions_ibfk_1` FOREIGN KEY (`participant_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_activity_completions_ibfk_2` FOREIGN KEY (`program_activity_id`) REFERENCES `program_activities` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_activity_completions`
--

LOCK TABLES `participant_activity_completions` WRITE;
/*!40000 ALTER TABLE `participant_activity_completions` DISABLE KEYS */;
INSERT INTO `participant_activity_completions` VALUES (1,NULL,NULL,'2026-06-27 20:21:33',NULL,2,3,6,10,'{\"task_type\": \"walking\", \"day_number\": 2, \"program_id\": 5, \"task_title\": \"testing 2\"}'),(2,NULL,NULL,'2026-06-28 18:40:27',NULL,4,4,6,10,'{\"task_type\": \"walking\", \"day_number\": 1, \"program_id\": 6, \"task_title\": \"walk\"}');
/*!40000 ALTER TABLE `participant_activity_completions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_assessment_answers`
--

DROP TABLE IF EXISTS `participant_assessment_answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_assessment_answers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assessment_id` int NOT NULL,
  `participant_profile_id` int NOT NULL,
  `question_text` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `answer_value` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `assessment_id` (`assessment_id`),
  KEY `participant_profile_id` (`participant_profile_id`),
  CONSTRAINT `participant_assessment_answers_ibfk_1` FOREIGN KEY (`assessment_id`) REFERENCES `participant_assessments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_assessment_answers_ibfk_2` FOREIGN KEY (`participant_profile_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_assessment_answers`
--

LOCK TABLES `participant_assessment_answers` WRITE;
/*!40000 ALTER TABLE `participant_assessment_answers` DISABLE KEYS */;
INSERT INTO `participant_assessment_answers` VALUES (1,1,1,'How would you rate your overall wellbeing today?',2,'2026-06-25 22:19:55'),(2,1,1,'How manageable was your stress level recently?',2,'2026-06-25 22:19:55'),(3,1,1,'How satisfied are you with your sleep quality?',1,'2026-06-25 22:19:55'),(4,1,1,'How motivated do you feel to continue the program?',1,'2026-06-25 22:19:55'),(5,1,1,'How balanced do you feel physically and mentally?',5,'2026-06-25 22:19:55'),(6,2,1,'How would you rate your overall wellbeing today?',5,'2026-06-25 22:20:04'),(7,2,1,'How manageable was your stress level recently?',5,'2026-06-25 22:20:04'),(8,2,1,'How satisfied are you with your sleep quality?',5,'2026-06-25 22:20:04'),(9,2,1,'How motivated do you feel to continue the program?',5,'2026-06-25 22:20:04'),(10,2,1,'How balanced do you feel physically and mentally?',5,'2026-06-25 22:20:04'),(11,3,1,'How would you rate your overall wellbeing today?',5,'2026-06-25 22:20:13'),(12,3,1,'How manageable was your stress level recently?',4,'2026-06-25 22:20:13'),(13,3,1,'How satisfied are you with your sleep quality?',5,'2026-06-25 22:20:13'),(14,3,1,'How motivated do you feel to continue the program?',2,'2026-06-25 22:20:13'),(15,3,1,'How balanced do you feel physically and mentally?',5,'2026-06-25 22:20:13'),(16,4,3,'How would you rate your overall wellbeing today?',5,'2026-06-26 22:46:26'),(17,4,3,'How manageable was your stress level recently?',1,'2026-06-26 22:46:26'),(18,4,3,'How satisfied are you with your sleep quality?',5,'2026-06-26 22:46:26'),(19,4,3,'How motivated do you feel to continue the program?',3,'2026-06-26 22:46:26'),(20,4,3,'How balanced do you feel physically and mentally?',1,'2026-06-26 22:46:26');
/*!40000 ALTER TABLE `participant_assessment_answers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_assessments`
--

DROP TABLE IF EXISTS `participant_assessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_assessments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_profile_id` int NOT NULL,
  `user_id` int NOT NULL,
  `program_id` int NOT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `score` int DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `participant_profile_id` (`participant_profile_id`),
  KEY `user_id` (`user_id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `participant_assessments_ibfk_1` FOREIGN KEY (`participant_profile_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_assessments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_assessments_ibfk_3` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_assessments`
--

LOCK TABLES `participant_assessments` WRITE;
/*!40000 ALTER TABLE `participant_assessments` DISABLE KEYS */;
INSERT INTO `participant_assessments` VALUES (1,1,6,2,'Wellbeing Check','A short check-in about your general wellbeing.','completed',44,'2026-06-25 22:19:55','2026-06-25 22:18:57'),(2,1,6,2,'Stress Level Assessment','A quick assessment about your current stress level.','completed',100,'2026-06-25 22:20:04','2026-06-25 22:18:57'),(3,1,6,2,'Sleep Quality Assessment','A short questionnaire about your recent sleep quality.','completed',84,'2026-06-25 22:20:13','2026-06-25 22:18:57'),(4,3,6,5,'Wellbeing Check','A short check-in about your general wellbeing.','completed',60,'2026-06-26 22:46:26','2026-06-26 22:46:13'),(5,3,6,5,'Stress Level Assessment','A quick assessment about your current stress level.','pending',NULL,NULL,'2026-06-26 22:46:13'),(6,3,6,5,'Sleep Quality Assessment','A short questionnaire about your recent sleep quality.','pending',NULL,NULL,'2026-06-26 22:46:13');
/*!40000 ALTER TABLE `participant_assessments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_documents`
--

DROP TABLE IF EXISTS `participant_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_profile_id` int NOT NULL,
  `user_id` int NOT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_type` enum('progress_report','assessment_report','reflection_report','certificate') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'progress_report',
  `period_label` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `period_months` int DEFAULT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_participant_documents_profile` (`participant_profile_id`),
  KEY `fk_participant_documents_user` (`user_id`),
  CONSTRAINT `fk_participant_documents_profile` FOREIGN KEY (`participant_profile_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_participant_documents_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_documents`
--

LOCK TABLES `participant_documents` WRITE;
/*!40000 ALTER TABLE `participant_documents` DISABLE KEYS */;
INSERT INTO `participant_documents` VALUES (4,1,6,'Wellness Progress Report - Last 1 Month','progress_report','Last 1 Month',1,'uploads/participant_documents/user_6/wellness_report_1_1m_1782497923.pdf','2026-06-26 21:18:43'),(5,3,6,'Wellness Progress Report - Last 1 Month','progress_report','Last 1 Month',1,'uploads/participant_documents/user_6/wellness_report_3_1m_1782570728.pdf','2026-06-27 17:32:08'),(6,3,6,'Wellness Progress Report - Last 1 Month','progress_report','Last 1 Month',1,'uploads/participant_documents/user_6/wellness_report_3_1m_1782660667.pdf','2026-06-28 18:31:08'),(7,5,8,'Wellness Progress Report - Last 1 Month','progress_report','Last 1 Month',1,'uploads/participant_documents/user_8/wellness_report_5_1m_1783011375.pdf','2026-07-02 19:56:15');
/*!40000 ALTER TABLE `participant_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_files`
--

DROP TABLE IF EXISTS `participant_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_files` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_profile_id` int NOT NULL,
  `user_id` int NOT NULL,
  `program_id` int NOT NULL,
  `file_type` enum('profile_photo','pdf','certificate','report','assessment','reflection','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime_type` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size` int DEFAULT NULL,
  `uploaded_by_user_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `participant_profile_id` (`participant_profile_id`),
  KEY `user_id` (`user_id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `participant_files_ibfk_1` FOREIGN KEY (`participant_profile_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_files_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_files_ibfk_3` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_files`
--

LOCK TABLES `participant_files` WRITE;
/*!40000 ALTER TABLE `participant_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `participant_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_health_metrics`
--

DROP TABLE IF EXISTS `participant_health_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_health_metrics` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_profile_id` int NOT NULL,
  `metric_type` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `metric_value` decimal(12,2) NOT NULL DEFAULT '0.00',
  `metric_unit` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Health Connect',
  `device_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recorded_at` datetime NOT NULL,
  `metric_date` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_phm_participant_date` (`participant_profile_id`,`metric_date`),
  KEY `idx_phm_type` (`metric_type`),
  KEY `idx_phm_recorded` (`recorded_at`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_health_metrics`
--

LOCK TABLES `participant_health_metrics` WRITE;
/*!40000 ALTER TABLE `participant_health_metrics` DISABLE KEYS */;
INSERT INTO `participant_health_metrics` VALUES (77,3,'heart_rate',49.00,'bpm','Health Connect','Android Health Connect','2026-06-28 18:16:25','2026-06-28','2026-06-28 18:16:27'),(78,3,'sleep_hours',5.50,'hours','Health Connect','Android Health Connect','2026-06-28 18:16:25','2026-06-28','2026-06-28 18:16:27'),(93,3,'steps',0.00,'steps','Health Connect','Android Health Connect','2026-06-28 18:30:55','2026-06-28','2026-06-28 18:30:56'),(106,5,'steps',988.00,'steps','Health Connect','Android Health Connect','2026-07-06 12:15:46','2026-07-06','2026-07-06 12:15:47'),(107,5,'heart_rate',63.00,'bpm','Health Connect','Android Health Connect','2026-07-06 12:15:46','2026-07-06','2026-07-06 12:15:47');
/*!40000 ALTER TABLE `participant_health_metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_health_syncs`
--

DROP TABLE IF EXISTS `participant_health_syncs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_health_syncs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_profile_id` int NOT NULL,
  `provider` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Health Connect',
  `device_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'connected',
  `last_sync_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_phs_participant` (`participant_profile_id`),
  KEY `idx_phs_provider` (`provider`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_health_syncs`
--

LOCK TABLES `participant_health_syncs` WRITE;
/*!40000 ALTER TABLE `participant_health_syncs` DISABLE KEYS */;
INSERT INTO `participant_health_syncs` VALUES (1,3,'Health Connect','Android Health Connect','connected','2026-06-28 18:30:56','2026-06-28 02:20:34','2026-06-28 18:30:56'),(2,5,'Health Connect','Android Health Connect','connected','2026-07-06 12:15:47','2026-07-06 12:07:29','2026-07-06 12:15:47');
/*!40000 ALTER TABLE `participant_health_syncs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_history`
--

DROP TABLE IF EXISTS `participant_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_profile_id` int NOT NULL,
  `user_id` int NOT NULL,
  `program_id` int NOT NULL,
  `event_type` enum('profile_created','profile_updated','file_uploaded','file_deleted','activity_completed','reflection_submitted','assessment_started','assessment_completed','certificate_generated','admin_note','system') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'system',
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `metadata` json DEFAULT NULL,
  `created_by_user_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `participant_profile_id` (`participant_profile_id`),
  KEY `user_id` (`user_id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `participant_history_ibfk_1` FOREIGN KEY (`participant_profile_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_history_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_history_ibfk_3` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_history`
--

LOCK TABLES `participant_history` WRITE;
/*!40000 ALTER TABLE `participant_history` DISABLE KEYS */;
INSERT INTO `participant_history` VALUES (1,1,6,2,'profile_created','Participant profile activated','The application was approved and the user gained access to the participant dashboard.','{\"program_title\": \"Biological Age Measurement and Reversion\", \"application_id\": 6, \"storage_folder\": \"a031c6f3dca9443611df3d2c6af3c18d\"}',1,'2026-06-25 21:52:25'),(2,1,6,2,'activity_completed','Activity completed','The participant completed a scheduled activity.','{\"task_id\": 1, \"task_title\": \"Biological Age Assessment\"}',6,'2026-06-25 22:13:58'),(3,1,6,2,'activity_completed','Activity completed','The participant completed a scheduled activity.','{\"task_id\": 2, \"task_title\": \"Lifestyle Plan\"}',6,'2026-06-25 22:14:12'),(4,1,6,2,'system','Wearable metrics synced','The participant synced wearable health data.','{\"provider\": \"Apple\", \"inserted_metrics\": 4}',6,'2026-06-25 22:15:04'),(5,1,6,2,'assessment_completed','Assessment completed','The participant completed an assessment with score 44%.',NULL,6,'2026-06-25 22:19:55'),(6,1,6,2,'assessment_completed','Assessment completed','The participant completed an assessment with score 100%.',NULL,6,'2026-06-25 22:20:04'),(7,1,6,2,'assessment_completed','Assessment completed','The participant completed an assessment with score 84%.',NULL,6,'2026-06-25 22:20:13'),(8,1,6,2,'reflection_submitted','Daily reflection submitted','this is just a test note',NULL,6,'2026-06-25 22:21:18'),(9,1,6,2,'reflection_submitted','Daily reflection submitted','another one',NULL,6,'2026-06-25 22:21:49'),(10,2,7,1,'profile_created','Participant profile activated','The application was approved and the user gained access to the participant dashboard.','{\"program_title\": \"Pythagorean Academia Retreat for Stress Management, Biological Age Reversion, Memory Improvement & Well-being\", \"application_id\": 7, \"storage_folder\": \"435d3d0bc585dc497dcf6a6caf978712\"}',1,'2026-06-26 12:16:41'),(11,2,7,1,'activity_completed','Activity completed','The participant completed a scheduled activity.','{\"task_id\": 4, \"task_title\": \"Daily Meditation\"}',7,'2026-06-26 12:28:57'),(12,2,7,1,'activity_completed','Activity completed','The participant completed a scheduled activity.','{\"task_id\": 5, \"task_title\": \"Breathing Exercises\"}',7,'2026-06-26 12:30:17'),(13,2,7,1,'reflection_submitted','Daily reflection submitted','testimg',NULL,7,'2026-06-26 12:30:52'),(14,3,6,5,'profile_created','Participant profile activated','The application was approved and the user gained access to the participant dashboard.','{\"program_title\": \"test 1\", \"application_id\": 11, \"storage_folder\": \"3ec193b4cb3258b164ea96ced38367d9\"}',1,'2026-06-26 21:51:32'),(15,3,6,5,'assessment_completed','Assessment completed','The participant completed an assessment with score 60%.',NULL,6,'2026-06-26 22:46:26'),(16,3,6,5,'reflection_submitted','Daily reflection submitted','The participant submitted a daily reflection.',NULL,6,'2026-06-27 19:48:53'),(17,3,6,5,'reflection_submitted','Daily reflection submitted','The participant submitted a daily reflection.',NULL,6,'2026-06-27 20:29:29'),(18,3,6,5,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 60, \"assessment_type\": \"wellness\", \"assessment_result_id\": 1}',6,'2026-06-27 22:50:58'),(19,3,6,5,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 60, \"assessment_type\": \"wellness\", \"assessment_result_id\": 2}',6,'2026-06-27 23:00:39'),(20,3,6,5,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 60, \"assessment_type\": \"wellness\", \"assessment_result_id\": 3}',6,'2026-06-27 23:08:51'),(21,3,6,5,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 64, \"assessment_type\": \"wellness\", \"assessment_result_id\": 4}',6,'2026-06-27 23:09:03'),(22,3,6,5,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 84, \"assessment_type\": \"wellness\", \"assessment_result_id\": 5}',6,'2026-06-27 23:09:20'),(23,3,6,5,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 40, \"assessment_type\": \"wellness\", \"assessment_result_id\": 6}',6,'2026-06-27 23:11:24'),(24,3,6,5,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 100, \"assessment_type\": \"wellness\", \"assessment_result_id\": 7}',6,'2026-06-27 23:11:38'),(25,3,6,5,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 60, \"assessment_type\": \"wellness\", \"assessment_result_id\": 8}',6,'2026-06-27 23:13:11'),(26,3,6,5,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 64, \"assessment_type\": \"sleep\", \"assessment_result_id\": 9}',6,'2026-06-27 23:14:29'),(27,3,6,5,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 84, \"assessment_type\": \"stress\", \"assessment_result_id\": 10}',6,'2026-06-27 23:14:38'),(28,3,6,5,'reflection_submitted','Daily reflection submitted','The participant submitted a daily reflection.',NULL,6,'2026-06-28 00:04:42'),(29,3,6,5,'reflection_submitted','Daily reflection submitted','The participant submitted a daily reflection.',NULL,6,'2026-06-28 18:29:35'),(30,4,6,6,'profile_created','Participant profile activated','The application was approved and the user gained access to the participant dashboard.','{\"program_title\": \"sjjfi\", \"application_id\": 12, \"storage_folder\": \"32bb5679cd6333f00d97411011c59d67\"}',1,'2026-06-28 18:35:55'),(31,5,8,1,'profile_created','Participant profile activated','The application was approved and the user gained access to the participant dashboard.','{\"program_title\": \"Pythagorean Academia Retreat for Stress Management, Biological Age Reversion, Memory Improvement & Well-being\", \"application_id\": 18, \"storage_folder\": \"2e34c14d5659e1f6baaffdd0281ecb61\"}',1,'2026-06-28 21:41:04'),(32,6,9,1,'profile_created','Participant profile activated','The application was approved and the user gained access to the participant dashboard.','{\"program_title\": \"Pythagorean Academia Retreat for Stress Management, Biological Age Reversion, Memory Improvement & Well-being\", \"application_id\": 19, \"storage_folder\": \"edcd1083faf088bb23d433a7d42f3105\"}',1,'2026-06-30 18:41:54'),(33,6,9,1,'reflection_submitted','Daily reflection submitted','feeling good',NULL,9,'2026-06-30 18:57:41'),(34,6,9,1,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 60, \"assessment_type\": \"sleep\", \"assessment_result_id\": 11, \"next_available_in_days\": 7}',9,'2026-06-30 19:00:42'),(35,6,9,1,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 60, \"assessment_type\": \"stress\", \"assessment_result_id\": 12, \"next_available_in_days\": 7}',9,'2026-06-30 19:04:16'),(36,5,8,1,'reflection_submitted','Daily reflection submitted','Even though I haven\'t slept well, my mood and energy are good.',NULL,8,'2026-07-02 19:14:52'),(37,5,8,1,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 80, \"assessment_type\": \"sleep\", \"assessment_result_id\": 13, \"next_available_in_days\": 7}',8,'2026-07-02 19:20:17'),(38,5,8,1,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 84, \"assessment_type\": \"stress\", \"assessment_result_id\": 14, \"next_available_in_days\": 7}',8,'2026-07-02 19:21:13'),(39,5,8,1,'assessment_completed','Assessment completed','The participant completed an assessment.','{\"score\": 56, \"assessment_type\": \"wellness\", \"assessment_result_id\": 15, \"next_available_in_days\": 7}',8,'2026-07-02 19:23:20');
/*!40000 ALTER TABLE `participant_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_messages`
--

DROP TABLE IF EXISTS `participant_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_profile_id` int NOT NULL,
  `user_id` int NOT NULL,
  `program_id` int NOT NULL,
  `sender_user_id` int DEFAULT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `participant_profile_id` (`participant_profile_id`),
  KEY `user_id` (`user_id`),
  KEY `program_id` (`program_id`),
  KEY `sender_user_id` (`sender_user_id`),
  CONSTRAINT `participant_messages_ibfk_1` FOREIGN KEY (`participant_profile_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_messages_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_messages_ibfk_3` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_messages_ibfk_4` FOREIGN KEY (`sender_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_messages`
--

LOCK TABLES `participant_messages` WRITE;
/*!40000 ALTER TABLE `participant_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `participant_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_metrics`
--

DROP TABLE IF EXISTS `participant_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_metrics` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_profile_id` int NOT NULL,
  `user_id` int NOT NULL,
  `program_id` int NOT NULL,
  `metric_type` enum('steps','heart_rate','sleep_hours','calories','distance_km','active_minutes','stress_score','oxygen_saturation','blood_pressure_systolic','blood_pressure_diastolic','weight_kg') COLLATE utf8mb4_unicode_ci NOT NULL,
  `metric_value` decimal(10,2) NOT NULL,
  `metric_unit` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provider` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recorded_at` datetime NOT NULL,
  `metric_date` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `participant_profile_id` (`participant_profile_id`),
  KEY `user_id` (`user_id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `participant_metrics_ibfk_1` FOREIGN KEY (`participant_profile_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_metrics_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_metrics_ibfk_3` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_metrics`
--

LOCK TABLES `participant_metrics` WRITE;
/*!40000 ALTER TABLE `participant_metrics` DISABLE KEYS */;
INSERT INTO `participant_metrics` VALUES (1,1,6,2,'steps',9143.00,'steps','Apple','2026-06-25 22:15:03','2026-06-25','2026-06-25 22:15:04'),(2,1,6,2,'heart_rate',72.00,'bpm','Apple','2026-06-25 22:15:03','2026-06-25','2026-06-25 22:15:04'),(3,1,6,2,'sleep_hours',7.50,'hours','Apple','2026-06-25 22:15:03','2026-06-25','2026-06-25 22:15:04'),(4,1,6,2,'calories',1240.00,'kcal','Apple','2026-06-25 22:15:03','2026-06-25','2026-06-25 22:15:04');
/*!40000 ALTER TABLE `participant_metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_profiles`
--

DROP TABLE IF EXISTS `participant_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_profiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `program_id` int NOT NULL,
  `application_id` int DEFAULT NULL,
  `current_week` int NOT NULL DEFAULT '1',
  `total_weeks` int NOT NULL,
  `wellness_score` int NOT NULL DEFAULT '0',
  `progress_percent` int NOT NULL DEFAULT '0',
  `joined_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `storage_folder` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_completed` tinyint(1) NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `completed_at` datetime DEFAULT NULL,
  `status` enum('active','completed','paused','removed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_participant_program` (`user_id`,`program_id`),
  KEY `program_id` (`program_id`),
  KEY `application_id` (`application_id`),
  CONSTRAINT `participant_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_profiles_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_profiles_ibfk_3` FOREIGN KEY (`application_id`) REFERENCES `program_applications` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_profiles`
--

LOCK TABLES `participant_profiles` WRITE;
/*!40000 ALTER TABLE `participant_profiles` DISABLE KEYS */;
INSERT INTO `participant_profiles` VALUES (1,6,2,6,1,6,0,100,'2026-06-25 21:52:25','a031c6f3dca9443611df3d2c6af3c18d',0,NULL,NULL,'removed',NULL,'2026-06-26'),(2,7,1,7,1,8,0,50,'2026-06-26 12:16:41','435d3d0bc585dc497dcf6a6caf978712',0,NULL,NULL,'active','2026-06-26',NULL),(3,6,5,11,1,2,10,50,'2026-06-26 21:51:32','3ec193b4cb3258b164ea96ced38367d9',0,NULL,NULL,'removed','2026-06-26','2026-06-28'),(4,6,6,12,1,8,10,100,'2026-06-28 18:35:55','32bb5679cd6333f00d97411011c59d67',0,NULL,NULL,'removed','2026-06-28','2026-06-28'),(5,8,1,18,1,8,0,0,'2026-06-28 21:41:04','2e34c14d5659e1f6baaffdd0281ecb61',0,NULL,NULL,'active','2026-06-28',NULL),(6,9,1,19,1,8,60,0,'2026-06-30 18:41:54','edcd1083faf088bb23d433a7d42f3105',0,NULL,NULL,'active','2026-06-30',NULL);
/*!40000 ALTER TABLE `participant_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_reflections`
--

DROP TABLE IF EXISTS `participant_reflections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant_reflections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_profile_id` int NOT NULL,
  `user_id` int NOT NULL,
  `program_id` int NOT NULL,
  `mood_level` int NOT NULL,
  `stress_level` int NOT NULL,
  `energy_level` int NOT NULL,
  `sleep_quality` int NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `reflection_date` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `participant_profile_id` (`participant_profile_id`),
  KEY `user_id` (`user_id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `participant_reflections_ibfk_1` FOREIGN KEY (`participant_profile_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_reflections_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `participant_reflections_ibfk_3` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_reflections`
--

LOCK TABLES `participant_reflections` WRITE;
/*!40000 ALTER TABLE `participant_reflections` DISABLE KEYS */;
INSERT INTO `participant_reflections` VALUES (1,1,6,2,2,5,3,2,'this is just a test note','2026-06-25','2026-06-25 22:21:18'),(2,1,6,2,5,5,5,5,'another one','2026-06-25','2026-06-25 22:21:49'),(3,2,7,1,1,5,2,2,'testimg','2026-06-26','2026-06-26 12:30:52'),(4,3,6,5,4,1,5,2,'','2026-06-27','2026-06-27 19:48:53'),(5,3,6,5,5,5,5,5,'','2026-06-27','2026-06-27 20:29:29'),(6,3,6,5,5,2,3,5,'','2026-06-28','2026-06-28 00:04:42'),(7,3,6,5,2,2,2,2,'','2026-06-28','2026-06-28 18:29:35'),(8,6,9,1,5,2,4,2,'feeling good','2026-06-30','2026-06-30 18:57:41'),(9,5,8,1,5,2,4,2,'Even though I haven\'t slept well, my mood and energy are good.','2026-07-02','2026-07-02 19:14:52');
/*!40000 ALTER TABLE `participant_reflections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `program_activities`
--

DROP TABLE IF EXISTS `program_activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `program_activities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `program_id` int NOT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `activity_type` enum('meditation','breathing','reflection','education','assessment','exercise','library','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `scheduled_day` int DEFAULT NULL,
  `scheduled_time` time DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `is_required` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_program_activities_program` (`program_id`),
  CONSTRAINT `program_activities_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `program_activities`
--

LOCK TABLES `program_activities` WRITE;
/*!40000 ALTER TABLE `program_activities` DISABLE KEYS */;
INSERT INTO `program_activities` VALUES (1,1,'Daily Meditation','Guided daily meditation practice.','meditation',NULL,NULL,1,1,'2026-06-24 17:13:47'),(2,1,'Breathing Exercises','Guided breathing and relaxation exercises.','breathing',NULL,NULL,2,1,'2026-06-24 17:13:47'),(3,1,'Progress Tracking','Track weekly and monthly wellbeing progress.','other',NULL,NULL,3,1,'2026-06-24 17:13:47'),(4,1,'Wellness Library','Access educational articles, videos and audio guides.','library',NULL,NULL,4,1,'2026-06-24 17:13:47'),(5,2,'Biological Age Assessment','Track and assess biological age indicators.','assessment',NULL,NULL,1,1,'2026-06-24 17:13:47'),(6,2,'Lifestyle Plan','Personalized lifestyle improvement plan.','education',NULL,NULL,2,1,'2026-06-24 17:13:47'),(7,3,'Professional Training Modules','Certification learning material.','education',NULL,NULL,1,1,'2026-06-24 17:13:47'),(8,3,'Certification Assessment','Final assessment for certification.','assessment',NULL,NULL,2,1,'2026-06-24 17:13:47');
/*!40000 ALTER TABLE `program_activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `program_applications`
--

DROP TABLE IF EXISTS `program_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `program_applications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `program_id` int NOT NULL,
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `admin_notes` text COLLATE utf8mb4_unicode_ci,
  `submitted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_by_admin_id` int DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_program_application` (`user_id`,`program_id`),
  KEY `program_id` (`program_id`),
  KEY `reviewed_by_admin_id` (`reviewed_by_admin_id`),
  KEY `idx_applications_status` (`status`),
  CONSTRAINT `program_applications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `program_applications_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `program_applications_ibfk_3` FOREIGN KEY (`reviewed_by_admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `program_applications`
--

LOCK TABLES `program_applications` WRITE;
/*!40000 ALTER TABLE `program_applications` DISABLE KEYS */;
INSERT INTO `program_applications` VALUES (1,3,1,'rejected','Rejected by administrator','2026-06-24 19:58:04',1,'2026-06-25 18:47:04'),(2,5,2,'rejected','Rejected by administrator','2026-06-24 21:23:22',1,'2026-06-25 18:57:42'),(3,6,1,'rejected','Rejected by administrator','2026-06-25 18:46:25',1,'2026-06-25 18:56:43'),(4,6,3,'pending',NULL,'2026-06-25 18:57:06',NULL,NULL),(6,6,2,'approved',NULL,'2026-06-25 18:59:02',1,'2026-06-25 21:52:25'),(7,7,1,'approved',NULL,'2026-06-26 12:15:28',1,'2026-06-26 12:16:41'),(11,6,5,'approved',NULL,'2026-06-26 21:50:13',1,'2026-06-26 21:51:32'),(12,6,6,'approved',NULL,'2026-06-28 18:35:22',1,'2026-06-28 18:35:55'),(18,8,1,'approved',NULL,'2026-06-28 21:40:36',1,'2026-06-28 21:41:04'),(19,9,1,'approved',NULL,'2026-06-30 18:40:36',1,'2026-06-30 18:41:54'),(20,9,5,'pending',NULL,'2026-06-30 18:40:59',NULL,NULL),(21,11,1,'pending',NULL,'2026-07-02 18:37:11',NULL,NULL);
/*!40000 ALTER TABLE `program_applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `program_categories`
--

DROP TABLE IF EXISTS `program_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `program_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `program_categories`
--

LOCK TABLES `program_categories` WRITE;
/*!40000 ALTER TABLE `program_categories` DISABLE KEYS */;
INSERT INTO `program_categories` VALUES (1,'Comprehensive Wellness','Stress management, biological age, memory and wellbeing'),(2,'Age Optimization','Biological age measurement and reversion'),(3,'Professional Training','Training and certification for healthcare professionals');
/*!40000 ALTER TABLE `program_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `program_daily_tasks`
--

DROP TABLE IF EXISTS `program_daily_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `program_daily_tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `program_id` int NOT NULL,
  `day_number` int NOT NULL DEFAULT '1',
  `order_index` int NOT NULL DEFAULT '0',
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `task_type` enum('video','audio','article','pdf','reflection','assessment','walking','meditation','breathing','exercise','custom') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'custom',
  `library_item_id` int DEFAULT NULL,
  `duration_minutes` int DEFAULT NULL,
  `points` int NOT NULL DEFAULT '10',
  `instructions` text COLLATE utf8mb4_unicode_ci,
  `is_required` tinyint(1) NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_program_day` (`program_id`,`day_number`),
  KEY `idx_library_item` (`library_item_id`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_program_daily_tasks_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_program_daily_tasks_library_item` FOREIGN KEY (`library_item_id`) REFERENCES `library_items` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_program_daily_tasks_program` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `program_daily_tasks`
--

LOCK TABLES `program_daily_tasks` WRITE;
/*!40000 ALTER TABLE `program_daily_tasks` DISABLE KEYS */;
INSERT INTO `program_daily_tasks` VALUES (1,1,2,1,'walking','make a short walk in nature','walking',NULL,30,125,'make a walk for 30 minutes',1,1,1,'2026-06-27 19:29:33','2026-07-02 19:00:55'),(2,5,2,1,'testing 2','testing...','walking',NULL,20,10,'make a walk for 20 minutes',1,1,1,'2026-06-27 19:54:07',NULL),(3,5,2,2,'testinb15','sgmnsdofgndsoj','video',6,60,35,'watch the video for relaxation',1,1,1,'2026-06-27 20:55:59',NULL),(4,6,1,1,'walk','walk 20 min','walking',NULL,20,10,'walk 20 min every day',1,1,1,'2026-06-28 18:28:30',NULL),(5,6,1,0,'testing 2','testing task','custom',NULL,NULL,10,'testing by admin',1,1,1,'2026-06-30 18:46:05',NULL);
/*!40000 ALTER TABLE `program_daily_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `programs`
--

DROP TABLE IF EXISTS `programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `programs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int DEFAULT NULL,
  `created_by_admin_id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_title` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration_weeks` int NOT NULL,
  `max_participants` int DEFAULT NULL,
  `status` enum('active','inactive','deleted') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `created_by_admin_id` (`created_by_admin_id`),
  KEY `idx_programs_status` (`status`),
  CONSTRAINT `programs_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `program_categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `programs_ibfk_2` FOREIGN KEY (`created_by_admin_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `programs`
--

LOCK TABLES `programs` WRITE;
/*!40000 ALTER TABLE `programs` DISABLE KEYS */;
INSERT INTO `programs` VALUES (1,1,1,'Pythagorean Academia Retreat for Stress Management, Biological Age Reversion, Memory Improvement & Well-being','Stress Management Retreat','Comprehensive program for stress management, biological age reversion, memory improvement and wellbeing.',8,50,'active','2026-06-24 17:13:47',NULL),(2,2,1,'Biological Age Measurement and Reversion','Biological Age Measurement','Specialized program focused on biological age measurement and reversion through wellbeing practices.',6,40,'active','2026-06-24 17:13:47',NULL),(3,3,2,'Training and Certification for Physicians and Healthcare Professionals','Physician Certification Program','Training and certification in the Pythagorean Self-Awareness technique for healthcare professionals.',12,30,'active','2026-06-24 17:13:47',NULL),(4,NULL,1,'estt','asedwer','fsdfdsfwf',4,5,'deleted','2026-06-24 19:15:27','2026-06-24 19:15:38'),(5,NULL,1,'test 1','testing ...','just testing',2,20,'active','2026-06-26 21:49:49',NULL),(6,NULL,1,'sjjfi','skrocj','wndirja',8,30,'active','2026-06-28 18:27:28',NULL);
/*!40000 ALTER TABLE `programs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reflections`
--

DROP TABLE IF EXISTS `reflections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reflections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_id` int NOT NULL,
  `mood` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `what_went_well` text COLLATE utf8mb4_unicode_ci,
  `challenges` text COLLATE utf8mb4_unicode_ci,
  `improvement_notes` text COLLATE utf8mb4_unicode_ci,
  `stress_level` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `participant_id` (`participant_id`),
  CONSTRAINT `reflections_ibfk_1` FOREIGN KEY (`participant_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reflections`
--

LOCK TABLES `reflections` WRITE;
/*!40000 ALTER TABLE `reflections` DISABLE KEYS */;
/*!40000 ALTER TABLE `reflections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_tokens`
--

DROP TABLE IF EXISTS `user_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token_hash` char(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `revoked_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_token_hash` (`token_hash`),
  KEY `idx_user_tokens_user` (`user_id`),
  CONSTRAINT `user_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=119 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_tokens`
--

LOCK TABLES `user_tokens` WRITE;
/*!40000 ALTER TABLE `user_tokens` DISABLE KEYS */;
INSERT INTO `user_tokens` VALUES (1,1,'da864e8e62cbe7aee30a53f5cc0f3fe89c16cc6913fdaca605fec9a6c092797f5bfc74427033966e6a7720496d0f63039d573dff98330b9b09475f95b4e724b9','2026-07-01 14:31:01','2026-06-24 17:31:01',NULL),(2,1,'56769c9dfa45ac8c6b52084181a0aabe79b961dedc53925e4cd92452b45373ea28439b14e2742b64b0557cdeef4313f14051828ff36f19b8e52322107c6b506e','2026-07-01 16:04:54','2026-06-24 19:04:54',NULL),(3,1,'4f7eeee946985bbe16ddb4ccd6d4a108b94b79cafb5f85fa3fea09a29d1b8c7d5f5e28716869b8d71749bc1baff5d6d5533a115ef2f0b87826af3e53435dbcab','2026-07-01 16:09:37','2026-06-24 19:09:37','2026-06-24 19:48:56'),(5,1,'e42b3377cd6b70591e7bc9b65cfa1839d1d2146c58adf60c5edfe75d73777c0840d96a2df7c3a98436fed25cc67f39f96a2a9a3634c893078cf4fb45ea9c71c4','2026-07-01 16:57:03','2026-06-24 19:57:03','2026-06-24 19:57:30'),(7,1,'f9914dedd1af3b387a96194ba3c9ccee00fff5bcf832a73503559b1b89723d63334b9453046e91f970a5779f0bc355e98f91fcd8f13d0794805e4de79c97575d','2026-07-01 16:58:24','2026-06-24 19:58:24','2026-06-24 19:58:36'),(14,5,'1d6df932173fa15212f4555c7573c70eae0de39a4ac661d42d9513ab7cf1bfe9484e2ca1a833b66ddb6bd65b5430cf6d0594fcb483c6415343f1b557351f1814','2026-07-01 18:22:32','2026-06-24 21:22:32','2026-06-24 21:23:36'),(20,6,'0fa81ad6637f29bc1b22d3c2e4d3bb3c17e2fdcbfe3883b7ece2e25d45ff3a59231b55113067dbea70aabb2b25ea9c4736103de76e84d4f6267260b98fb23dbd','2026-07-02 08:54:28','2026-06-25 11:54:28','2026-06-25 15:17:32'),(21,6,'6ad4980bcdd7d955cec93a67ef67efc159a4b17ab072d1f54322484d806e2826cfbef70679b7e3f84b97f84516fb5b93d3b02b33667a50f98682edaaa0911a0f','2026-07-02 15:46:16','2026-06-25 18:46:16','2026-06-25 18:46:31'),(22,1,'69b8f0f11aac1c6da90928acc4248cd7eabb87d976b1fce2620cabeff5d515a825ee59044cc9eb39c4c594e0ca021e0bb09d7f69f82cee3578c75623fe5ea3e4','2026-07-02 15:46:45','2026-06-25 18:46:45',NULL),(23,1,'637d784c5ddea4a77b4ec4e5b9a5414a438dc8a07b1b3cbcb627248b85cd92e16b600b191a92585b5c1af85a8aee20744a7c0b2229d74e0cf4965cd79ad84f58','2026-07-02 15:52:09','2026-06-25 18:52:09','2026-06-25 18:56:16'),(24,1,'304e4ed403b023c287cf0109cafaf447b5b1d43b4ad1126eb18c9d4469b70b9095d744f064120b84d23a79f7731794498249b7d52f1b8a825e5f22467a852960','2026-07-02 15:56:35','2026-06-25 18:56:35','2026-06-25 18:56:47'),(25,6,'fda984c3445a9e5af838e1339b61d2114c8f762d264fe01bbea99fdd8346f5b4900fd878e682d7af672a92fb0cb072d283cd832bed161f23d107b97d5f500edb','2026-07-02 15:56:56','2026-06-25 18:56:56','2026-06-25 18:57:12'),(26,1,'bd5e93e7a94e2de84c2a496275f77ed5348bfb8389e4007c55962c308f0068ccd63307f638564cffd5d6c0635145b3aca53a3811bc712349b82267b241501e2f','2026-07-02 15:57:23','2026-06-25 18:57:23','2026-06-25 18:57:49'),(27,1,'ec3d037ef394dae7443ecb16a9c34bf9ba1f5362c968586cc706bac87274157681645f8f446afc3b9c17f1894c1a7ee0648429126a506f8b1545092b0ab62857','2026-07-02 15:58:07','2026-06-25 18:58:07','2026-06-25 18:58:21'),(28,6,'5cb6b5c9a6e60d77be6d53bd4de06f9cbb246d21ef0b7362e41e8df5b806534da66cb349f573b6846b72c70f78bdecdf483f615268464f271bf2c516cb7eac81','2026-07-02 15:58:45','2026-06-25 18:58:45','2026-06-25 18:59:07'),(29,1,'a6e626ed94761b9965cd25be4d5402771113edb4b3d171b1c1f8737b6c5501f3b8c3de82313a80e151a43bf4c4ff0dee292981a4984437f22cd984f540d396b3','2026-07-02 15:59:23','2026-06-25 18:59:23','2026-06-25 21:52:30'),(30,6,'71e3da7726861ed63f25e82a0eec81f6a2abe020987963c8a82aaa2ac503ccbc1c876e88549d0e6545571e09a424f42dc89f56ceb1e075235a7b06d32ad26c45','2026-07-02 18:52:42','2026-06-25 21:52:42',NULL),(31,7,'9bcf52172190385e61d1ee16d51ac209f0a2754b6fe1a7a796af365be8556c09495ed7feed491a370cb3f0be0b30ad2b85cef4d28e0c18a8226ca3d7924f9c39','2026-07-03 09:09:26','2026-06-26 12:09:26','2026-06-26 12:15:38'),(32,1,'a21ed8819467eb04229849e2091f12018413e5702549609b2b4e71e9132356e3ea9b097a051aab627cff5ab2e16fa626874cfc9ffd757d9020f278494ff0541c','2026-07-03 09:16:11','2026-06-26 12:16:11','2026-06-26 12:16:51'),(33,7,'0b029d3770f44c3a3b3468744a1e69eabe77f38a51366ae188a8d080f56e54bb1ae97cdc38f38214ab3eacddebfc56689447d72364f62dbb0262986b9f1be78a','2026-07-03 09:27:42','2026-06-26 12:27:42',NULL),(34,6,'9ae91b8d75c45b705dae4471224f991d560c8b4f5a80d4467ffd5bc5a6e85bf6938c364e5a8982c47ce0aeb4ae7fc684e1bcfeb06d582404b3fb066cd002bc12','2026-07-03 15:41:28','2026-06-26 18:41:28',NULL),(35,1,'66712ab334f96ea1677ac8ae0ce8bc1988e6d31800e32ed9281185ccf9dd6023eb00fc8d65b405ae6a6351bbef80972bad083542a46e2fc691a4dc5387a53235','2026-07-03 16:18:52','2026-06-26 19:18:52','2026-06-26 19:19:20'),(36,1,'1f451933ce028cc95a6bb9088d6a19fa1fea5b5c846c86c02aacf4c5515871ab707cdfc7394d7d33e40206f7c9c2496d6a31d5f6693f47845f064d83023697a4','2026-07-03 16:26:14','2026-06-26 19:26:14','2026-06-26 19:29:18'),(37,6,'e7e495c172fdfa671c56a5f774e807ded190c8491980233215e84790118a36d52ca7c321b4635eed3bd7fe760ec4569576a030285824ae24acac8fd4cc4e69c0','2026-07-03 16:29:26','2026-06-26 19:29:26',NULL),(38,1,'ea8f4241d9cdaeb3de77fb21d594244be7f651cdf2350b6b6aa0e2dad6b0317fbbde07caeddf584caed0c93e13c5d1c18ca3fd2b8bf7785c857963d74f8decf4','2026-07-03 16:29:55','2026-06-26 19:29:55','2026-06-26 19:34:38'),(39,6,'3ea54a9d93c99c9b4f255f8ad59235238079d8d0f83c43cce5ae14a1249e00fc2556140c7e0e0726c7734b5f5ac121e47e9a9f78ea79825c6914cfd89d57ae30','2026-07-03 16:34:54','2026-06-26 19:34:54',NULL),(40,1,'5e4c83ce63f040710320f7d296d45d6f488166c0b61d1e05aa897f391b9ef11417ff0ec4453951423c2b8cb252b3c15c690436240b27835519c7326ea7c896e0','2026-07-03 16:35:35','2026-06-26 19:35:35','2026-06-26 19:49:05'),(41,6,'0b4a473e965981396b2e4425bc9c126137f57bfe952334c808a7146ce4e6ddb40d9b894d4ca1ef5a2887ddd7473274215cd50e5495142e354c661192bab086f0','2026-07-03 16:49:13','2026-06-26 19:49:13',NULL),(42,6,'db952d2f98739e591309947d8b8217bd9f2723d2da8af7725645cadce4815394d3bb8000ac842e1019701a1e5ad7245c28dd19ebf2c86933a3658c96b492a059','2026-07-03 17:06:41','2026-06-26 20:06:41',NULL),(43,6,'df92472d8771436340f8a19f308a20ed03bd6f97dbb1eb18893b0298eef8f06d8c1bab7c26b2387bd2773f290fd503a8cd317fb08ee488749f3983374b888598','2026-07-03 17:47:30','2026-06-26 20:47:30',NULL),(44,6,'ed61c4f4712f56fbd4680c7ae01633c6c844b56725767625ecdd34334f4147381fa785b7fe54fe10907149086615a8b6c73317bc9bce0ec92867bcd17c45a43f','2026-07-03 18:46:24','2026-06-26 21:46:24','2026-06-26 21:47:50'),(45,1,'2fb4afae57726de36074fae866a745c984e4b5c916c7265a79c57862177ec84dd8d386ecf423ec80e31dbe49841f43d464bbf3bcba362107a588eb568df807b7','2026-07-03 18:48:03','2026-06-26 21:48:03','2026-06-26 21:49:52'),(46,6,'abef060cbb1c277a58dbe4d2d55b17fba90030d602605ee7bfa7b9fbcbcfc0ec67500e13c83eb058a679a9d92e3d18331713f01ef99463b56368b9dcf0304a5e','2026-07-03 18:50:03','2026-06-26 21:50:03','2026-06-26 21:50:21'),(47,1,'c44f26343d050a05cac5565a51f57783c06c9cfb8b9ed8654b6ae7a4281615aa89ea344e2f0dd3469bf2837943fc016276da2ec188f13def7701fdf6f8092e76','2026-07-03 18:51:26','2026-06-26 21:51:26','2026-06-26 21:54:12'),(48,1,'396ae3a661a65e6905f0c4108cd33f0e66d7a26592d1bf2cddc1f0e3767443548e4414e3d152ef4af456a18a88e5a43907af366c1a518bc98b49369eb82fdc86','2026-07-03 19:28:09','2026-06-26 22:28:09','2026-06-26 22:36:31'),(49,6,'a0aef0f69829931bc947197546f89ddbb262a34a1fb94263d64a1cf555efbb56cd965975a647b03e13097598365b215ac405c45c48d850c8320655b6fd88fe8a','2026-07-03 19:36:38','2026-06-26 22:36:38',NULL),(50,1,'1e8918e709dbaaf704ffccdeb6cb360e24a28c9bbb43fa1b346ad83e4bb406c5603513036e9a36e46ff0d00a159f9a5d1d74ca1b649e7a7d74699b04f6037623','2026-07-03 19:41:36','2026-06-26 22:41:36','2026-06-26 22:43:01'),(51,6,'73710d19dc9ac32f77aa72fde44a5849c01115ade47f01d71ca7b24a85b00c412cabff7cea8cbe7c9c1d68de0e94651c90f9293531a90323b7360606395c0d87','2026-07-03 19:43:14','2026-06-26 22:43:14',NULL),(52,1,'328bfd21e6dfe03645c1729c3baca0febaf4f0c0d389433ea3c7cc1885d2a348e6ba4de5b0fcfcab3060aa2c69d6061a7922b2c8d6f576bbfe6f6700e35ba08d','2026-07-03 19:55:24','2026-06-26 22:55:24',NULL),(53,1,'8178c99fcd2336b5173a263a1074e59e631cb36f399bf00e49f8a69ee5c988f2afdbb5c9c64143c580d59b8e8261ada6b761a2b92c8ae4245d69b7428e54f260','2026-07-04 13:11:37','2026-06-27 16:11:37','2026-06-27 16:12:29'),(54,6,'d0a0e63091665eb31c1c8b5625bb6f6e6553db5230a0dbfa5871f2e958c80c270c34f1ede8b247cac0e5f4f4782967568db4d914e212a88db1b6eed0ce102657','2026-07-04 13:12:45','2026-06-27 16:12:45',NULL),(55,1,'a81866a91fd780477638db8ea788bf7c95b1490c8dd71e7924993ae23acf13cd7cfd4fe5deec9682c543b34260f08f2fa15fc12c44c615353b4d5d8f8221c0ab','2026-07-04 13:13:46','2026-06-27 16:13:46','2026-06-27 16:36:52'),(56,6,'4688288a2a06ecf908164b6f3fb33a86609819079c2267881fa0e8fd4495ad6c1f95c8fe7a7a4b2c3db0c5d23aea81928d31037b2eeb6ca5733802593f314d44','2026-07-04 13:37:03','2026-06-27 16:37:03',NULL),(57,1,'3b59f110de81adc372b87a99de938e3839df51d43bad875a75c08aaffdd5d7a8bf629b9827fcd041bd431894024491e96bc0f3b246788894be2709ad9b70f763','2026-07-04 13:50:03','2026-06-27 16:50:03','2026-06-27 17:21:18'),(58,6,'5dff0306704f1fc0c16892ccf3695a75b8a9e504428c9dda482941b4c8c1ecf198be251537e504f60236fa2c9fdae8c0035931301d05873ffd553eb294c7df09','2026-07-04 14:21:27','2026-06-27 17:21:27',NULL),(59,1,'3545c303712f968980cbab547edd16f5511db38c35ea486a5e5fd5c9db45fcf57cd1d7b8beb482bd0086a6535475bdabc9475c5e3554fed3679f1f76805cfd1c','2026-07-04 14:23:28','2026-06-27 17:23:28','2026-06-27 17:31:47'),(60,6,'b14759a7d0baba3a0729e7789ede3371c28b45b364e701ebd6837f8559e16a14c1d57199e55d4a6b1485931de9d7b0283a150f9deac69e9316a1d03b557dc926','2026-07-04 14:32:00','2026-06-27 17:32:00',NULL),(61,1,'d3e367ff088d71ebfcdc6b81a5988a9eefbfe65cd232d3b47eab7809a100267da249af8a586668d0405cb04ea665eec923f903576c8ea349d51c488a51b8d439','2026-07-04 16:26:20','2026-06-27 19:26:20','2026-06-27 19:30:01'),(62,6,'c7955fd0af80df5ae5eccd5a22eb846c24cb5b11b79dec314be7df39a873cb1695e1ac4ec93581a216dc4b1730035561711550d04aa569883512f31398caa936','2026-07-04 16:30:20','2026-06-27 19:30:20',NULL),(63,1,'6a006515a03157aaf2765330e53483d3993bd56f316fe9223e510a04f9c34e0cc3446765052ac4f4669f5b5f877858fdd0c28b2ec3a6d89675ba51df8b05c311','2026-07-04 16:51:55','2026-06-27 19:51:55','2026-06-27 19:54:13'),(64,6,'9779e1f99ced9cc008da6ace7211e924f1b3643621a6cb1acd423345420497efee83d34ef7d7978af7b3b1c0754df2e9570abc73a6228d1efeb6cfc034c1fc5b','2026-07-04 16:54:20','2026-06-27 19:54:20',NULL),(65,6,'8e8bc50383c698318315548b2024bbeb7bfd01246b6d6c895851985f002b7702ded58fa920c6da2a0ef41abf14477962519b5a50ccd5ce500e3dd44e7dcdbe73','2026-07-04 17:00:56','2026-06-27 20:00:56',NULL),(66,6,'c9d44f844b4c224acd0b541aa63f8edf49e1214c424314dfd658d9db352e09eff4918b70a54fb46f2c931d67391beb253ae11be4c37868d0cd727de8e1cfb7dd','2026-07-04 17:07:00','2026-06-27 20:07:00',NULL),(67,1,'510b1581066efc22277b0b77bc15f838fd3f1973048c9c01779335095a9eacffe4ed2d8a88d847ab38075e64c8588001ec03071f1642d70248107965caced0fc','2026-07-04 17:34:16','2026-06-27 20:34:16','2026-06-27 20:53:10'),(68,6,'0a9162bdffe32ee41c5068d96164650cd2926db847d3ed03073594a09826506aed802fdb1e379aa07ea820efeb027f991770586825273827533f9639c1da9e07','2026-07-04 17:53:20','2026-06-27 20:53:20',NULL),(69,1,'db52e2421b3accbbceac289c39a7a6d87640a7c982b729cf64860b8bd17d9dcc7a63698e94042c9a38e07729987a6a6faeec0ec7d7c1021d36d11c7452edf308','2026-07-04 17:55:09','2026-06-27 20:55:09','2026-06-27 20:59:28'),(70,6,'6967e780b00348816d99bcea72d36657cf38135bdfc09345e6b24c2cb598a77d4277cdd9e5d68b4c3ad425a803d3fd682b2d1adf0e1db81f7ba50aa8238a1c6d','2026-07-04 17:59:42','2026-06-27 20:59:42',NULL),(71,6,'e6dfa20cdc90a5a6e8f005e049210c0014b93f9bf3337eb9faf41a24b649454881c15e75805dcd30af4c79579ae8d2f9c303d7650d6b572890da1067d71bdc0d','2026-07-04 20:14:14','2026-06-27 23:14:14',NULL),(72,6,'b11e844d4af0f20647d1d4f140c095af2222f34eb9f860812ffd3e8e37a4b22c569ef86386a223ee1172030da4a928e33ec3b4932b94e811cc9d8c7973e0082c','2026-07-04 21:03:33','2026-06-28 00:03:33',NULL),(73,6,'7e6a4336424cd128f56214d12de763dead49c6c5aa32fa7f0c73c2781e6551504553828072d48f005d3b2a11e010a5d8a248f05704c56ac597b84a15f9cdb747','2026-07-04 22:12:53','2026-06-28 01:12:53',NULL),(74,6,'3b938fb6aad461a5bbe29914b8e4610cf916e1c00147de3200d559ebc4828dc8c32122703d1b43468330f7796e24f1e596a80f0d7d12ab4a1e5ef5664ee77da6','2026-07-04 22:30:48','2026-06-28 01:30:48',NULL),(75,6,'3338e65d41e65a6ff7efb7987e5db055a560bc4755aea94e0d8608388d788ab05c96f686abe3f1cc1ae9d3a038a00d76aa98efd27776cf725d80e14e292a3243','2026-07-04 22:53:40','2026-06-28 01:53:40',NULL),(76,6,'306e24b05bf5591f7a5f60712ce056427acb2088bc66db84a8fb652eea0495506b5550e87151876bfb5d130a3ea78b8dd74ae24f66d851dceba4d1509a0fe84b','2026-07-04 23:10:01','2026-06-28 02:10:01',NULL),(77,6,'a77635477553d215e5c4afea2f28cca1a1ffc132b44f44980f9c65c5f9fc01e6cb65b90fc0d1c048b3d0be27389448a7419ae7b3d5ab60c5832a4e0561815f2f','2026-07-04 23:31:16','2026-06-28 02:31:16',NULL),(78,6,'2831eb80cc9c6be3904558fb783e0074bc6f6e5079367432ba7530492b3e40f07a708c8dd9e178fc3d8b91fbd54f563deeeda30c963ccca9fffaf5f34aa9ea28','2026-07-05 00:08:16','2026-06-28 03:08:16',NULL),(79,6,'e16cf79463c8455a7414368a7627ac43f6fbe60982232e811cdd14aa80fe76f235fab4ad6321285285e2bad9a939f2ccb2622a9f1453f4704b632ae4e0fdb357','2026-07-05 00:35:49','2026-06-28 03:35:49',NULL),(80,6,'770f8c85a5cac3f4b534f4510230ec84acaf05cbc788c4bba5b615deae7dfb7c5190661436ba500fc2268c1c46ee977f40a0e414b09f44abc5403b7549a952cf','2026-07-05 07:07:16','2026-06-28 10:07:16',NULL),(81,6,'5100e6c3e3248809cca2a9ad6dc8b65544389a2562ea56228219d10470d4be3bfdf34375b6cadc9641b06063f59c71acec68ad34e783015a497717d8ffedfb26','2026-07-05 07:24:47','2026-06-28 10:24:47',NULL),(82,6,'9d17fd6ca65b29489657a30f3ae14a560e07ede4c260903b021cf2aa11404a95da695e296185bb1e8333e8da6ed301840fc1851b0bb38eb2f05ca04812f95a66','2026-07-05 07:41:11','2026-06-28 10:41:11',NULL),(83,6,'60d28349d71eb4d1433ba80fc89918ef8f8e853d70900cd238fe6b14d26452653eae0385c57a6f5e766d3a73c0ac59d929f3a8ccb35c42adb904fa3927321840','2026-07-05 09:56:10','2026-06-28 12:56:10',NULL),(84,6,'92569d9910cb571bf6fa96e326c4ef120abbf19ce5b097e23c27fa7307147e5714a62c695f93c096f90f72f828de7ebc2cb53e80b1bf2760362d0fcdd31de5f1','2026-07-05 10:37:55','2026-06-28 13:37:55',NULL),(85,6,'2b1937595482b04edfd928f98dfaa3150854d49f9ae63d3d96ccc00f9ad1b14fc855322f9d38839801c4e225869eb8e40fe9886bc40b68d686bab30cfeb56fac','2026-07-05 11:20:01','2026-06-28 14:20:01',NULL),(86,6,'a9eb9a2d78b9149221b9a675b1cf9532fd1cc2cda9df0e29bfe67e29ae1c80acace8372d12fa886b02975f0ad0851a0d48f007f4ba6896bfc788223f767e97f7','2026-07-05 13:55:01','2026-06-28 16:55:01',NULL),(87,6,'293c9591e773c1e449ec9b3fb1955107a4173328e97ccdad9116789df88bed7e7781f07d134b6c86e540b5d99a39877bc81c2ef840c8889b232fff0de4a8dd69','2026-07-05 14:04:03','2026-06-28 17:04:03',NULL),(88,6,'b9103d9b8a37865e88deb99e1c002e28a10e68ab7e34b8343c5e5e43bd0ec00e90949f717b226451bb7ae42156c202aa4b1c1cb0245408c70b291411d9343572','2026-07-05 14:39:26','2026-06-28 17:39:26','2026-06-28 18:35:31'),(89,6,'9252b70b46f346381261e30d09aab892134a8aa9ddd68fa70a365aca96a022d5c6de432427d2ef06d62d6cfe0084ba414a8e30417714eccbdff2e419fabafc1d','2026-07-05 14:54:49','2026-06-28 17:54:49',NULL),(90,1,'8b592653e3d29bf393f59f14c0de4b761e2b8330cc3aa1200097f82d784cf0334253d001bc7aebeea8d78f6aa2fc29010a23daed459333f1db0741bd681cf1c1','2026-07-05 15:26:56','2026-06-28 18:26:56','2026-06-28 18:28:51'),(91,6,'b6653e4c31cb8d0fb4ba2a0c6f5b9786bf3eb0263c2cfc48758a9bcf4fa1ed972cca2d5ecc4fcf2c2eadf0e195073ab58cea78234e912d03ddab4b4139637b9d','2026-07-05 15:29:16','2026-06-28 18:29:16',NULL),(92,6,'536835439000cd73f4aa6461dcfaae37274a1ee9bb54bc4f9a52734cb87d3cf54b9d658c837c581cbf36bcf60d30947dd7b710b4d82c063eec20be56b5d8fde2','2026-07-05 15:31:57','2026-06-28 18:31:57','2026-06-28 18:39:35'),(93,1,'488da029d1217b0a9885719809d8285b787e6555a81121bb395fca87f2ad42314adca45430dc939ff8de20b8bc49e34a223e1a2ffbf3599af3b6ffc4c1355a1e','2026-07-05 15:35:44','2026-06-28 18:35:44','2026-06-28 18:36:00'),(94,6,'6c903ddfa393ad1139acb771aa3f3b490604dd3990563a0a2865b76b30cd36aa24ffce28f6eaee63ab6e658bc75e91cbf9178eae8dfb2a2391bcdab916c3fb5a','2026-07-05 15:36:30','2026-06-28 18:36:30',NULL),(95,6,'e0037802f431694ff6c9a051b955ffb047169e0100e1c31390e7fe1bf1e4536dd9712087ed00fb07844b9487ebb893ddd810615839be70e80fb9f915412649a4','2026-07-05 15:39:47','2026-06-28 18:39:47',NULL),(96,6,'143f63b52a638e7d7efc4fd2463cf1f59f13b437ac23c4f418664dda690007b49a8085b99ab2dcefdb9ae9033fa2f0be11e8e0a27c0adae478c75138e2357a43','2026-07-05 15:53:47','2026-06-28 18:53:47','2026-06-28 19:12:53'),(97,1,'79bf7848dfb29c71e01802a1b5573bc0145388e1986ef00319bc7cdde2fb7d340f38001102f3c51cc30f422e76cc9d9a2e0182cbbfad5c8e7d104679ff9b2b19','2026-07-05 18:34:53','2026-06-28 21:34:53','2026-06-28 21:36:16'),(98,8,'34c81835a55e2c0c8528fe168e0cf3ce59b2cdbda96b8b838e592c8dd045a4c3abac291df92906c83ddd0e206880a73f30305726881333c5f7fb1f92b438afd2','2026-07-05 18:37:20','2026-06-28 21:37:20','2026-06-28 21:38:58'),(99,6,'23b2db7b6f41f112278e7998b5b3d4c818dbf0bd1b8839d752495eee6f895b50ef74ca54ac9ea76dfaf5ce1fb9d3bea3ed4989595c1bbcc823bf162e54701ba8','2026-07-05 18:39:07','2026-06-28 21:39:07','2026-06-28 21:39:17'),(100,6,'537e3935802ce0ccd8e9f82387cf4af1baa0cb4ff6d8ba01ce0010ae9cb2c9db9b44e6e9125d5743c5293fac226d7ccbd87875e8012073254b8cd584f4ccb8f7','2026-07-05 18:39:27','2026-06-28 21:39:27','2026-06-28 21:40:16'),(101,8,'659a7f4fc62b9b5c04382045310963e9c1098f9ea505a77afc922a92272f20964902d396ed443b9a472bcf3ca1acb217710bcfdec1836964dde1a32bbef5e05b','2026-07-05 18:40:26','2026-06-28 21:40:26','2026-06-28 21:40:43'),(102,1,'bba0a5aaaab5ad84594806e30c41efe48cfe5da54aeff7eb67edfb537fe2bf90a5c4c5f75c1a553b499b9340d77710441ff45e766fd06104b74a1c0c6632f6a8','2026-07-05 18:40:56','2026-06-28 21:40:56','2026-06-28 21:41:08'),(103,8,'9bb69120f9400bcd4e3ec44fdf76c1adab52b349fd71709484e131f9084f8c0486d799db31cc847e8bdeaeffd8bd13336a9b6ce88d92e9037088d3f9129ecf89','2026-07-05 18:41:20','2026-06-28 21:41:20',NULL),(104,1,'331921eca7da58afd74d2cecc0305ddfc3cd935636a1dd6ef137da7b8b162e144a216cc3cbbf65d522d32863f4197d9f55dd0a930497b75e4f091af92806689c','2026-07-06 16:04:07','2026-06-29 19:04:07','2026-06-29 19:04:18'),(105,6,'c996855b3c04b5517e77c48dcabd75cbb94b03f7630c8a092552377028a4a0fb30c397e0a179fc72beded6395185430030fb577e12fdc8a516fc9f21f1009b53','2026-07-06 16:04:29','2026-06-29 19:04:29','2026-06-29 19:05:10'),(106,8,'e90d224e9c880dbf0bfd2a4d0ef00e1b3a9e0175f504646ea5dfd7d1d88fe82320da0147b02b64a844ba3408ba7b01a9056e27da82a563213f179a35d9c8deeb','2026-07-06 16:05:23','2026-06-29 19:05:23',NULL),(107,6,'969cfbbf6b9a7639b6be793ac26172ba3ac43848b5b99994ab5a06642207f1a3030e063993025c783d2fd733d892710353a5eb84c97a8f9747effe0fd51260f7','2026-07-06 16:15:11','2026-06-29 19:15:11','2026-06-29 19:15:50'),(108,8,'c48f67f4dbd87235bd784b71441cca61a593f574abe8570dad2889a0dbfca009c8bb9107e0ced06f943ddd154746c01922b4ce8ef616bd4e7c6c4a036a74edcc','2026-07-06 16:16:03','2026-06-29 19:16:03',NULL),(109,9,'8e8f1ff9bb5370c83789083c4ca80c5699651a944de44c493c3d69175295f80a13582c8d261b6825754daf65cdf7b4da74917c0863f187ab276ad5fbbf5afd08','2026-07-07 15:29:26','2026-06-30 18:29:26','2026-06-30 18:41:06'),(110,1,'e6f70327e66b380154dcb352a253d3b6a4252cd9723bab393be7899df2fe985c2c55cc17b4ca3a8363408c7a97eb30dfc36ad1c9bca6c66aaa7b754008ce19c8','2026-07-07 15:41:20','2026-06-30 18:41:20','2026-06-30 18:48:01'),(111,9,'a20efcd96ba6cbdc1c76f9b9a03cbc46eef00133e146df18c49cefc05af16dec113e61d6118c49a31426811d0d76ebc72382109432f0a905ec5a4a175441e215','2026-07-07 15:48:29','2026-06-30 18:48:29',NULL),(112,11,'1fabd917dd21f0f349665070449aa7ca049d06c08c00109b6122e694394b3dd374ffd9abc326eaa8e30c873cc9494bd6f7d3d392b058c49c1a18ef94073794de','2026-07-09 15:23:52','2026-07-02 18:23:52','2026-07-02 18:43:04'),(113,1,'ef6ef8f0d61a72edf0906113d384d6f5892376c797930d8696949b6c578c8893aab6bf3b3d2e29f8fc171c8dba05c4af76e6919425bb5f46d58299fe6e6489f5','2026-07-09 15:43:20','2026-07-02 18:43:20','2026-07-02 19:05:43'),(114,8,'832f9ef11d05fa11353b68c79ce876c9b9e634f6a6044724aee1ccf7549dc602fdbde0b7e018c8e8c714b22966c885d84cd3b24d7120e291b9ae7caad5ae2004','2026-07-09 16:05:57','2026-07-02 19:05:57',NULL),(115,8,'b61e795660ab4f4a35ed583abb7383559e55e0cdf0503dc4c430b79c749aeb769223ab13ca7f0027662ce9cd9d86375938f7176f14eb2966eb5091b2c3b185ff','2026-07-10 13:42:53','2026-07-03 16:42:53',NULL),(116,1,'be1cfa10538216ed2e23faca095fa1eb03ea2190d1e906e0f6bc32f8ad5faff8171437a8dc750565b77c733e7cb19d7e4c58e97728b7010906ec761a702ba622','2026-07-10 13:44:09','2026-07-03 16:44:09',NULL),(117,1,'9da612632e99e4041bd924a9bfc092425dba9d5fb9d322d1a07a9310380f872cd18c8786be9687aa3c5f545e05ca61698cef248613b7eb90b2b265999a3ad6ca','2026-07-13 09:01:57','2026-07-06 12:01:57','2026-07-06 12:02:10'),(118,8,'66679404ea718e8b8defa47ed052769c0b5819c9457fff089941d31e55e886709950328505ba11cf9dc0ab9d2a7b946b36883b93a8287b46b2757601afc3147d','2026-07-13 09:07:11','2026-07-06 12:07:11',NULL);
/*!40000 ALTER TABLE `user_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_salt` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('admin','interested','participant') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'interested',
  `status` enum('active','inactive','blocked') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `profile_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `auth_provider` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'local',
  `google_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apple_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Default Admin','admin@pythagorean.gr','277a81c40779d2233f48124ba6bf98324f005283ccf9037c86fead0ecd311d80ff42a51f574b7fd0c9cc2c960a448e3a01b7294f23c78c617ffdbb3b67fb9bd7','02abb2b5effcd5a2e44251fda070a65dc11d6192b21df6e39e6d0ba7043aa673','','admin','active','2026-06-24 17:13:47','2026-06-28 17:11:32',NULL,'local',NULL,NULL),(2,'Program Manager','manager@pythagorean.gr','00c231d5751fab1edeaa67e04dbdbf2006f1ad5d60296e33569f56e6b6803e8ac6d1b1c5efe92e092ed58b63f3206d4595ea095cc0dcf16b0ce0bd3b9c43b043','96dee93bc57eac2a668e723663335cceed6515c84d6d6e3dd73dbd16ad4582b6','','admin','active','2026-06-24 17:13:47','2026-06-28 17:11:32',NULL,'local',NULL,NULL),(3,'Deleted User','deleted_user_3_1782326802@deleted.local','$2y$12$KFEjNvrt.oAdfUDoLNA0nussFubMr7n6Oa.e6SuA.lXsxa4DQhnWu','17d9d876b713ffddc6b7e800b8a67e218af9afd376cf3fe80b49cd5afebb3dad',NULL,'interested','active','2026-06-24 19:51:58','2026-06-24 21:46:42',NULL,'local',NULL,NULL),(5,'user3 test','user3@test.gr','be81eeabbd8e4a88ec839b291667da050f200ac277a12b31fdfcce3f41fbadb74ea5de0e5c0b172cf5df7f20e0b0f5f006d17416176c4affa6e0310736d2e50e','b03aac1ab171f4541a4ec97774888dc31ed88217cda126ad72d834a0e3c3ce30','','interested','active','2026-06-24 21:22:19',NULL,NULL,'local',NULL,NULL),(6,'test user','user1@test.gr','13ca3c9dc3d5088bf95c118f481779fdc177ec95c9e27f12429f30617ab2955e397fb5f4a8dfeb685ee75f41632f77f76123a4ccc89286a56c31522343f54839','cf7979f953cb1c6d7fdf34de26d9cfb44e075cd94cc64caae4d611e1f12b7143','','interested','active','2026-06-25 11:54:17','2026-06-28 18:53:39',NULL,'local',NULL,NULL),(7,'user2 test','user2@test.gr','e388b4d5b4953bb60a689aed660083e1758b16e4c10ceab24577ef5ced6396921e9edc6498008fb2b173249ff49f7ca354c6b44242dad719bd30891036d03695','a73b24e576e807672baa3472f903ac58c2278ebb32fe7e1506fdde95646a2a3a','','participant','active','2026-06-26 12:09:09','2026-06-26 12:16:41',NULL,'local',NULL,NULL),(8,'user5 test','user5@test.gr','0f12c2c5217c35b98b0c69a1bbd490df4829acee5615719434f626e15a1cc1063634f9b14e646a73b1004325972f06cadc09ef95340a5725972244eabae588d5','b6de5cc1d7ef1f15e42baaa2b8efbe4376cd8bbd9eb0e754329b655a0b773f6d','','participant','active','2026-06-28 21:37:11','2026-06-28 21:41:04',NULL,'local',NULL,NULL),(9,'Manolis Elenis','elenis.manolis@gmail.com','e746dfe890350b5fc2a6c021ba5ebc0fcabfd971969ff68059c68bbaa937b395029e9cab32387144d794434fc7d451ec4a01b29370fb857e5357af250f9a063e','f6b065dc53021717b7ea76d9358bd197a6c7f8ff62af9e0321a8ddf068fc31f0','','participant','active','2026-06-30 18:28:55','2026-06-30 18:41:54',NULL,'local',NULL,NULL),(11,'user4 test','user4@test.gr','991d443197073e6542438b3624376741f5d7ca901d790b253b69542474356be09c3a6067458767ce37947c14789d66101941f827f98bef384bed4c658db1d24f','d9dd25ad2362f2dff0fe059b0f7b63409301906c0d093a0e1b46afda8321d55e','','interested','active','2026-07-02 18:23:22',NULL,NULL,'local',NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wearable_devices`
--

DROP TABLE IF EXISTS `wearable_devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wearable_devices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `participant_id` int NOT NULL,
  `provider` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('connected','disconnected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'disconnected',
  `last_sync` datetime DEFAULT NULL,
  `last_sync_at` datetime DEFAULT NULL,
  `access_token` text COLLATE utf8mb4_unicode_ci,
  `refresh_token` text COLLATE utf8mb4_unicode_ci,
  `provider_user_id` varchar(180) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sync_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `participant_id` (`participant_id`),
  CONSTRAINT `wearable_devices_ibfk_1` FOREIGN KEY (`participant_id`) REFERENCES `participant_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wearable_devices`
--

LOCK TABLES `wearable_devices` WRITE;
/*!40000 ALTER TABLE `wearable_devices` DISABLE KEYS */;
INSERT INTO `wearable_devices` VALUES (1,1,'Apple','Apple Watch','connected',NULL,'2026-06-25 22:15:04',NULL,NULL,NULL,1,'2026-06-25 21:52:25','2026-06-25 22:15:04'),(2,1,'Apple','Apple Health','connected',NULL,'2026-06-25 22:15:04',NULL,NULL,NULL,1,'2026-06-25 21:52:25','2026-06-25 22:15:04'),(3,1,'Samsung','Samsung Health','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-25 21:52:25',NULL),(4,1,'Google','Google Fit','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-25 21:52:25',NULL),(5,2,'Apple','Apple Watch','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-26 12:16:41',NULL),(6,2,'Apple','Apple Health','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-26 12:16:41',NULL),(7,2,'Samsung','Samsung Health','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-26 12:16:41',NULL),(8,2,'Google','Google Fit','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-26 12:16:41',NULL),(9,3,'Apple','Apple Watch','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-26 21:51:32',NULL),(10,3,'Apple','Apple Health','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-26 21:51:32',NULL),(11,3,'Samsung','Samsung Health','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-26 21:51:32',NULL),(12,3,'Google','Google Fit','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-26 21:51:32',NULL),(24,4,'Apple','Apple Watch','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-28 18:35:55',NULL),(25,4,'Apple','Apple Health','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-28 18:35:55',NULL),(26,4,'Samsung','Samsung Health','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-28 18:35:55',NULL),(27,4,'Google','Google Fit','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-28 18:35:55',NULL),(28,5,'Apple','Apple Watch','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-28 21:41:04',NULL),(29,5,'Apple','Apple Health','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-28 21:41:04',NULL),(30,5,'Samsung','Samsung Health','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-28 21:41:04',NULL),(31,5,'Google','Google Fit','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-28 21:41:04',NULL),(32,6,'Apple','Apple Watch','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-30 18:41:54',NULL),(33,6,'Apple','Apple Health','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-30 18:41:54',NULL),(34,6,'Samsung','Samsung Health','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-30 18:41:54',NULL),(35,6,'Google','Google Fit','disconnected',NULL,NULL,NULL,NULL,NULL,0,'2026-06-30 18:41:54',NULL);
/*!40000 ALTER TABLE `wearable_devices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'pythagorean_academia'
--

--
-- Dumping routines for database 'pythagorean_academia'
--
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-10 11:07:15
