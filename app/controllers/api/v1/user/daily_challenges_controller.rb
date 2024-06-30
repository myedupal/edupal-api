class Api::V1::User::DailyChallengesController < Api::V1::User::ApplicationController
  before_action :set_challenge, only: [:show]
  before_action :set_challenges, only: [:index]

  def index
    @pagy, @challenges = pagy(@challenges)
    render json: @challenges, each_serializer: Api::V1::User::DailyChallengeSerializer, include: ['subject.curriculum']
  end

  def show
    render json: @challenge,
           serializer: Api::V1::User::DailyChallengeSerializer,
           include: ['*',
                     'subject.curriculum',
                     'questions.question_images',
                     'questions.topics',
                     'challenge_questions']
  end

  private

    def set_challenge
      @challenge = pundit_scope(
        Challenge.with_user_submission_count(current_user.id)
                 .with_user_success_submission_count(current_user.id)
                 .with_challenge_questions_count
      ).preload({ subject: :curriculum },
                { questions: [:question_images, :topics] },
                :challenge_questions)
                   .find(params[:id])
      pundit_authorize(@challenge) if @challenge
    end

    def set_challenges
      pundit_authorize(Challenge)
      @challenges = pundit_scope(
        Challenge.with_user_submission_count(current_user.id)
                 .with_user_success_submission_count(current_user.id)
                 .with_challenge_questions_count
      ).preload({ subject: :curriculum })
      @challenges = @challenges.joins(:subject).where(subject: { curriculum_id: current_user.selected_curriculum_id })
      @challenges = challenge_time_filterable(@challenges)
      @challenges = attribute_sortable(@challenges)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::DailyChallengePolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::DailyChallengePolicy)
    end

    def challenge_time_filterable(records)
      if params[:from_start_at].present? && params[:to_start_at].present?
        start_time = begin
          Time.zone.parse(params[:from_start_at])
        rescue StandardError
          nil
        end
        end_time = begin
          Time.zone.parse(params[:to_start_at])
        rescue StandardError
          nil
        end
      end
      start_time ||= Time.current.beginning_of_day
      end_time ||= Time.current.end_of_day
      records.where(start_at: start_time..end_time)
    end
end
