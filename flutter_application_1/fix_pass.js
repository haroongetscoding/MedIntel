const {OAuth2Client} = require('google-auth-library');
const https = require('https');
const fs = require('fs');
const path = require('path');

const [,, email, newPassword] = process.argv;
if (!email || !newPassword) {
  console.log('Usage: node fix_pass.js email@example.com newpassword');
  process.exit(1);
}

const configPath = path.join(process.env.USERPROFILE, '.config', 'configstore', 'firebase-tools.json');
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const refreshToken = config.tokens.refresh_token;

const client = new OAuth2Client(
  '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com',
  undefined,
  undefined
);
client.setCredentials({ refresh_token: refreshToken });

async function main() {
  const { token } = await client.getAccessToken();
  const projectId = 'med-intel-d0b1e';

  // Lookup user by email
  const lookup = await apiCall(token, projectId, 'accounts:lookup', { email: [email.trim()] });
  if (!lookup.users || lookup.users.length === 0) {
    console.log('Error: No user found with email', email);
    process.exit(1);
  }
  const uid = lookup.users[0].localId;
  console.log('Found user:', uid);

  // Update password
  await apiCall(token, projectId, 'accounts:update', { localId: uid, password: newPassword });
  console.log(`Password changed for ${email}`);
}

function apiCall(token, projectId, endpoint, body) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const opts = {
      hostname: 'identitytoolkit.googleapis.com',
      path: `/v1/projects/${projectId}/${endpoint}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
        'Content-Length': Buffer.byteLength(data),
      },
    };
    const req = https.request(opts, res => {
      let body = '';
      res.on('data', d => body += d);
      res.on('end', () => {
        const parsed = JSON.parse(body);
        if (res.statusCode >= 400) reject(new Error(parsed.error?.message || body));
        else resolve(parsed);
      });
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

main().catch(err => {
  console.log('Error:', err.message);
  process.exit(1);
});
