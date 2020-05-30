Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get '/login', to: 'sessions#new' # ログインページ
  post   '/login', to: 'sessions#create' # セッション作成（ログイン）
  delete '/logout', to: 'sessions#destroy' # セッション削除（ログアウト）
  # createやdestroyには対応するビューが必要ないため、
  # ここでは指定せずにSessionsコントローラに直接追加
  
  resources :users do
    # memberブロックをリソースブロックに追加する
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month' # 勤怠編集ページのルーティング
      patch 'attendances/update_one_month' # 勤怠編集ページをまとめて更新する為のルーティング。
    end
    # onlyオプションで指定することで、updateアクション以外のルーティングを制限。
    # 勤怠データは、アップデートのみ。
    resources :attendances, only: :update do
      member do
        get 'edit_overtime_info' # 残業申請ボタン〜残業申請一覧ページ（モーダル）
        patch 'update_overtime_info' # 残業申請一覧ページ（モーダル）内の変更を送信〜更新
      end
    end
    # 勤怠変更申請モーダルは特定のattendancesモデルの情報を求める必要性はないのでattendancesモデルから外してusersモデルのみの中に入れる。
    get 'edit_overtime_application_information' # 残業申請のお知らせモーダル
    patch 'update_overtime_application_information' # 残業申請のお知らせモーダル
  end
end