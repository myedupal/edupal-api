class Api::V1::User::UserExamsController < Api::V1::User::ApplicationController
  before_action :set_user_exam, only: [:show, :update, :destroy]
  before_action :set_user_exams, only: [:index]

  def index
    @pagy, @user_exams = pagy(@user_exams)
    render json: @user_exams, include: ['created_by', 'subject.curriculum', 'user_exam_questions']
  end

  def show
    render json: @user_exam, include: ['created_by',
                                       'subject.curriculum',
                                       'user_exam_questions.question.exam.paper',
                                       'user_exam_questions.question.question_images',
                                       'user_exam_questions.question.topics',
                                       'user_exam_questions.question.answers']
  end

  def create
    @user_exam = UserExam.new(user_exam_params)
    @user_exam.created_by = current_user
    pundit_authorize(@user_exam)

    if @user_exam.save
      render json: @user_exam, include: ['created_by',
                                         'subject.curriculum',
                                         'user_exam_questions.question.exam.paper',
                                         'user_exam_questions.question.question_images',
                                         'user_exam_questions.question.topics',
                                         'user_exam_questions.question.answers']
    else
      render json: ErrorResponse.new(@user_exam), status: :unprocessable_entity
    end
  end

  def update
    if @user_exam.update(user_exam_params)
      render json: @user_exam, include: ['created_by',
                                         'subject.curriculum',
                                         'user_exam_questions.question.exam.paper',
                                         'user_exam_questions.question.question_images',
                                         'user_exam_questions.question.topics',
                                         'user_exam_questions.question.answers']
    else
      render json: ErrorResponse.new(@user_exam), status: :unprocessable_entity
    end
  end

  def destroy
    if @user_exam.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@user_exam), status: :unprocessable_entity
    end
  end

  private

    def set_user_exam
      scope = UserExam.preload(:created_by, { user_exam_questions: { question: [{ exam: :paper }, :question_images, :topics, :answers] } }, { subject: :curriculum })
      @user_exam = scope.find_by(id: params[:id]) || scope.find_by!(nanoid: params[:id])
      pundit_authorize(@user_exam) if @user_exam
    end

    def set_user_exams
      pundit_authorize(UserExam)
      @user_exams = pundit_scope(UserExam.preload(:created_by, :user_exam_questions, { subject: :curriculum }))
      @user_exams = attribute_sortable(@user_exams)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::UserExamPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::UserExamPolicy)
    end

    def user_exam_params
      params.require(:user_exam).permit(
        :title, :subject_id, :is_public,
        user_exam_questions_attributes: [:id, :question_id, :_destroy]
      )
    end
end
