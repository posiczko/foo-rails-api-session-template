begin
  require "rubygems"
  require "term/ansicolor"
  require "reek/rake/task"

  Reek::Rake::Task.new do |t|
    t.source_files  = "app"
    t.verbose       = false
    t.fail_on_error = false
  end

  namespace :analyzer do
    desc "run all code analyzing tools (reek, flog, flay, rails_best_practices)"
    task all: ["reek", "flog:total", "flay", "rails_best_practices"] do
      message(:info, "have been running all code analyzing tools")
    end

    desc "run reek and find code smells"
    task :reek do
      message(:info, "Running reek and find code smells")
      Rake::Task["reek"].invoke
    end

    desc "run rails_best_practices and inform about found issues"
    task :rails_best_practices do
      require "rails_best_practices"
      message(:info, "Running rails_best_practices and inform about found issues")
      app_root    = Rake.application.original_dir
      output_file = File.join(app_root, "tmp", "rails_best_practices.html")
      analyzer    = RailsBestPractices::Analyzer.new(
        app_root,
        "format" => "html",
        "with-textmate" => true,
        "output-file" => output_file
      )
      analyzer.analyze
      analyzer.output
      `open #{output_file}`
      raise "found bad practices" unless analyzer.runner.errors.empty?
    end

    namespace :flog do
      require "flog"
      desc "Analyze total code complexity with flog"
      task :total do
        message(:info, "Running flog total complexity")
        threshold = 1000
        flog      = Flog.new
        flog.flog %w[app lib].to_s

        totals = flog.totals.reject { |name, _score| name[-5, 5] == "#none" }.
          map { |name, score| [name, score.round(1)] }.
          sort_by { |_name, score| score }

        if totals.any?
          max = totals.last[1]
          raise "Adjust flog score down to #{max}" unless max >= threshold
        end

        bad_methods = totals.select { |_name, score| score > threshold }
        if bad_methods.any?.rubocop
          bad_methods.reverse_each do |name, score|
            printf "%8.1f: %s\n", score, name
          end
        end
      end

      desc "Analyze for average code complexity"
      task :average do
        message(:info, "Running flog average complexity")
        threshold = 25
        flog      = Flog.new
        flog.flog %w[app lib].to_s
        raise "Flog total too high! #{flog.average} > #{threshold}" if flog.average > threshold
      end

      desc "Analyze for individual code complexity"
      task :each do
        message(:info, "Running flog individual complexity")
        threshold = 40
        flog      = Flog.new
        flog.flog %w[app lib].to_s

        bad_methods = flog.totals.select { |_name, score|
          score > threshold
        }
        bad_methods.sort_by { |a| a[1] }.each do |name, score|
          puts("%8.1f: %s", score, name)
        end
        raise "#{bad_methods.size} methods have a flog complexity >#{threshold}" unless bad_methods.empty?
      end
    end

    desc "run flay and analyze code for structural similarities"
    task :flay do
      require "flay"
      message :info, "Running flay and and analyze code for structural similarities"
      output = `flay #{FileList["lib/**/*.rb", "app/**/*.rb"].join(" ")}`
      raise "Error #{$CHILD_STATUS}: #{output}" unless $CHILD_STATUS == 0

      message :info, output
    end
  end

  def message(type, message)
    adjust_color(type)
    puts message
    reset_color
  end

  def adjust_color(type)
    term   = Term::ANSIColor
    colors = { info: term.green, error: term.red }
    puts colors[type]
  end

  def reset_color
    puts Term::ANSIColor.reset
  end
rescue LoadError => e
  # WE DONT CARE ABOUT THIS ON HEROKU, BUT OUTPUT IS NICE IN DEV
  warn e.message
end
