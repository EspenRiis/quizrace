module Api
  module V1
    class QuizzesController < BaseController
      before_action :set_quiz, only: [:show, :update, :destroy]

      def index
        @quizzes = Quiz.includes(:questions).order(created_at: :desc)
        render json: @quizzes.as_json(include: { questions: { only: [:id, :sentence, :question_type, :time_limit, :points] } })
      end

      def show
        render json: @quiz.as_json(include: { questions: { except: [:created_at, :updated_at] } })
      end

      def create
        @quiz = Quiz.new(quiz_params)

        if @quiz.save
          render json: @quiz, status: :created
        else
          render_error(@quiz.errors.full_messages.join(', '), status: :unprocessable_entity)
        end
      end

      def update
        if @quiz.update(quiz_params)
          render json: @quiz
        else
          render_error(@quiz.errors.full_messages.join(', '), status: :unprocessable_entity)
        end
      end

      def destroy
        @quiz.destroy
        head :no_content
      end

      private

      def set_quiz
        @quiz = Quiz.find(params[:id])
      end

      def quiz_params
        params.require(:quiz).permit(:name, :created_by_id)
      end
    end
  end
end
