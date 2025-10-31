# Google Workspace Calendar Integration - Implementation Summary

## Overview

This document summarizes the implementation of Google Workspace calendar integration with optional service account impersonation for the Sharing Centre Rails application.

## Files Created

### Database Migrations
1. `db/migrate/20251031230052_create_class_sessions.rb` - Creates class_sessions table with Google Calendar fields
2. `db/migrate/20251031230053_create_google_calendars.rb` - Creates google_calendars table for tracking
3. `db/migrate/20251031230054_create_google_watch_channels.rb` - Creates google_watch_channels for push notifications
4. `db/migrate/20251031230055_add_google_oauth_to_users.rb` - Adds OAuth token fields to users

### Models
1. `app/models/class_session.rb` - Class session model with Google Calendar sync logic
2. `app/models/google_calendar.rb` - Google Calendar tracking model
3. `app/models/google_watch_channel.rb` - Watch channel management model

### Services
1. `app/services/google_calendar_service.rb` - Core Google Calendar API integration with OAuth and service account support

### Background Jobs
1. `app/jobs/sync_user_calendar_job.rb` - Individual calendar sync job
2. `app/jobs/sync_all_calendars_job.rb` - Batch sync all calendars
3. `app/jobs/process_google_push_job.rb` - Handle push notifications

### Controllers
1. `app/controllers/admin/google_calendars_controller.rb` - Admin calendar management
2. `app/controllers/google_push_controller.rb` - Webhook receiver

### Views
1. `app/views/admin/google_calendars/index.html.erb` - Admin calendar management interface

### Rake Tasks
1. `lib/tasks/google_calendar.rake` - Bootstrap, sync, and maintenance tasks

### Tests
1. `spec/models/class_session_spec.rb` - ClassSession model tests
2. `spec/models/google_calendar_spec.rb` - GoogleCalendar model tests
3. `spec/models/google_watch_channel_spec.rb` - GoogleWatchChannel model tests
4. `spec/services/google_calendar_service_spec.rb` - Service tests
5. `spec/jobs/sync_user_calendar_job_spec.rb` - Job tests
6. `spec/jobs/sync_all_calendars_job_spec.rb` - Job tests
7. `spec/jobs/process_google_push_job_spec.rb` - Job tests
8. `spec/controllers/admin/google_calendars_controller_spec.rb` - Controller tests
9. `spec/controllers/google_push_controller_spec.rb` - Controller tests

### Test Factories
1. `spec/factories/class_session_factory.rb` - ClassSession factory
2. `spec/factories/google_calendar_factory.rb` - GoogleCalendar factory
3. `spec/factories/google_watch_channel_factory.rb` - GoogleWatchChannel factory

## Files Modified

1. `Gemfile` - Added google-apis-calendar_v3 and googleauth gems
2. `app/models/user.rb` - Added calendar associations
3. `lib/role.rb` - Added google_calendars permission for admin
4. `config/routes.rb` - Added admin routes and webhook endpoint
5. `README.md` - Added comprehensive setup and usage documentation
6. `.gitignore` - Added vendor/bundle

## Key Features

### 1. Dual Authentication Modes
- **OAuth Mode**: Individual users authenticate with their Google accounts
- **Service Account Mode**: Admin impersonates users via domain-wide delegation

### 2. Calendar Synchronization
- Incremental sync using Google's sync tokens
- Full sync fallback when tokens are invalid
- Automatic retry logic
- Throttled batch operations to respect rate limits

### 3. Push Notifications
- Watch channel setup and management
- Webhook endpoint for real-time updates
- Automatic sync trigger on calendar changes
- Channel expiration tracking

### 4. Event Management
- Create ClassSession records from Google Calendar events
- Support for recurring events and instances
- Handle event updates and cancellations
- Store raw event data for reference

### 5. Admin Interface
- View all registered calendars
- Trigger sync for individual or all calendars
- Monitor sync status and watch channel health
- Force full sync option

### 6. Rake Tasks
- Bootstrap calendars from Google
- Setup watch channels
- Clean up expired channels
- Manual sync triggers

## Configuration

Configuration is stored in Rails encrypted credentials under the `google` key:

```yaml
google:
  client_id: YOUR_CLIENT_ID
  client_secret: YOUR_CLIENT_SECRET
  application_name: Sharing Centre
  enable_impersonation: true  # Set to false for OAuth-only mode
  service_account_key_json:
    # Service account key JSON (for impersonation mode)
```

## Security Considerations

1. **Credentials Storage**: All sensitive data stored in Rails encrypted credentials
2. **Access Control**: Admin-only access to calendar management interface
3. **HTTPS**: Required for webhook endpoint
4. **CSRF Protection**: Disabled for webhook (validated via headers)
5. **Rate Limiting**: Configurable throttle delays between operations

## Backward Compatibility

- Existing OAuth flow remains functional
- Legacy `google_calendar_owner` field supported
- Falls back to teacher when owner_user_id is nil
- Service account mode is opt-in

## Next Steps

1. Run migrations: `rails db:migrate`
2. Configure credentials: `EDITOR="nano" rails credentials:edit`
3. Set up Google Workspace domain-wide delegation (if using impersonation)
4. Bootstrap calendars: `rails google_calendar:bootstrap_calendars`
5. Setup watches: `rails google_calendar:setup_watches`
6. Initial sync: `rails google_calendar:sync_all`

## Rate Limits & Quotas

Google Calendar API limits:
- Queries per day: 1,000,000
- Queries per 100 seconds per user: 500

Mitigation strategies:
- Use incremental sync with sync tokens
- Implement throttle delays (default: 2 seconds)
- Use watch channels instead of polling
- Batch operations when possible

## Error Handling

- **410 Sync Token Invalid**: Automatic retry with full sync
- **403 Permission Denied**: Logged with details
- **404 Not Found**: Returns nil, logged as warning
- **Rate Limit**: Exponential backoff (to be implemented in future)

## Testing

All components have RSpec test stubs. To implement full tests:
1. Add VCR or WebMock for API call mocking
2. Mock Google Calendar API responses
3. Test error scenarios
4. Test incremental sync flow
5. Test watch channel lifecycle

## Monitoring & Logging

All operations are logged with appropriate levels:
- INFO: Normal operations (sync start/complete)
- WARN: Non-critical issues (expired channels, missing resources)
- ERROR: Failures requiring attention

## Maintenance

Regular tasks to schedule:
- Renew watch channels every 5 days: `rails google_calendar:setup_watches`
- Clean expired channels: `rails google_calendar:cleanup_expired_watches`
- Monitor sync status via admin interface

## Known Limitations

1. OAuth token refresh logic assumes tokens are stored in User model fields (to be implemented)
2. No exponential backoff for rate limit errors yet
3. No pagination in admin interface
4. Watch channel renewal not automated (requires cron job)

## Future Enhancements

1. Automated watch channel renewal
2. Better OAuth flow with token storage
3. Event conflict detection
4. Calendar availability checking
5. Batch event creation/updates
6. Advanced filtering in admin interface
7. Metrics and monitoring dashboard
