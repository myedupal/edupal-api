class AddIsCorrectToAnswers < ActiveRecord::Migration[7.0]
  class Answer < ApplicationRecord; end

  def up
    add_column :answers, :is_correct, :boolean
    add_column :answers, :description, :string
    Answer.update_all(is_correct: true)
  end

  def down
    Answer.where(is_correct: false).delete_all
    remove_column :answers, :is_correct, :boolean
    remove_column :answers, :description, :string
  end
end
