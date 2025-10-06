require_relative 'concerns/conditional_includes'

class ApplicationSerializer
  include JSONAPI::Serializer
  include ConditionalIncludes
end
