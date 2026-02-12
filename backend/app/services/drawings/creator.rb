module Drawings
  class Creator < BaseService
    def self.call(user:, params:)
      new(user: user, params: params).call
    end

    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      drawing = @user.drawings.new(drawing_params)

      if drawing.save
        success(data: drawing, message: 'Drawing created successfully')
      else
        failure(errors: format_errors(drawing), message: 'Failed to create drawing')
      end
    end

    private

    def drawing_params
      {
        title: @params[:title] || 'Untitled',
        canvas_data: @params[:canvas_data] || default_canvas_data
      }
    end

    def default_canvas_data
      {
        version: '5.3.0',
        objects: [],
        background: '#ffffff'
      }
    end
  end
end
