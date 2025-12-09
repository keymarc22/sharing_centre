# Compatibility shim: some tools call `rails g tailwindcss:install` (generator)
# but `tailwindcss-rails` exposes a Rails command `rails tailwindcss:install`.
# This generator delegates to that command so existing instructions/tools keep working.
require "rails/generators"

module Tailwindcss
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Delegate `rails g tailwindcss:install` to `bin/rails tailwindcss:install`."

      def install_tailwindcss
        say_status :info, "Delegating to `bin/rails tailwindcss:install`"
        unless system("bin/rails tailwindcss:install")
          say_status :error, "Failed to run `bin/rails tailwindcss:install`. See output above."
          exit(1)
        end
      end
    end
  end
end
