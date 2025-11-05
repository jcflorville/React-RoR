# app/services/base_service.rb
class BaseService
  # Result object para retornos padronizados
  Result = Struct.new(:success?, :data, :errors, :message, :metadata, keyword_init: true) do
    def failure?
      !success?
    end

    def self.success(data: nil, message: nil, metadata: nil)
      new(success?: true, data: data, message: message, errors: {}, metadata: metadata)
    end

    def self.failure(errors: {}, message: nil, data: nil, metadata: nil)
      new(success?: false, errors: errors, message: message, data: data, metadata: metadata)
    end
  end

  private

  # Helper para criar resultado de sucesso
  def success(data: nil, message: nil, metadata: nil)
    Result.success(data: data, message: message, metadata: metadata)
  end

  # Helper para criar resultado de erro
  def failure(errors: {}, message: nil, data: nil, metadata: nil)
    Result.failure(errors: errors, message: message, data: data, metadata: metadata)
  end

  # Helper para formatar erros do ActiveRecord
  def format_errors(record)
    return {} unless record.respond_to?(:errors)

    record.errors.as_json
  end
end
