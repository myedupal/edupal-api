class Api::V1::Admin::GuessWordDictionariesController < Api::V1::Admin::ApplicationController
  before_action :set_guess_word_dictionary, only: [:show, :update, :destroy]
  before_action :set_guess_word_dictionaries, only: [:index]

  def index
    @pagy, @set_guess_word_dictionaries = pagy(@set_guess_word_dictionaries)
    render json: @set_guess_word_dictionaries
  end

  def show
    render json: @set_guess_word_dictionary
  end

  def create
    @set_guess_word_dictionary = pundit_scope(GuessWordDictionary).new(guess_word_params)
    pundit_authorize(@set_guess_word_dictionary)

    if @set_guess_word_dictionary.save
      render json: @set_guess_word_dictionary
    else
      render json: ErrorResponse.new(@set_guess_word_dictionary), status: :unprocessable_entity
    end
  end

  def update
    if @set_guess_word_dictionary.update(guess_word_params)
      render json: @set_guess_word_dictionary
    else
      render json: ErrorResponse.new(@set_guess_word_dictionary), status: :unprocessable_entity
    end
  end

  def destroy
    if @set_guess_word_dictionary.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@set_guess_word_dictionary), status: :unprocessable_entity
    end
  end

  def import
    read = 0
    imported = 0

    GuessWordDictionary.transaction do
      uploaded_file = params.permit(:file)[:file]
      filename = uploaded_file.tempfile.path

      File.foreach(filename).each_slice(5000) do |words|
        read += words.length
        # insert_all does not instantiate any models nor does it trigger Active Record callbacks or validations.
        # therefore word formatting has to be made beforehand
        entries = words
                    .map { |entry| { word: entry.strip.downcase } }
                    .select(&:present?)

        result = GuessWordDictionary.insert_all(entries, unique_by: :word, returning: :id)
        imported += result.length
      end
    end

    render json: { read: read, imported: imported }
  end

  private

    def set_guess_word_dictionary
      @set_guess_word_dictionary = pundit_scope(GuessWordDictionary).find(params[:id])
      pundit_authorize(@set_guess_word_dictionary) if @set_guess_word_dictionary
    end

    def set_guess_word_dictionaries
      pundit_authorize(GuessWord)
      @set_guess_word_dictionaries = pundit_scope(GuessWordDictionary)
      @set_guess_word_dictionaries = keyword_queryable(@set_guess_word_dictionaries)
      @set_guess_word_dictionaries = attribute_sortable(@set_guess_word_dictionaries)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::GuessWordDictionaryPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::GuessWordDictionaryPolicy)
    end

    def guess_word_params
      params.require(:guess_word_dictionary).permit(:word)
    end
end
