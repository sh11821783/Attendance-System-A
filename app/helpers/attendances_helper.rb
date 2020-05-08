module AttendancesHelper
  
  def attendance_state(attendance)
    # もし、現在の日付 == 日付の時、
    if Date.current == attendance.worked_on
      # 出社時間がない時は、出社。
      return '出社' if attendance.started_at.nil?
      # 出社時間があり、且つ、退社時間がない時は、退社。
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    return false
  end
  # 就労時間。出勤時間と退勤時間を受け取り、在社時間を計算
  def working_times(start, finish) # ()内の引数はなんでもいい。
    # f = 小数点以下２桁
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  # 終了予定時間と指定勤務時間を引いて時間外時間を算出。
  def overtime_info(finished_end_time, finish) # ()内の引数はなんでもいい。
    format("%.2f", (((finished_end_time - finish) / 60) / 60.0))
  end
  
  def format_hour(time)
    format('%.2d',((time.hour)))
  end
  
  def format_min(time)
    # d = 整数 2 = 2けた
    format('%.2d',(((time.min) / 15) * 15))
  end
end
