# Pythagorean Academia API - PHP/MySQL Backend

Αυτό είναι πλήρες αρχικό backend για Flutter client/server αρχιτεκτονική.

## Περιλαμβάνει

- MySQL schema
- PHP REST API
- κοινό login για admin / interested / participant
- PBKDF2-SHA512 password hashing
- Bearer token authentication
- Programs
- Applications
- Admin approve/reject
- Participant profile creation
- Onboarding profile
- Media library
- Reflections
- Tasks
- Wearables
- Audit logs

## Τοπική εγκατάσταση με MAMP/XAMPP

1. Βάλε τον φάκελο `pythagorean_api` μέσα στο web root:

MAMP:
`/Applications/MAMP/htdocs/pythagorean_api`

XAMPP:
`/Applications/XAMPP/htdocs/pythagorean_api`

2. Άνοιξε phpMyAdmin.

3. Κάνε import:

`database/schema.sql`

4. Άλλαξε τα στοιχεία στο:

`config/database.php`

Παράδειγμα για MAMP συνήθως:
```php
const DB_USER = 'root';
const DB_PASS = 'root';
```

Για XAMPP συνήθως:
```php
const DB_USER = 'root';
const DB_PASS = '';
```

5. Τρέξε μία φορά στο browser:

`http://localhost/pythagorean_api/database/seed_passwords.php`

Αυτό βάζει σωστά PBKDF2-SHA512 password hash στους default admins.

## Demo accounts

```text
admin@pythagorean.gr / admin123
manager@pythagorean.gr / manager123
```

## Base URL για Flutter

Android Emulator:
```dart
const String baseUrl = "http://10.0.2.2/pythagorean_api/api";
```

iOS Simulator:
```dart
const String baseUrl = "http://localhost/pythagorean_api/api";
```

Πραγματικό κινητό στο ίδιο Wi-Fi:
```dart
const String baseUrl = "http://YOUR_MAC_LOCAL_IP/pythagorean_api/api";
```

Online hosting:
```dart
const String baseUrl = "https://yourdomain.com/pythagorean_api/api";
```

## Βασικά endpoints

### Auth

POST `/api/auth/register.php`
```json
{
  "full_name": "Maria Santos",
  "email": "maria@example.com",
  "password": "123456",
  "phone": "6900000000"
}
```

POST `/api/auth/login.php`
```json
{
  "email": "admin@pythagorean.gr",
  "password": "admin123"
}
```

GET `/api/auth/me.php`

POST `/api/auth/logout.php`

### Programs

GET `/api/programs/list.php`

GET `/api/programs/details.php?id=1`

GET `/api/programs/admin_list.php`  
Requires admin token.

POST `/api/programs/create.php`  
Requires admin token.

POST `/api/programs/update.php`  
Requires admin token.

POST `/api/programs/delete.php`  
Requires admin token.

### Applications

POST `/api/applications/apply.php`

GET `/api/applications/user_list.php`

GET `/api/applications/admin_list.php`  
Requires admin token.

POST `/api/applications/approve.php`  
Requires admin token.

POST `/api/applications/reject.php`  
Requires admin token.

### Profile / Onboarding

GET `/api/profile/get.php`

POST `/api/profile/save_onboarding.php`

### Participant

GET `/api/participant/dashboard.php`

GET `/api/participant/tasks.php`

POST `/api/participant/complete_task.php`

POST `/api/participant/save_reflection.php`

GET `/api/participant/reflections.php`

GET `/api/participant/wearables.php`

### Media

GET `/api/media/list.php`

GET `/api/media/list.php?type=article`

GET `/api/media/list.php?type=video`

GET `/api/media/list.php?type=audio`

## Authorization header

Μετά το login, το Flutter πρέπει να στέλνει:

```http
Authorization: Bearer YOUR_TOKEN_HERE
```

## Σημαντικό

Αυτό είναι καθαρό MVP backend για εργασία. Είναι αρκετό για να δείξει client/server, ρόλους χρηστών, κεντρική βάση, αιτήσεις, εγκρίσεις και δυναμικά δεδομένα.
