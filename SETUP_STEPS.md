# Strata — Wall Assembly Embodied Carbon Calculator

© 2026 Studio G Architects. All rights reserved.

## What this version adds

This version keeps the calculator public while adding a separate, password-protected **Studio G Library** page.

Public users can still:

- Use the calculator, comparisons, material library, definitions, and method guide.
- Create custom materials and wall assemblies.
- Save materials and walls in their own browser.
- Download Excel and PDF results.

After entering the Studio G shared password, authorized users can:

- Save or update custom materials in a shared online database.
- Copy a shared material into the current browser for use in wall dropdowns.
- Edit or delete shared materials.
- Save or update the current wall assembly in the shared database.
- Load a shared wall as a new editable wall option.
- Copy a shared wall into the browser-only Saved Walls list.
- Lock the database again without affecting the public calculator.

The shared database is not contacted until the Studio G Library is unlocked.

## Package files

- `app.py` — complete Streamlit application
- `requirements.txt` — Python dependencies
- `.streamlit/config.toml` — Streamlit appearance settings
- `.streamlit/secrets.toml.example` — example only; do not place real secrets in GitHub
- `database_setup.sql` — database tables and security setup to run once in Supabase
- `.gitignore` — prevents local secrets and temporary data from being committed
- `assets/studio_g_logo.jpg` — logo used in exported graphics, Excel, and PDF reports
- `LICENSE.txt` — proprietary-use notice

# One-time setup required in addition to GitHub

Uploading the files to GitHub is not enough for the shared database. Complete Steps 1–4 once.

## Step 1 — Create a Supabase project

1. Go to Supabase and sign in.
2. Select **New project**.
3. Choose the Studio G organization or create one.
4. Enter a project name such as `Strata-studio-g`.
5. Create and safely store the Supabase database password.
6. Choose the nearest region.
7. Create the project and wait for setup to finish.

The public calculator will continue to work even if Supabase is temporarily unavailable. Only the protected shared library depends on it.

## Step 2 — Create the shared tables

1. In the Supabase project, open **SQL Editor**.
2. Select **New query**.
3. Open `database_setup.sql` from this package.
4. Copy the entire file into the SQL Editor.
5. Select **Run**.
6. Confirm that these two tables appear under **Table Editor**:
   - `wall_e_materials`
   - `wall_e_assemblies`

The SQL enables Row Level Security, removes public table access, and grants access only to Supabase's server-side service role.

## Step 3 — Copy the Supabase URL and server-side secret key

1. In Supabase, open the project's **Connect** dialog or **Settings → API Keys**.
2. Copy the project URL. It looks like:
   `https://YOUR-PROJECT-REF.supabase.co`
3. Create or copy a **Secret key** beginning with `sb_secret_`.
4. Do **not** use the publishable or anonymous key.
5. Do **not** place the secret key in GitHub, `app.py`, email, or a public document.

A legacy `service_role` key also works, but the newer `sb_secret_` key is preferred.

## Step 4 — Add the protected values to Streamlit Community Cloud

### For an existing deployed app

1. Open Streamlit Community Cloud.
2. Open the Strata app.
3. Open the app's **Settings** or **Manage app** menu.
4. Open **Secrets**.
5. Paste the following, replacing all three values:

```toml
[studio_g_library]
password = "YOUR-NEW-SHARED-STUDIO-G-PASSWORD"
supabase_url = "https://YOUR-PROJECT-REF.supabase.co"
supabase_secret_key = "sb_secret_YOUR-SERVER-SIDE-SECRET-KEY"
```

6. Select **Save**.
7. Reboot the app if Streamlit does not automatically restart it.

### For a new deployment

Paste the same TOML block into the **Secrets** field under **Advanced settings** while deploying.

### Password recommendations

- Use a new password that is not used for email, Microsoft 365, banking, or other systems.
- Store it in Studio G's password manager.
- Change it by editing the `password` value in Streamlit Secrets and saving/rebooting the app.
- The password must never be added to GitHub.

# GitHub deployment steps

1. Replace the repository's existing files with the files in this package.
2. Keep the folder structure exactly as provided, including:
   - `.streamlit/config.toml`
   - `assets/studio_g_logo.jpg`
3. Upload `database_setup.sql` and `.streamlit/secrets.toml.example`; they contain no real credentials.
4. Do **not** create or upload `.streamlit/secrets.toml` with real values.
5. Commit and push the changes.
6. Streamlit Community Cloud should rebuild the app from `app.py` and install the added `requests` dependency from `requirements.txt`.
7. Complete the Streamlit Secrets step above if it has not already been done.

# Test after deployment

1. Open Strata in a private/incognito browser window.
2. Confirm that **Build Assemblies**, **Compare Assemblies**, **Material Library**, **Definitions**, and **Method Guide** work without a password.
3. Open **Studio G Library**.
4. Enter an incorrect password and confirm access is denied.
5. Enter the correct password.
6. Under **Shared Materials**, create a small test material.
7. Open Strata in a second browser or computer, unlock Studio G Library, and confirm the test material appears.
8. Copy the test material to that browser and confirm it appears in the public Material Library and wall material dropdowns.
9. Create or rename a wall, save it under **Shared Wall Assemblies**, and confirm it can be loaded from the second browser.
10. Delete the test items when finished.

# Existing browser data

Existing custom materials and Saved Walls remain in the browser where they were originally created. They are not automatically uploaded.

To move them into the shared database:

- Open **Studio G Library → Shared Materials**, select each browser material, and choose **Save / update shared**.
- Open the desired wall under **Build Assemblies**, then go to **Studio G Library → Shared Wall Assemblies** and choose **Save / update shared**.

# Security behavior

- The public app never receives or displays the Supabase secret key.
- The key and shared password are read server-side from Streamlit Secrets.
- The new Supabase `sb_secret_` key is sent only in the `apikey` request header.
- Legacy service-role JWT keys are supported for existing projects.
- Supabase Row Level Security is enabled, and no anonymous or ordinary authenticated policies are created.
- The shared password unlock lasts only for the current Streamlit session.
- Five incorrect attempts cause a 60-second session lockout.
- Anyone who knows the one shared password can add, edit, or delete shared records. This setup does not identify which employee made a change.

# Troubleshooting

## “Studio G Library is not configured yet”

One or more values are missing from Streamlit Secrets. Confirm the section name is exactly `[studio_g_library]` and all three values are present.

## Database request failed with 401

- Confirm that the key is a Supabase **Secret key**, not a publishable key.
- Confirm the key and project URL belong to the same project.
- Remove accidental spaces before or after the values.
- Save Streamlit Secrets and reboot the app.

## Database request failed with 404 or a missing-table message

Run `database_setup.sql` in the correct Supabase project.

## Shared library opens but contains no records

This is normal for a new database. Save a browser material or current wall to create the first record.

## Public calculator works but shared library does not

This is expected when the database or secrets are not configured. Browser-only saving remains available.

## Changing the shared password

Edit only this value in Streamlit Secrets:

```toml
password = "YOUR-NEW-PASSWORD"
```

Save and reboot the app. No database changes are required.
