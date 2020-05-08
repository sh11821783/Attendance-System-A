class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.string :note
      t.datetime :scheduled_end_time # 終了予定時間
      t.string :business_processing_content # 業務処理内容
      t.integer :instructor_confirmation, null: false, default: 0 # 指示者確認
      t.boolean :tomorrow # 翌日
      t.string :superior # 上長
      t.datetime :coming_to_work # 出社
      t.datetime :leaving_the_company # 退社
      t.boolean :change, default: false # 変更
      t.references :user, foreign_key: true
      t.string :application # 申請

      t.timestamps
    end
  end
end
