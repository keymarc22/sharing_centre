### Proyecto freelance para Sharing centre

- Gestion de estudiantes (Clases personalizados y progreso)
- Agenda de clases
- Gestion administrativa

## Stack
- Ruby on rails
- Hotwire (Turbo)
- sqlite

## Google Calendar Integration

This application supports Google Calendar integration with two modes:
1. **OAuth Mode**: Individual users connect their Google accounts using OAuth
2. **Service Account Mode (Enterprise)**: Admin can impersonate users via Google Workspace domain-wide delegation

### Setup Google Calendar Integration

#### 1. OAuth Mode (Per-User Authentication)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Calendar API
4. Create OAuth 2.0 credentials:
   - Application type: Web application
   - Add authorized redirect URIs for your application
5. Add credentials to Rails credentials:

```bash
EDITOR="nano" rails credentials:edit
```

Add the following structure:

```yaml
google:
  client_id: YOUR_CLIENT_ID
  client_secret: YOUR_CLIENT_SECRET
  application_name: Sharing Centre
  enable_impersonation: false  # Set to true for enterprise mode
```

#### 2. Service Account Mode (Domain-Wide Delegation)

For enterprise deployments where an admin needs to access all users' calendars:

##### Step 1: Create a Service Account

1. In Google Cloud Console, go to "IAM & Admin" > "Service Accounts"
2. Click "Create Service Account"
3. Give it a name (e.g., "sharing-centre-calendar-sync")
4. Grant appropriate roles (optional)
5. Click "Done"

##### Step 2: Create Service Account Key

1. Click on the service account you just created
2. Go to "Keys" tab
3. Click "Add Key" > "Create new key"
4. Choose JSON format
5. Download the JSON key file (keep it secure!)

##### Step 3: Enable Domain-Wide Delegation

1. In the service account details, check "Enable Google Workspace Domain-wide Delegation"
2. Note the "Client ID" (you'll need this for the next step)
3. Optionally set a product name

##### Step 4: Grant Domain-Wide Authority

1. Go to your [Google Workspace Admin Console](https://admin.google.com/)
2. Navigate to "Security" > "Access and data control" > "API controls"
3. Scroll to "Domain-wide delegation"
4. Click "Add new"
5. Enter the Client ID from your service account
6. Add the OAuth scope: `https://www.googleapis.com/auth/calendar`
7. Click "Authorize"

##### Step 5: Add Service Account Key to Rails Credentials

```bash
EDITOR="nano" rails credentials:edit
```

Add the service account key JSON:

```yaml
google:
  client_id: YOUR_OAUTH_CLIENT_ID  # Still needed for OAuth flow
  client_secret: YOUR_OAUTH_CLIENT_SECRET
  application_name: Sharing Centre
  enable_impersonation: true  # Enable service account mode
  service_account_key_json:
    type: service_account
    project_id: your-project-id
    private_key_id: your-private-key-id
    private_key: "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
    client_email: your-service-account@your-project.iam.gserviceaccount.com
    client_id: your-service-account-client-id
    auth_uri: https://accounts.google.com/o/oauth2/auth
    token_uri: https://oauth2.googleapis.com/token
    auth_provider_x509_cert_url: https://www.googleapis.com/oauth2/v1/certs
    client_x509_cert_url: https://www.googleapis.com/robot/v1/metadata/x509/...
```

### Using the Integration

#### Bootstrap Google Calendars

After setting up credentials, bootstrap calendar records for existing users:

```bash
rails google_calendar:bootstrap_calendars
```

This will:
- List all calendars for each user
- Create `GoogleCalendar` records in the database

#### Setup Watch Channels (Push Notifications)

To receive real-time updates when calendar events change:

```bash
# Set webhook URL (default uses your app's root URL + /google/calendar/push)
export GOOGLE_CALENDAR_WEBHOOK_URL="https://your-domain.com/google/calendar/push"

rails google_calendar:setup_watches
```

**Note**: Your webhook URL must be publicly accessible and use HTTPS.

#### Sync Calendars

Manually trigger a sync for all calendars:

```bash
# Standard incremental sync
rails google_calendar:sync_all

# Force full sync (ignores sync tokens)
FORCE_FULL_SYNC=true rails google_calendar:sync_all

# Adjust throttle delay (default: 2 seconds between jobs)
THROTTLE_DELAY=5 rails google_calendar:sync_all
```

#### Admin Interface

Admins can manage calendar syncs via the web interface:

- View all calendars: `/admin/google_calendars`
- Sync specific calendar: POST `/admin/google_calendars/:id/sync_now`
- Sync all calendars: POST `/admin/google_calendars/sync_all`
- Fetch specific event: POST `/admin/google_calendars/:id/fetch_event?event_id=EVENT_ID`

### Rate Limiting and Quotas

Google Calendar API has the following quotas (as of 2024):
- **Queries per day**: 1,000,000
- **Queries per 100 seconds per user**: 500

**Best Practices**:
- Use incremental sync with `sync_token` whenever possible
- Implement exponential backoff for rate limit errors
- Use watch channels instead of polling for real-time updates
- Batch operations and add throttle delays when syncing multiple calendars

**Throttling Configuration**:
- Default throttle delay: 2 seconds between sync jobs
- Adjust via `THROTTLE_DELAY` environment variable
- For large deployments, increase throttle delay to avoid rate limits

### Troubleshooting

#### Sync Token Invalid (410 Error)

If you receive a 410 error, the sync token has expired. The system will automatically:
1. Clear the invalid sync token
2. Retry with a full sync

You can also manually clear sync tokens:

```ruby
GoogleCalendar.find_by(calendar_id: 'calendar_id').clear_sync_token!
```

#### Permission Denied (403 Error)

Check that:
1. Service account has domain-wide delegation enabled
2. Scope `https://www.googleapis.com/auth/calendar` is authorized in Google Workspace Admin Console
3. User's email matches their Google Workspace account

#### Watch Channel Expired

Watch channels expire after 7 days. Run the cleanup task regularly:

```bash
rails google_calendar:cleanup_expired_watches
```

Consider setting up a cron job to renew watches before expiration:

```ruby
# config/schedule.rb (if using whenever gem)
every 5.days do
  rake "google_calendar:setup_watches"
end
```

### Security Considerations

1. **Never commit credentials**: Service account keys should only be in Rails encrypted credentials
2. **Restrict access**: Only admin users should access the admin calendar interface
3. **HTTPS required**: Webhook endpoints must use HTTPS
4. **Validate notifications**: The system validates `X-Goog-Channel-ID` headers
5. **Audit logs**: All sync operations are logged for debugging and auditing