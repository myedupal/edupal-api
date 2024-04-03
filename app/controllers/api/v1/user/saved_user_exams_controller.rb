class Api::V1::User::SavedUserExamsController < Api::V1::User::ApplicationController
  before_action :set_saved_user_exam, only: [:destroy]
  before_action :set_saved_user_exams, only: [:index]

  def index
    @pagy, @saved_user_exams = pagy(@saved_user_exams)
    render json: @saved_user_exams, include: ['user_exam.created_by', 'user_exam.subject.curriculum', 'user_exam.user_exam_questions']
  end

  def create
    @saved_user_exam = current_user.saved_user_exams.find_or_initialize_by(saved_user_exam_params)
    pundit_authorize(@saved_user_exam)

    if @saved_user_exam.save
      render json: @saved_user_exam, include: ['user_exam.created_by', 'user_exam.subject.curriculum', 'user_exam.user_exam_questions']
    else
      render json: ErrorResponse.new(@saved_user_exam), status: :unprocessable_entity
    end
  end

  def destroy
    if @saved_user_exam.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@saved_user_exam), status: :unprocessable_entity
    end
  end

  private

    def set_saved_user_exam
      @saved_user_exam = pundit_scope(SavedUserExam.preload({ user_exam: [:created_by, :user_exam_questions, { subject: :curriculum }] })).find(params[:id])
      pundit_authorize(@saved_user_exam) if @saved_user_exam
    end

    def set_saved_user_exams
      pundit_authorize(SavedUserExam)
      @saved_user_exams = pundit_scope(SavedUserExam.preload({ user_exam: [:created_by, :user_exam_questions, { subject: :curriculum }] }))
      @saved_user_exams = attribute_sortable(@saved_user_exams)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::SavedUserExamPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::SavedUserExamPolicy)
    end

    def saved_user_exam_params
      params.require(:saved_user_exam).permit(:user_exam_id)
    end
end
