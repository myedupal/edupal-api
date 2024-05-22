module ExamFilteringHelper
  extend ActiveSupport::Concern

  def exams_filtering
    Rails.cache.fetch("#{object.id}:exams_filtering", expires_in: 24.hours) do
      {
        all: {
          papers: object.papers.distinct(:name).pluck(:name),
          zones: object.exams.distinct(:zone).pluck(:zone),
          seasons: object.exams.distinct(:season).pluck(:season),
          years: object.exams.distinct(:year).pluck(:year),
          levels: object.exams.distinct(:level).pluck(:level)
        },
        mcq: {
          papers: object.papers.has_mcq_questions.distinct(:name).pluck(:name),
          zones: object.exams.has_mcq_questions.distinct(:zone).pluck(:zone),
          seasons: object.exams.has_mcq_questions.distinct(:season).pluck(:season),
          years: object.exams.has_mcq_questions.distinct(:year).pluck(:year),
          levels: object.exams.has_mcq_questions.distinct(:level).pluck(:level)
        }
      }
    end
  end
end
