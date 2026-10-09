const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const { HttpsError, onCall } = require('firebase-functions/v2/https');

initializeApp();

const db = getFirestore();
const auth = getAuth();

exports.createManagedUser = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Connectez-vous pour continuer.');
  }

  const callerSnapshot = await db.collection('users').doc(request.auth.uid).get();
  const caller = callerSnapshot.data();
  if (!callerSnapshot.exists || caller.role !== 'admin' || caller.active === false) {
    throw new HttpsError('permission-denied', 'Action réservée à un administrateur.');
  }

  const data = request.data || {};
  const name = typeof data.name === 'string' ? data.name.trim() : '';
  const email = typeof data.email === 'string' ? data.email.trim().toLowerCase() : '';
  const password = typeof data.password === 'string' ? data.password : '';
  const role = data.role;

  if (name.length < 3 || !email.includes('@') || password.length < 6) {
    throw new HttpsError('invalid-argument', 'Nom, email ou mot de passe invalide.');
  }
  if (role !== 'teacher' && role !== 'student') {
    throw new HttpsError('invalid-argument', 'Seuls les comptes enseignant et étudiant peuvent être créés ici.');
  }

  let account;
  try {
    account = await auth.createUser({ email, password, displayName: name });
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      throw new HttpsError('already-exists', 'Cet email est déjà utilisé.');
    }
    if (error.code === 'auth/invalid-email' || error.code === 'auth/weak-password' || error.code === 'auth/invalid-password') {
      throw new HttpsError('invalid-argument', 'Email ou mot de passe invalide.');
    }
    throw new HttpsError('internal', 'Création impossible. Réessayez.');
  }

  try {
    await db.collection('users').doc(account.uid).create({
      name,
      email: account.email || email,
      role,
      active: true,
      createdAt: FieldValue.serverTimestamp(),
    });
  } catch (_) {
    try {
      await auth.deleteUser(account.uid);
    } catch (_) {
      // Preserve the original Firestore failure; operators can reconcile the account.
    }
    throw new HttpsError('internal', 'Profil utilisateur impossible à créer.');
  }

  return { uid: account.uid };
});
