require "fileutils"

PROJECT_NAME = "rails-api-session".freeze
PROJECT_REPO = "https://github.com/posiczko/#{PROJECT_NAME}.git".freeze

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("jumpstart-"))
    at_exit {FileUtils.remove_entry(tempdir)}
    git clone: [
      "--quiet",
      PROJECT_REPO,
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{jumpstart/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) {git checkout: branch}
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def add_cors
  say "> Adding cors", :blue
  say "> CORS is wide open. You may need to configure config/initializers/cors.rb.", :red
  say "> See https://gorails.com/episodes/cross-origin-resource-sharing-with-rails", :red
  copy_file "config/initializers/cors.rb", force: true
end

def add_critics
  say "> Adding critics", :blue
  directory "lib", force: :true
  copy_file ".rubocop.yml", force: :true
  copy_file ".gitignore", force: true
end

def add_gems
  say "> Adding gems", :blue

  gem "bcrypt"
  gem "fast_jsonapi"
  gem "foreman"
  gem "local_time"
  gem "name_of_person"
  gem "rack-cors"
  gem "rack-attack"
  gem "sidekiq"
  gem "whenever", require: false

  gem_group :development do
    gem "annotate"
    gem "brakeman"
    gem "flog"
    gem "flay"
    gem "guard-bundler"
    gem "guard-rspec", require: false
    gem "guard-spring"
    gem "rails_best_practices"
    gem "reek"
    gem "term-ansicolor"
  end

  gem_group :development, :test do
    gem "byebug", platforms: %i[mri mingw x64_mingw]
    gem "factory_bot_rails"
    gem "ffaker"
    gem "email_spec"
    gem "rubocop", require: false
    gem "rubocop-rspec"
  end

  gem_group :test do
    gem "database_cleaner"
    gem "rspec-rails"
    gem "rspec-sidekiq"
    gem "rspec-collection_matchers"
    gem "shoulda-matchers", require: false
    gem "vcr"
    gem "webmock"
  end
end

def add_guard
  say "> Adding Guard", :blue
  copy_file "Guardfile", force: :true
end

def add_rspec
  say "> Configuring RSpec", :blue
  copy_file ".rspec", force: :true
  directory "spec", force: :true
end

def add_sidekiq
  # TODO: Add add_sidekiq
  say "TBD:: add_sidekiq", :magenta
end

def add_users
  say "> Adding users.", :blue
  generate :model, "User",
    "username",
    "first_name",
    "last_name",
    "password_digest",
    "admin:boolean"

  # Set admin default to false
  in_root do
    migration = Dir.glob("db/migrate/*").max_by {|f| File.mtime(f)}
    gsub_file migration, /:admin/, ":admin, default: false"
    gsub_file migration, /:username/, ":username, null: false, default:\"\""
    insert_into_file migration, "    add_index :users, :username, unique: true", before: /^  end/
  end

  insert_into_file "app/models/user.rb", "
  has_secure_password

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false }

  def self.authenticate(username, password)
    user = User.find_by(username: username)
    user && user.authenticate(password)
  end
", before: /^end/

  # tests and factories are copied in add_rspec
  # controllers for session and user are copied in copy_templates
end

def add_whenever
  say "> Adding whenever.", :blue
  run "wheneverize ."
end

def check_rails_version
  return if rails_6?
  $stderr.puts <<-OOPS.strip_heredoc

  Oops. We've encountered an error:

  This version of rails-api template is meant to be run with Rails 6.

  Please install proper version of rails using either
    gem install rails --pre
  OOPS
  exit 1
end

def copy_templates
  say "> Copying templates", :blue
  directory "app", force: true
  directory "db", force: true
  directory "config", force: true
  copy_file "Procfile", force: :true

  insert_into_file "app/models/user.rb", "

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
", after: /config.api_only = true/
end

def prettify_gemfile
  # TODO: Add prettify_gemfile
  say "TBD: Prettify Gemfile.", :magenta
end

def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def rails_6?
  Gem::Requirement.new(">= 6.0.0.beta1", "< 7").satisfied_by? rails_version
end

def stop_spring
  run "spring stop"
end

#
# Main
#
check_rails_version
add_template_repository_to_source_path
add_gems
stop_spring
prettify_gemfile

after_bundle do
  add_rspec
  add_guard
  add_critics
  add_cors
  add_sidekiq
  add_whenever
  add_users
  copy_templates


  # Migrate
  rails_command "db:create"
  rails_command "db:create", env: :test
  rails_command "g annotate:install"
  rails_command "db:migrate"
  rails_command "db:migrate", env: :test
  rails_command "db:seed"

  # Commit everything to git
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }

  say
  say "API successfully created using #{PROJECT_NAME}!", :blue
  say
  say "To get started with your new app:", :green
  say "cd #{app_name} - Switch to your new app's directory."
  say "foreman start - Run Rails, sidekiq, and guard."
end
