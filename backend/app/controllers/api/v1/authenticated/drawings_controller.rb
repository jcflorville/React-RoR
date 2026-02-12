module Api
  module V1
    module Authenticated
      class DrawingsController < BaseController
        before_action :set_drawing, only: [ :show, :update, :destroy ]

        def index
          drawings = current_user.drawings.order(created_at: :desc)
          render_success(drawings, 'Drawings retrieved successfully')
        end

        def show
          render_success(@drawing, 'Drawing retrieved successfully')
        end

        def create
          result = Drawings::Creator.call(user: current_user, params: drawing_params)

          if result.success?
            render_success(result.data, result.message, :created)
          else
            render_error(result.message, result.errors, :unprocessable_content)
          end
        end

        def update
          result = Drawings::Updater.call(drawing: @drawing, params: drawing_params)

          if result.success?
            render_success(result.data, result.message)
          else
            render_error(result.message, result.errors, :unprocessable_content)
          end
        end

        def destroy
          if @drawing.destroy
            render_success(nil, 'Drawing deleted successfully')
          else
            render_error('Failed to delete drawing', nil, :unprocessable_content)
          end
        end

        private

        def set_drawing
          @drawing = current_user.drawings.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render_error('Drawing not found', nil, :not_found)
        end

        def drawing_params
          params.require(:drawing).permit(:title, :lock_version, canvas_data: {})
        end
      end
    end
  end
end
