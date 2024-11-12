class AddOrganizationIdToModels < ActiveRecord::Migration[7.0]
  def change
    # Add org id to models
    # ordered following object dependency
    # omitted models are retained with comments for documentation purposes
    add_reference :curriculums, :organization, null: true, type: :uuid
    add_reference :subjects, :organization, null: true, type: :uuid
    add_reference :topics, :organization, null: true, type: :uuid
    ## add_reference :question_topics #m2m
    add_reference :papers, :organization, null: true, type: :uuid
    add_reference :exams, :organization, null: true, type: :uuid
    add_reference :questions, :organization, null: true, type: :uuid
    # add_reference :answers #child model
    # add_reference :question_images #no individual controller

    add_reference :submissions, :organization, null: true, type: :uuid
    add_reference :submission_answers, :organization, null: true, type: :uuid

    add_reference :guess_word_pools, :organization, null: true, type: :uuid
    # add_reference :guess_word_questions #no individual controller
    add_reference :guess_words, :organization, null: true, type: :uuid
    add_reference :guess_word_submissions, :organization, null: true, type: :uuid
    # add_reference :guess_word_submission_guesses #no individual controller
    add_reference :guess_word_dictionaries, :organization, null: true, type: :uuid

    add_reference :activities, :organization, null: true, type: :uuid
    ## add_reference :activity_papers #m2m
    ## add_reference :activity_questions #m2m
    ## add_reference :activity_topics #m2m
    
    add_reference :challenges, :organization, null: true, type: :uuid
    ## add_reference :challenge_questions #m2m

    # uncertain user data
    add_reference :user_collections, :organization, null: true, type: :uuid
    ## add_reference :user_collection_questions #m2m

    add_reference :saved_user_exams, :organization, null: true, type: :uuid
    add_reference :user_exams, :organization, null: true, type: :uuid
    ## add_reference :user_exam_questions #m2m

    # add_reference :study_goals #child model
  end
end
