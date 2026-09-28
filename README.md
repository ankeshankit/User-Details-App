# User Details App

A Flutter application that allows users to enter and save their
personal details locally using GetX and SharedPreferences.

## Features

- Add user details
- Edit user details
- Save data locally
- Load saved data automatically
- Clear user details
- GetX state management
- SharedPreferences local storage
- Form validation

## Technologies Used

- Flutter
- Dart
- GetX
- SharedPreferences

## User Details

The application stores:

- Name
- Email
- Phone
- Address

## Local Storage

SharedPreferences is used to store user data locally.

Data flow:

User Form
↓
GetX Controller
↓
User Model
↓
Local Storage Service
↓
SharedPreferences

## Project Structure

lib/
├── controllers/
│   └── user_controller.dart
│
├── models/
│   └── user_model.dart
│
├── services/
│   └── local_storage_service.dart
│
├── views/
│   └── user_details_screen.dart
│
└── main.dart

## Installation

Clone the project:

git clone YOUR_GITHUB_REPOSITORY_URL

Go to the project:

cd your_project

Install dependencies:

flutter pub get

Run the application:

flutter run

## Packages

get

shared_preferences

## How It Works

The user enters their details in the form and clicks
"Save Details".

The GetX controller receives the data and sends it to the
LocalStorageService.

The LocalStorageService saves the data using SharedPreferences.

When the application starts again, the saved data is loaded
from local storage and displayed in the form.

## Author

Ankit Kumar
