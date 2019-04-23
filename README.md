# Foo Rails API Template (Session Version)

## Introduction

A reasonably small, slightly opinionated Rails 6 experimental API template inspired by Chris Oliver's 
[Jumpstart Rails Template](https://github.com/excid3/jumpstart). This template was built to general messing around.
It is meant to be reasonably simple, providing minimal and foundational set of tools I use for
every day development.

## Features

* Your own user management with `User` model having `has_secure_password` and CRUD decisions
  being left up to you.
* Session based authentication (see resulting `application.rb`). Because why not?
* Code analysis using reek, flog, flay, rails_best_practices.
* Security scan capability using [breakman](https://brakemanscanner.org).
* Rubocop template based on [Thoughtbot's guides](https://github.com/thoughtbot/guides/tree/master/style/ruby).
* RSpec with a few handy tools (FactoryBot, Sidekiq, vcr, database cleaner, email spec).
* Cronjob management via [whenever](https://github.com/javan/whenever).
* JSON API using [fast_jsonapi](https://github.com/Netflix/fast_jsonapi).
* Guard for RSpec.

## Getting Started

### Prerequisites

* Ruby 2.5 or higher, preferrably 2.6.2
* Bundler - `gem install bundler`
* Rails 6.0.0.beta3 or later - currently installed via `gem install rails --pre` 
* PostgreSQL
* (Optional), process manager for Procfiles, such as foreman using `gem install foreman` or 
  [hivemind](https://github.com/DarthSim/hivemind) with `brew install hivemind`.
  
The template install process assumes you have a running PostgreSQL instance with your shell account capable of 
running `createdb` via `rails db:create`. This occurs as a part of the template run which creates
development and test databases.

### Creating a New App

You can use this template either online, using Github, like so

```bash
rails new myapp --api \
  -d postgresql \
  --skip-test \
  --skip-action-cable \
  --skip-turbolinks \
  --skip-active-storage \
  --template https://raw.githubusercontent.com/posiczko/foo-rails-api-session-template/master/template.rb
```

or you can clone it locally after you clone this repo:

```bash
git clone --depth 1 https://github.com/posiczko/foo-rails-api-session-template
cd rails-api-session
rails new foo-api --api -d postgresql \
  --skip-test \
  --skip-action-cable \
  --skip-turbolinks \
  --skip-active-storage \
  --template template.rb
mv foo-api ..
```

You can stand up your API using either:

```bash
foreman start
```

or 

```bash
hivemind
```
 
## Testing

* FactoryBot is included and linted before suite run.
* RSpec uses database_cleaner for testing with tests wrapped in the transaction
  for extra giddy-up factor.  
* Email spec is included with [matchers and helpers](https://github.com/bmabey/email-spec#rspec).
* Time helpers are included and enabled. See [documentation](http://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html).
* VCR and Mock are included and enabled for interaction with outside world. 
  See [VCR docs](https://relishapp.com/vcr/vcr/docs).
* Authentication helper is included for features and requests 
  which assumes `session_path` exists. See `spec/support/helpers/authentication_helper.rb`.  
* Non-memoizing JSON helper which parses the body is included and enabled.

## Project Code Analysis

Rake `analyzer` tasks provides analysis for your code:

    rake analyzer:all                   # run all code analyzing tools (reek, flog, flay, rails_best_practices)
    rake analyzer:flay                  # run flay and analyze code for structural similarities
    rake analyzer:flog:average          # Analyze for average code complexity
    rake analyzer:flog:each             # Analyze for individual code complexity
    rake analyzer:flog:total            # Analyze total code complexity with flog
    rake analyzer:reek                  # run reek and find code smells
    rake reek                           # Check for code smells
    rake stats                          # Report code statistics (KLOCs, etc) from the application or engine
    
## Cleanup

To remove your template-created app, use the following:

```bash
rails db:drop
spring stop
cd ..
rm -rf foo-api
```
    
