# Pythagorean Academia Wellbeing App

A full-stack prototype wellbeing platform developed as part of an
undergraduate thesis at the University of the Aegean for the Pythagorean
Academy of Sciences and Values -- International Center for Stress
Science and Health Promotion.

The project consists of a **Flutter mobile application**, a **PHP
RESTful backend API**, and a **MySQL relational database**. Together,
these components provide a client-server system for structured wellbeing
programmes, participant monitoring, communication, educational content,
assessments, reflections, reports, and health-data synchronization.

## Authors

-   John Bourmpoulas
-   Katerina Mitsiou

This project was developed collaboratively as part of an undergraduate
thesis at the University of the Aegean.

## System Components

### Mobile Application

The mobile application was developed using Flutter and Dart and provides
the main user interface of the system.

It supports:

-   User registration and secure login
-   User onboarding with personal, biometric, lifestyle, and goal
    information
-   Role-based access
-   Programme browsing and applications
-   Daily programme activities and task tracking
-   Daily reflections and reflection history
-   Assessments and wellness score tracking
-   Educational content
-   Messaging between participants and administrators
-   Notifications
-   Personal progress monitoring
-   PDF wellness report generation
-   Health Connect synchronization
-   Administrator functionality

### Backend Server

The backend was developed in PHP and provides a RESTful API for
communication between the mobile application and the database.

The backend is responsible for:

-   User authentication and authorization
-   Password hashing and verification
-   Role-based access control
-   User and participant management
-   Programme application processing
-   Administrator approval and rejection
-   Programme and activity management
-   Assessment and reflection processing
-   Messaging
-   Notifications
-   Educational content management
-   Participant data processing
-   Report-related data retrieval
-   Communication with the MySQL database

Data is exchanged between the mobile application and the backend using
JSON over HTTP.

### Database

The system uses a MySQL relational database for persistent data storage.

The database stores and manages information related to users, profiles,
administrators, participants, programmes, applications, activities,
assessments, reflections, educational resources, messages,
notifications, health and wellbeing data, and system activity.

## User Roles

### Interested User

Interested users can register, complete onboarding, browse available
programmes, view programme details, submit programme applications, and
monitor their application status.

### Participant

After administrator approval, participants can access their active
programme, complete daily activities, submit reflections, complete
assessments, monitor their progress, access educational resources,
generate reports, synchronize supported health data, and communicate
with the programme team.

### Administrator

Administrators can manage users, review programme applications, approve
or reject participants, create and manage programmes, manage programme
activities and educational resources, communicate with participants, and
monitor system information.

## Health Data Integration

The mobile application integrates with Android Health Connect to
retrieve selected wellbeing-related information after user permission.

The prototype supports synchronization and visualization of selected
health metrics, including steps, heart rate, and sleep-related
information.

The health-data functionality is intended for wellbeing monitoring and
visualization and does not provide medical diagnosis or clinical
interpretation.

## Technologies Used

### Mobile Application

-   Flutter
-   Dart
-   Android Studio
-   Android Health Connect

### Backend

-   PHP
-   RESTful API
-   JSON over HTTP

### Database

-   MySQL
-   MySQL Workbench

### Design

-   Figma

## Repository Structure

``` text
pythagorean-academia-wellbeing-app/
├── mobile_app/
│   ├── lib/
│   ├── android/
│   ├── assets/
│   └── pubspec.yaml
├── pythagorean_api/
│   ├── api/
│   ├── helpers/
│   └── ...
├── database/
│   └── ...
├── .gitignore
└── README.md
```

## System Architecture

``` text
Flutter Mobile Application
          |
          | JSON / HTTP
          v
     PHP REST API
          |
          v
     MySQL Database

Android Health Connect
          |
          v
Flutter Mobile Application
```

The Flutter application acts as the client interface. The PHP backend
handles server-side application logic, authentication, authorization,
data processing, and database communication. The MySQL database provides
persistent storage, while Android Health Connect enables supported
health-data synchronization with the mobile application.

## Project Status

This repository contains a functional prototype developed for an
undergraduate thesis.

The system was primarily developed and tested in a controlled
development environment. The backend and database require appropriate
server configuration before production deployment.

Potential future development includes:

-   Production server deployment
-   Greek language support
-   Full Google Authentication
-   Full Apple Authentication
-   Extended health-platform integration
-   Additional wellbeing indicators
-   Extended administrator analytics
-   iOS testing and adaptation

## Disclaimer

This application is intended for wellbeing support, self-monitoring,
education, and programme participation.

It is not intended to provide medical diagnosis, medical advice,
clinical interpretation, or clinical decision-making.
