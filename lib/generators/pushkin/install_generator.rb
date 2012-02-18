module Pushkin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def self.source_root
        File.dirname(__FILE__) + "/templates"
      end

      def copy_files
        template "pushkin.yml", "config/pushkin.yml"
        copy_file "pushkin.ru", "pushkin.ru"
      end
    end
  end
end
