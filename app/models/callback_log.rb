class CallbackLog < ApplicationRecord
  after_commit :schedule_process_callback_job, on: :create

  private

    def schedule_process_callback_job
      ProcessCallbackJob.perform_async(id)
    end
end
