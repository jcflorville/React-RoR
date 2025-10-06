module ConditionalIncludes
  extend ActiveSupport::Concern

  class_methods do
    def conditional_has_many(name, **options)
      has_many name, if: include_condition(name), **options
    end

    def conditional_belongs_to(name, **options)
      belongs_to name, if: include_condition(name), **options
    end

    def conditional_has_one(name, **options)
      has_one name, if: include_condition(name), **options
    end

    private

    def include_condition(relationship_name)
      Proc.new { |record, params|
        params && params[:include]&.include?(relationship_name.to_sym)
      }
    end
  end
end
