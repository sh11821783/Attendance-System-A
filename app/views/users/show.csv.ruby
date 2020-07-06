require 'csv'

CSV.generate do |csv|
  column_names = %w(worked_on started_at finished_at note business_processing_content)
  csv << column_names
  @attendances.each do |attendance|
    column_values = [
      attendance.worked_on,
      if attendance.started_at.present?
        l(attendance.started_at, format: :time)
      else
        ""
      end,
      if attendance.finished_at.present?
        l(attendance.finished_at, format: :time)
      else
        ""
      end,
      attendance.note,
      attendance.business_processing_content
    ]
    csv << column_values
  end
end