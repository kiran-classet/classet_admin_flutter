# classet_admin

A Flutter project for a school administration system (Classet Admin).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Key Dependencies

This project uses the following key dependencies:
- flutter_riverpod: For state management
- go_router: For navigation
- firebase_core, firebase_auth, cloud_firestore: For Firebase integration
- amazon_cognito_identity_dart_2: For AWS Cognito integration

## Project Structure

The project follows a feature-based structure:
- lib/config: Configuration files
- lib/core: Core utilities and services
- lib/features: Feature-specific code (e.g., admissions, attendance, auth)