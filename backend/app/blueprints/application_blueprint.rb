# Base blueprint class for all blueprints
# Provides common configuration and helpers
class ApplicationBlueprint < Blueprinter::Base
  # Helper method to check if an association should be included
  # Usage: if: include_condition(:tasks)
  def self.include_condition(association_name)
    ->(_, _, options) { options[:include]&.include?(association_name) }
  end
end
