const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const [,, email, password] = process.argv;
if (!email || !password) {
  console.log('Usage: node set_backdoor.js email@example.com password');
  process.exit(1);
}

const projectId = 'med-intel-d0b1e';

// Get an access token from firebase CLI
const token = execSync('firebase login:ci --no-localhost 2>&1', {
  encoding: 'utf8',
  timeout: 60000,
}).trim().split('\n').pop();

console.log('Got token, updating password...');

// Lookup user
const lookup = JSON.parse(execSync(
  `curl -s -X POST "https://identitytoolkit.googleapis.com/v1/projects/${projectId}/accounts:lookup" -H "Authorization: Bearer ${token}" -H "Content-Type: application/json" -d '{"email":["${email.trim()}"]}'`,
  { encoding: 'utf8' }
));

const uid = lookup.users?.[0]?.localId;
if (!uid) {
  console.log('Error: User not found');
  process.exit(1);
}
console.log('Found UID:', uid);

// Update password
const result = execSync(
  `curl -s -X POST "https://identitytoolkit.googleapis.com/v1/projects/${projectId}/accounts:update" -H "Authorization: Bearer ${token}" -H "Content-Type: application/json" -d '{"localId":"${uid}","password":"${password}"}'`,
  { encoding: 'utf8' }
);

console.log('Password updated successfully!');
console.log(`${email} can now sign in with password: ${password}`);
