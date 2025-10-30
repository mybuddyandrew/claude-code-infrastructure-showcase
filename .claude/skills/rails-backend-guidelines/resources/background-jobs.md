# Background Jobs - Async Processing

## Creating Jobs

```bash
rails generate job WelcomeEmail
rails generate job DataExport
```

## Basic Job

```ruby
# app/jobs/welcome_email_job.rb
class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserMailer.welcome_email(user).deliver_now
  end
end

# Enqueue
WelcomeEmailJob.perform_later(user)

# Enqueue with delay
WelcomeEmailJob.set(wait: 1.hour).perform_later(user)

# Enqueue at specific time
WelcomeEmailJob.set(wait_until: Date.tomorrow.noon).perform_later(user)
```

## Sidekiq Configuration

```ruby
# Gemfile
gem 'sidekiq'

# config/application.rb
config.active_job.queue_adapter = :sidekiq

# config/sidekiq.yml
:queues:
  - default
  - mailers
  - exports
```

## Retries and Error Handling

```ruby
class DataExportJob < ApplicationJob
  queue_as :exports
  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(user, data)
    # Export logic
  end
end
```

## See Also
- [services.md](services.md) - Service object patterns
