const admin = require('firebase-admin');
const [,, email, newPassword] = process.argv;

if (!email || !newPassword) {
  console.log('Usage: node admin_reset.js email@example.com newpassword');
  process.exit(1);
}


admin.initializeApp({ projectId: 'med-intel-d0b1e' });
admin.auth().getUserByEmail(email.trim())
  .then(user => admin.auth().updateUser(user.uid, { password: newPassword }))
  .then(() => console.log(`Password changed for ${email}`))
  .catch(err => console.log('Error:', err.message))
  .finally(() => process.exit());
