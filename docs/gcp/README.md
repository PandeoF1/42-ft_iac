# GCP

## Setup service account

1. Go to the [Google Cloud Console IAM & Admin](https://console.cloud.google.com/iam-admin/serviceaccounts).
2. Click on "Create Service Account".
3. Fill in the service account name and description (ex: `42-ft-iac`).
4. Click "Create and continue".
5. In the " Grant this service account access to project" step, add the following roles:
   - `Compute Instance Admin (v1)`
   - `IAP-secured Tunnel User`
   - `Service Account User`
   - `Compute Admin`
   - `Create Service Accounts`
   - `Delete Service Accounts`
   - `Secret manager admin`
   - `Service Networking Admin`
   - `Cloud SQL Admin`
   - `Cloud Memorystore Admin`
6. Click done.
7. Download the JSON key file and at the root of the project, rename it to `gcp.json`.