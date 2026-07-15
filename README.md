## Authors

- John Bourmpoulas
- Katerina Mitsiou

This project was developed collaboratively as part of an undergraduate thesis at the University of the Aegean.

# Pythagorean Academia Wellbeing App

A prototype mobile wellbeing application developed as part of an undergraduate thesis for the Pythagorean Academy of Sciences and Values – International Center for Stress Science and Health Promotion.

The application supports structured wellbeing programmes through registration, role-based access, programme applications, participant activities, reflections, assessments, educational content, messaging, personal reports, and health-data synchronization.

## Features

- User registration and secure login
- Role-based access for Interested Users, Participants, and Administrators
- User onboarding with personal, biometric, lifestyle, and goal information
- Programme catalogue and programme applications
- Administrator approval and participant activation
- Daily programme activities and task tracking
- Daily reflections and reflection history
- Assessments and wellness score tracking
- Educational library with articles, videos, audio, PDFs, and meditation resources
- Messaging between participants and administrators
- PDF wellness report generation
- Health Connect integration for wearable-related data
- Administrator dashboard and programme management

## User Roles

### Interested User
Users can register, complete onboarding, browse available programmes, view programme details, apply to programmes, and track their application status.

### Participant
Approved users can access their active programme, complete daily activities, submit reflections, complete assessments, view progress, access the wellness library, generate reports, and communicate with the programme team.

### Administrator
Administrators can manage users, approve or reject applications, create and edit programmes, manage programme tasks, manage educational resources, send messages, and view system statistics.

## Technologies Used

- Flutter
- Dart
- PHP
- MySQL
- REST API
- JSON over HTTP
- Android Studio
- MySQL Workbench
- Android Health Connect
- Figma

## Project Structure

```text
project/
├── mobile_app/
│   ├── lib/
│   ├── android/
│   └── pubspec.yaml
│
├── backend/
│   ├── config/
│   ├── helpers/
│   ├── api/
│   └── uploads/
│
├── database/
│   └── schema.sql
│
├── documentation/
│   ├── thesis/
│   ├── diagrams/
│   └── screenshots/
│
└── README.md
