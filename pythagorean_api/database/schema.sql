CREATE DATABASE IF NOT EXISTS pythagorean_academia
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE pythagorean_academia;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS wearable_devices;
DROP TABLE IF EXISTS participant_activity_completions;
DROP TABLE IF EXISTS daily_tasks;
DROP TABLE IF EXISTS assessment_answers;
DROP TABLE IF EXISTS assessment_questions;
DROP TABLE IF EXISTS assessment_results;
DROP TABLE IF EXISTS reflections;
DROP TABLE IF EXISTS media_items;
DROP TABLE IF EXISTS media_categories;
DROP TABLE IF EXISTS participant_profiles;
DROP TABLE IF EXISTS program_applications;
DROP TABLE IF EXISTS program_activities;
DROP TABLE IF EXISTS admin_programs;
DROP TABLE IF EXISTS programs;
DROP TABLE IF EXISTS program_categories;
DROP TABLE IF EXISTS interested_profiles;
DROP TABLE IF EXISTS admin_profiles;
DROP TABLE IF EXISTS user_tokens;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(180) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    password_salt VARCHAR(255) NOT NULL,
    phone VARCHAR(40),
    role ENUM('admin','interested','participant') NOT NULL DEFAULT 'interested',
    status ENUM('active','inactive','blocked') NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE user_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token_hash CHAR(128) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token_hash (token_hash),
    INDEX idx_user_tokens_user (user_id)
) ENGINE=InnoDB;

CREATE TABLE admin_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    position VARCHAR(120),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE interested_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    age INT,
    profession VARCHAR(150),
    height_cm DECIMAL(6,2),
    weight_kg DECIMAL(6,2),
    neck_cm DECIMAL(6,2),
    waist_cm DECIMAL(6,2),
    bmi DECIMAL(6,2),
    nutrition_habits VARCHAR(120),
    smoking_habits VARCHAR(120),
    physical_activity VARCHAR(120),
    sleep_quality VARCHAR(120),
    goals JSON,
    onboarding_completed TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE program_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

CREATE TABLE programs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NULL,
    created_by_admin_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    short_title VARCHAR(160) NOT NULL,
    description TEXT NOT NULL,
    duration_weeks INT NOT NULL,
    max_participants INT NULL,
    status ENUM('active','inactive','deleted') NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES program_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by_admin_id) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_programs_status (status)
) ENGINE=InnoDB;

CREATE TABLE admin_programs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    program_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_admin_program (admin_id, program_id),
    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE program_activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT NOT NULL,
    title VARCHAR(180) NOT NULL,
    description TEXT,
    activity_type ENUM('meditation','breathing','reflection','education','assessment','exercise','library','other') NOT NULL DEFAULT 'other',
    scheduled_day INT NULL,
    scheduled_time TIME NULL,
    sort_order INT NOT NULL DEFAULT 0,
    is_required TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
    INDEX idx_program_activities_program (program_id)
) ENGINE=InnoDB;

CREATE TABLE program_applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    program_id INT NOT NULL,
    status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    admin_notes TEXT,
    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_by_admin_id INT NULL,
    reviewed_at DATETIME NULL,
    UNIQUE KEY uq_user_program_application (user_id, program_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_by_admin_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_applications_status (status)
) ENGINE=InnoDB;

CREATE TABLE participant_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    program_id INT NOT NULL,
    application_id INT NULL,
    current_week INT NOT NULL DEFAULT 1,
    total_weeks INT NOT NULL,
    wellness_score INT NOT NULL DEFAULT 0,
    progress_percent INT NOT NULL DEFAULT 0,
    joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_participant_program (user_id, program_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
    FOREIGN KEY (application_id) REFERENCES program_applications(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE daily_tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    participant_id INT NOT NULL,
    program_activity_id INT NULL,
    title VARCHAR(180) NOT NULL,
    description TEXT,
    scheduled_time TIME NULL,
    task_date DATE NOT NULL,
    completed TINYINT(1) NOT NULL DEFAULT 0,
    completed_at DATETIME NULL,
    FOREIGN KEY (participant_id) REFERENCES participant_profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (program_activity_id) REFERENCES program_activities(id) ON DELETE SET NULL,
    INDEX idx_daily_tasks_participant_date (participant_id, task_date)
) ENGINE=InnoDB;

CREATE TABLE participant_activity_completions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    participant_id INT NOT NULL,
    program_activity_id INT NOT NULL,
    completed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    UNIQUE KEY uq_activity_completion (participant_id, program_activity_id),
    FOREIGN KEY (participant_id) REFERENCES participant_profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (program_activity_id) REFERENCES program_activities(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE reflections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    participant_id INT NOT NULL,
    mood VARCHAR(40) NOT NULL,
    notes TEXT,
    what_went_well TEXT,
    challenges TEXT,
    improvement_notes TEXT,
    stress_level INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participant_profiles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE assessment_questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    assessment_type VARCHAR(80) NOT NULL,
    question_text TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE assessment_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    participant_id INT NOT NULL,
    assessment_type VARCHAR(80) NOT NULL,
    score INT NOT NULL,
    result_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participant_profiles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE assessment_answers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    assessment_result_id INT NOT NULL,
    question_id INT NOT NULL,
    answer_value VARCHAR(120) NOT NULL,
    FOREIGN KEY (assessment_result_id) REFERENCES assessment_results(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES assessment_questions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE media_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE media_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NULL,
    title VARCHAR(180) NOT NULL,
    type ENUM('article','video','audio') NOT NULL,
    duration VARCHAR(60),
    description TEXT,
    content_url VARCHAR(255),
    body LONGTEXT,
    status ENUM('active','inactive') NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES media_categories(id) ON DELETE SET NULL,
    INDEX idx_media_type (type)
) ENGINE=InnoDB;

CREATE TABLE wearable_devices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    participant_id INT NOT NULL,
    provider VARCHAR(120) NOT NULL,
    device_name VARCHAR(120) NOT NULL,
    status ENUM('connected','disconnected') NOT NULL DEFAULT 'disconnected',
    last_sync DATETIME NULL,
    FOREIGN KEY (participant_id) REFERENCES participant_profiles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(180) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(80),
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    action VARCHAR(120) NOT NULL,
    entity_type VARCHAR(80),
    entity_id INT,
    details JSON,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

INSERT INTO users (full_name, email, password_hash, password_salt, phone, role)
VALUES
('Default Admin', 'admin@pythagorean.gr', '', '', '', 'admin'),
('Program Manager', 'manager@pythagorean.gr', '', '', '', 'admin');

INSERT INTO admin_profiles (user_id, position)
VALUES
(1, 'System Administrator'),
(2, 'Program Manager');

INSERT INTO program_categories (name, description)
VALUES
('Comprehensive Wellness', 'Stress management, biological age, memory and wellbeing'),
('Age Optimization', 'Biological age measurement and reversion'),
('Professional Training', 'Training and certification for healthcare professionals');

INSERT INTO programs (category_id, created_by_admin_id, title, short_title, description, duration_weeks, max_participants, status)
VALUES
(1, 1, 'Pythagorean Academia Retreat for Stress Management, Biological Age Reversion, Memory Improvement & Well-being', 'Stress Management Retreat', 'Comprehensive program for stress management, biological age reversion, memory improvement and wellbeing.', 8, 50, 'active'),
(2, 1, 'Biological Age Measurement and Reversion', 'Biological Age Measurement', 'Specialized program focused on biological age measurement and reversion through wellbeing practices.', 6, 40, 'active'),
(3, 2, 'Training and Certification for Physicians and Healthcare Professionals', 'Physician Certification Program', 'Training and certification in the Pythagorean Self-Awareness technique for healthcare professionals.', 12, 30, 'active');

INSERT INTO admin_programs (admin_id, program_id)
VALUES
(1, 1), (1, 2), (2, 3);

INSERT INTO program_activities (program_id, title, description, activity_type, sort_order)
VALUES
(1, 'Daily Meditation', 'Guided daily meditation practice.', 'meditation', 1),
(1, 'Breathing Exercises', 'Guided breathing and relaxation exercises.', 'breathing', 2),
(1, 'Progress Tracking', 'Track weekly and monthly wellbeing progress.', 'other', 3),
(1, 'Wellness Library', 'Access educational articles, videos and audio guides.', 'library', 4),
(2, 'Biological Age Assessment', 'Track and assess biological age indicators.', 'assessment', 1),
(2, 'Lifestyle Plan', 'Personalized lifestyle improvement plan.', 'education', 2),
(3, 'Professional Training Modules', 'Certification learning material.', 'education', 1),
(3, 'Certification Assessment', 'Final assessment for certification.', 'assessment', 2);

INSERT INTO media_categories (name)
VALUES ('Stress Management'), ('Biological Age'), ('Memory Enhancement'), ('Relaxation');

INSERT INTO media_items (category_id, title, type, duration, description, body, status)
VALUES
(1, 'Managing Stress Through Mindfulness', 'article', '5 min read', 'Article about mindfulness and stress management.', 'Educational article content.', 'active'),
(2, 'The Science of Biological Age', 'article', '5 min read', 'Article about biological age.', 'Educational article content.', 'active'),
(3, 'Memory Enhancement Techniques', 'article', '5 min read', 'Article about memory improvement.', 'Educational article content.', 'active'),
(4, 'Guided Meditation Session', 'video', '15 min', 'Guided meditation video session.', NULL, 'active'),
(4, 'Breathing Techniques', 'video', '8 min', 'Video for breathing techniques.', NULL, 'active'),
(4, 'Sleep Meditation', 'audio', '20 min', 'Audio sleep meditation guide.', NULL, 'active'),
(4, 'Focus Enhancement', 'audio', '10 min', 'Audio guide for focus enhancement.', NULL, 'active'),
(4, 'Anxiety Relief', 'audio', '15 min', 'Audio guide for anxiety relief.', NULL, 'active');
