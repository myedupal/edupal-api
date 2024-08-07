class Api::V1::User::AccountsController < Api::V1::User::ApplicationController
  after_action :daily_check_in, only: [:show]

  def show
    render json: current_user, serializer: Api::V1::User::UserWithActiveSubscriptionSerializer
  end

  def update
    if current_user.update(account_params)
      render json: current_user
    else
      render json: ErrorResponse.new(current_user), status: :unprocessable_entity
    end
  end

  def password
    if current_user.update_with_password(password_params)
      render json: current_user
    else
      render json: ErrorResponse.new(current_user), status: :unprocessable_entity
    end
  end

  def zklogin_salt
    render json: { zklogin_salt: current_user.zklogin_salt }
  end

  def update_referral
    if current_user.update_referral(params[:referral_code])
      render json: current_user
    else
      render json: ErrorResponse.new(current_user), status: :unprocessable_entity
    end
  end

  private

    def account_params
      params.require(:account).permit(:name, :phone_number, :selected_curriculum_id)
    end

    def password_params
      params.require(:account).permit(:current_password, :password, :password_confirmation)
    end

    def daily_check_in
      Rails.cache.fetch("daily_check_in:#{Date.current}:#{current_user.id}", expires_at: Time.current.end_of_day) do
        retry_count = 0
        begin
          daily_check_in = current_user.daily_check_ins.find_or_create_by!(date: Date.current)
        rescue ActiveRecord::RecordNotUnique
          retry_count += 1
          retry if retry_count < 3
        end
        current_user.point_activities.find_or_create_by(action_type: :daily_check_in, activity_id: daily_check_in.id, activity_type: daily_check_in.class.name) do |point_activity|
          point_activity.points = Setting.daily_check_in_points
        end
      end
    end
end
