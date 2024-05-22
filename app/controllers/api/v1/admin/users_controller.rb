class Api::V1::Admin::UsersController < Api::V1::Admin::ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :set_users, only: [:index]

  def index
    @pagy, @users = pagy(@users)
    render json: @users
  end

  def show
    render json: @user
  end

  def create
    @user = pundit_scope(User).new(user_params)
    pundit_authorize(@user)

    if @user.save
      render json: @user
    else
      render json: ErrorResponse.new(@user), status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: ErrorResponse.new(@user), status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@user), status: :unprocessable_entity
    end
  end

  private

    def set_user
      @user = pundit_scope(User).find(params[:id])
      pundit_authorize(@user) if @user
    end

    def set_users
      pundit_authorize(User)
      @users = pundit_scope(User.includes(:stripe_profile))
      @users = keyword_queryable(@users)
      @users = attribute_sortable(@users)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::UserPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::UserPolicy)
    end

    def user_params
      params.require(:user).permit(:email, :name, :active, :password, :phone_number)
    end
end
