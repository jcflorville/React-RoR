module Drawings
  class Updater < BaseService
    def self.call(drawing:, params:)
      new(drawing: drawing, params: params).call
    end

    def initialize(drawing:, params:)
      @drawing = drawing
      @params = params
    end

    def call
      # Optimistic locking check
      if @params[:lock_version] && @drawing.lock_version != @params[:lock_version].to_i
        return failure(message: 'Drawing was modified by another user. Please refresh and try again.')
      end

      if @drawing.update(update_params)
        success(data: @drawing, message: 'Drawing updated successfully')
      else
        failure(errors: format_errors(@drawing), message: 'Failed to update drawing')
      end
    end

    private

    def update_params
      {
        title: @params[:title],
        canvas_data: @params[:canvas_data]
      }.compact
    end
  end
end
