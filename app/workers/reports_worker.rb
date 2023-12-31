# frozen_string_literal: true

class ReportsWorker
  include Sidekiq::Worker

  def perform(user_id)
    tasks = Task.accessible_to(user_id)
    html_report = ApplicationController.render(
      assigns: {
        template: "tasks/report/download",
        layout: "pdf"
      }
    )
    pdf_report = WickedPdf.new.pdf_from_string html_report
    current_user = User.find(user_id)
    if current_user.report.attached?
      current_user.report.purge_later
    end
    current_user.report.attach(
      io: StringIO.new(pdf_report), filename: "report.pdf",
      content_type: "application/pdf")
    current_user.save
  end
end
