# PresenceApp

Flutter attendance app using Firebase Authentication and Cloud Firestore.

## Authentication and roles

- Email/password sign-in is handled by Firebase Authentication.
- Public registration creates student accounts only. The registration form never accepts a role.
- An admin creates teacher accounts from the admin form. The app uses a separate Firebase Auth app instance, so the admin session is preserved; this does not require Cloud Functions or the Blaze plan.
- Unknown or missing profile roles are not treated as student accounts. Missing profiles show a recoverable error rather than an endless loading screen.
- Users can change only their own profile name. Firestore rules allow only an active admin to promote a student to teacher; clients cannot assign themselves a role.
- Firestore rules protect user profiles and classes. Class writes are admin-only, while teachers and students can read only classes assigned to them. Sessions, attendance, and Storage remain closed until their feature-specific rules are added.

## First-time Firebase setup

1. Create a Firebase project and enable Email/Password under Authentication sign-in providers.
2. Configure the Flutter app with FlutterFire CLI, then run flutter pub get.
3. Create the first admin account in Firebase Authentication Console.
4. In Firestore Console, create users/<admin uid> with name, email, role set to admin, and active set to true. Do not expose a public admin-registration flow.
5. Install Firebase CLI and deploy the Firestore rules from the repository root with: firebase deploy --only firestore:rules.
6. Run the app with flutter run.

## Adding a teacher on the free plan

1. The admin opens the Teachers section and chooses Add.
2. The admin enters the teacher name, email, and temporary password.
3. The app creates the Firebase Authentication account and teacher profile.
4. The teacher logs in with the supplied credentials.

The teacher does not use public student registration. The admin's session remains active while the secondary Auth instance creates the teacher account.

## Tests

Run flutter test after flutter pub get. Tests cover role decoding, unknown-role handling, role labels, and student/teacher landing screens. Deploy the Firestore rules before testing the admin promotion flow.


## Admin class management

The admin area can create, edit, archive, and restore classes. Each class stores a name, group, description, responsible teacher, student IDs, active state, and creation time. Admins can assign active teachers and enroll active students from the class details screen. Classes are archived rather than hard-deleted so later session and attendance records can retain their class reference.

Only admins can read and write class documents in this admin-focused phase. Teacher and student class access will be added with their role-specific flows. Sessions and attendance remain unavailable until their data flows and Firestore rules are added.
