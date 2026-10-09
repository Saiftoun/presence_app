# PresenceApp

Flutter attendance app using Firebase Authentication and Cloud Firestore.

## Authentication and roles

- Email/password sign-in is handled by Firebase Authentication.
- Public registration creates student accounts only. The registration form never accepts a role.
- Admin-created teacher accounts are provisioned by the createManagedUser Cloud Function. It requires an authenticated account whose users/{uid} Firestore profile has role admin and active true.
- Unknown or missing profile roles are not treated as student accounts. Missing profiles show a recoverable error rather than an endless loading screen.
- Users can change only their own profile name. Firestore rules prevent clients from changing roles. The callable uses the Admin SDK to create teacher/student profiles.
- The current rule file intentionally denies access to collections other than users until those features receive their own rules.

## First-time Firebase setup

1. Create a Firebase project and enable Email/Password under Authentication sign-in providers.
2. Configure the Flutter app with FlutterFire CLI, then run flutter pub get.
3. Create the first admin account in Firebase Authentication Console.
4. In Firestore Console, create users/<admin uid> with name, email, role set to admin, and active set to true. Do not expose a public admin-registration flow.
5. Install Firebase CLI and deploy the rules and callable function from the repository root with: firebase deploy --only firestore:rules,functions. Cloud Functions deployment may require the Firebase project to use the Blaze plan.
6. Run the app with flutter run.

## Functions

The createManagedUser callable accepts name, email, password, and role. Only teacher/student roles are accepted, and only an active admin can call it. The admin teacher screen uses this callable so creating a teacher does not sign the admin out or grant roles from an untrusted client.

Install the server dependencies with npm install --prefix functions. Validate JavaScript syntax with npm --prefix functions run check.

## Tests

Run flutter test after flutter pub get. Tests cover role decoding, unknown-role handling, role labels, and student/teacher landing screens. The Firebase callable and deployed Firestore rules also need verification against the project's Firebase emulator or staging project before production use.
