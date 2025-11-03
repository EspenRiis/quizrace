module Api
  module V1
    class QuestionsController < BaseController
      before_action :set_quiz
      before_action :set_question, only: [:update, :destroy]

      def index
        @questions = @quiz.questions.order(:question_number)
        render json: @questions
      end

      def create
        @question = @quiz.questions.new(question_params)

        # Auto-increment question number
        @question.question_number ||= @quiz.questions.maximum(:question_number).to_i + 1

        if @question.save
          @quiz.update(questions_count: @quiz.questions.count)
          render json: @question, status: :created
        else
          render_error(@question.errors.full_messages.join(', '), status: :unprocessable_entity)
        end
      end

      def update
        if @question.update(question_params)
          render json: @question
        else
          render_error(@question.errors.full_messages.join(', '), status: :unprocessable_entity)
        end
      end

      def destroy
        @question.destroy
        @quiz.update(questions_count: @quiz.questions.count)
        head :no_content
      end

      private

      def set_quiz
        @quiz = Quiz.find(params[:quiz_id])
      end

      def set_question
        @question = @quiz.questions.find(params[:id])
      end

      def question_params
        params.require(:question).permit(
          :sentence,
          :question_type,
          :time_limit,
          :points,
          :question_number,
          :correct_answer,
          possible_answers: []
        )
      end
    end
  end
end
