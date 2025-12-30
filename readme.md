## Jeremy


[Windows looking waybar for gaming pc](https://github.com/Harsh-bin/waybar-config)

move: C:\Users\jcehe\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1


# aerc Gmail OAuth2 Setup

This document explains how to configure **aerc** to work with **Gmail using OAuth2 authentication**.

Source: https://tilde.club/~djhsu/aerc-gmail-oauth2.html

---

## Requirements

- aerc installed
- Python installed
- Gmail account

---

## Step 1: Create Google Cloud Project

1. Create a new project in Google Cloud Console
2. Enable the **Gmail API**
3. Create **OAuth credentials**

Use the following settings:

- Application type: Web application
- Authorized redirect URI: https://oauth2.dance/

Save these values:

- `client_id`
- `client_secret`

---

## Step 2: Generate OAuth2 Refresh Token

Download `oauth2.py` from Google’s OAuth tools repository.

Run the following command:

python oauth2.py --generate_oauth2_token --user you@gmail.com --client_id CLIENT_ID --client_secret CLIENT_SECRET

Steps:

1. The script prints a URL — open it in your browser
2. Authenticate with Google
3. You will be redirected to https://oauth2.dance/
4. Copy the verification code
5. Paste it back into the script

Save the **Refresh Token** output.

---

## Step 3: Configure aerc

Edit the file:

~/.config/aerc/accounts.conf

Add the following configuration:

[account-name]
source = imaps+oauthbearer://you%40gmail.com:REFRESH_TOKEN@imap.gmail.com:993?client_id=CLIENT_ID&client_secret=CLIENT_SECRET&token_endpoint=https%3A%2F%2Foauth2.googleapis.com%2Ftoken
outgoing = smtps+oauthbearer://you%40gmail.com:REFRESH_TOKEN@smtp.gmail.com:465?client_id=CLIENT_ID&client_secret=CLIENT_SECRET&token_endpoint=https%3A%2F%2Foauth2.googleapis.com%2Ftoken
default = INBOX

---

## Encoding Notes

- Replace `@` with `%40` in the email address
- Replace `/` with `%2F` in the refresh token

Example:

you@gmail.com → you%40gmail.com

---

## Final Notes

- aerc automatically refreshes access tokens
- No app password required
- IMAP and SMTP both use OAuth2
