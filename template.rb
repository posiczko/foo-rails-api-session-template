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

def add_critics
  say "Adding critics"
  directory "lib", force: :true
  copy_file ".rubocop"
end

def add_gems
  gem "bcrypt"
  gem "fast_jsonapi"
  gem "foreman"
  gem "local_time"
  gem "name_of_person"
  gem "rack-cors"
  gem "sidekiq"
  gem "whenever", require: false
  
  gem_group :development do
    gem "term-ansicolor"
    gem "flog"
    gem "flay"
    gem "guard-bundler"
    gem "guard-rspec", require: false
    # gem "guard-spring"
    gem "rails_best_practices"
    gem "reek"
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
  say "Adding Guard"
  copy_file "Guardfile"
end

def add_rspec
  say "Configuring RSpec"
  copy_file ".rspec"
  directory "spec", force: :true
end

def add_sidekiq
  # TODO: Add add_sidekiq
  say "TBD:: add_sidekiq"
end

def add_users
  # TODO: Add add_users
  say "TBD:: Adding users."
end

def add_whenever
  # TODO: Add whenever
  say "Adding whenever."
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

def prettify_gemfile
  # TODO: Add prettify_gemfile
  say "TBD: Prettify Gemfile."
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
  add_sidekiq
  add_whenever
  
  # Migrate
  rails_command "db:create"
  rails_command "db:migrate"
  
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
