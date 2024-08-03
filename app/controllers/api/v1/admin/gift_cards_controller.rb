class Api::V1::Admin::GiftCardsController < Api::V1::Admin::ApplicationController
  before_action :set_gift_card, only: [:show, :update, :destroy]
  before_action :set_gift_cards, only: [:index]

  def index
    @pagy, @gift_cards = pagy(@gift_cards)
    render json: @gift_cards, include: %w[plan created_by]
  end

  def show
    render json: @gift_card, include: %w[plan created_by]
  end

  def create
    @gift_card = GiftCard.new(gift_card_params)
    @gift_card.created_by = current_admin
    pundit_authorize(@gift_card)

    if @gift_card.save
      render json: @gift_card, include: %w[plan created_by]
    else
      render json: ErrorResponse.new(@gift_card), status: :unprocessable_entity
    end
  end

  def update
    if @gift_card.update(gift_card_params)
      render json: @gift_card, include: %w[plan created_by]
    else
      render json: ErrorResponse.new(@gift_card), status: :unprocessable_entity
    end
  end

  def destroy
    if @gift_card.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@gift_card), status: :unprocessable_entity
    end
  end

  private

    def set_gift_card
      @gift_card = pundit_scope(GiftCard).find(params[:id])
      pundit_authorize(@gift_card) if @gift_card
    end

    def set_gift_cards
      pundit_authorize(GiftCard)
      @gift_cards = pundit_scope(GiftCard.preload(:plan, :created_by))
      @gift_cards = @gift_cards.where(plan_id: params[:plan_id]) if params[:plan_id].present?
      @gift_cards = keyword_queryable(@gift_cards)
      @gift_cards = attribute_sortable(@gift_cards)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::GiftCardPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::GiftCardPolicy)
    end

    def gift_card_params
      params.require(:gift_card).permit(:name, :remark, :plan_id, :redemption_limit, :expires_at, :duration)
    end
end
