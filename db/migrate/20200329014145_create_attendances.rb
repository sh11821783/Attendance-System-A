class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.string :note
      # 終了予定時間
      t.time :scheduled_end_time
      # 業務処理内容
      t.string :business_processing_content
      # 指示者確認
      t.string :instructor_confirmation
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
