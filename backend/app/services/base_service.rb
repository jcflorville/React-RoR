# app/services/base_service.rb
class BaseService
  # Result object para retornos padronizados
  Result = Struct.new(:success?, :data, :errors, :message, keyword_init: true) do
    def failure?
      !success?
    end

    def self.success(data: nil, message: nil)
      new(success?: true, data: data, message: message, errors: {})
    end

    def self.failure(errors: {}, message: nil, data: nil)
      new(success?: false, errors: errors, message: message, data: data)
    end
  end

  private

  # Helper para criar resultado de sucesso
  def success(data: nil, message: nil)
    Result.success(data: data, message: message)
  end

  # Helper para criar resultado de erro
  def failure(errors: {}, message: nil, data: nil)
    Result.failure(errors: errors, message: message, data: data)
  end

  # Helper para formatar erros do ActiveRecord
  def format_errors(record)
    return {} unless record.respond_to?(:errors)

    record.errors.as_json
  end
end
