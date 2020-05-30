class UsersController < ApplicationController
  # 共通している部分@user = User.find(params[:id])をまとめた。追加したedit_basic_infoとupdate_basic_infoをログインユーザーかつ管理権限者のみが実行できるようフィルタリング設定。
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  # [:index, :show, :edit, :update, :destroy]にいく際は、すでにログインしているユーザーのみ
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :edit_overtime_application_information, :update_overtime_application_information]
  # 現在ログインしているユーザーのみ[:edit, :update]できる。
  before_action :correct_user, only: [:edit, :update]
  
  before_action :admin_or_correct_user, only: :show
  
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info, :edit_overtime_application_information, :update_overtime_application_information]
  
  before_action :set_one_month, only: :show
  

  
  def new # ユーザー新規作成ページへ
    @user = User.new # ユーザーオブジェクトを生成し、インスタンス変数に代入。
  end
  
  def index
    # @users = User.allから下記に置き換え
    @users = User.paginate(page: params[:page]).search(params[:search]) # 名前検索フォームに必須。
  end
  
  def show # ユーザーの勤怠ページ
    @user = User.find(params[:id])
    @worked_sum = @attendances.where.not(started_at: nil).count
    # 申請数(上長を選んで、且つ、申請中のユーザー)
    if @user.superior_flag == true
      @number_of_applications = Attendance.where(instructor_confirmation: @user.id, application: "残業申請中").count
    end
  end
  
  def create # ユーザー新規作成ページから登録（保存）まで
    @user = User.new(user_params)
    if @user.save
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
      # 保存に成功した後、リダイレクトしてユーザー情報ページへ遷移
      # 遷移したページで保存が成功したことを知らせるフラッシュメッセージを表示
    else
      render :new
    end
  end
  
  def edit # 編集
    # @user = User.find(params[:id])
  end
  
  def update # 更新
    # @user = User.find(params[:id])
    # .update_attributes(user_params)　⇨　(user_params)を更新し、保存する。
    if @user.update_attributes(user_params)
      # 更新に成功した場合の処理を記述します。
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
    @users = User.all
  end

  def update_basic_info # 更新
    if @user.update_attributes(basic_info_params)
      # 更新成功時の処理
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      # 更新失敗時の処理
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
   
  # 残業申請のお知らせモーダル
  def edit_overtime_application_information
    @user = User.find(params[:user_id])
    # 1.User.joins(:attendances)　⇨　UserとAttendanceモデルをひっつける。
    # 2.where(attendances: { application: "残業申請中" })　⇨　Attendanceモデルの「残業申請中」の項目の入ったレコードを選んでる。
    # 3.group("users.id")　⇨　例/userのidが同じレコードをグループでまとめる。
    # @users = User.joins(:attendances).group("users.id").where(attendances: { application: "残業申請中" })
    # 指示者確認がtrueなので、「申請者のみ」に絞れる。
    # .order(user_id: "ASC", worked_on: "ASC")　⇨　userごと、日付ごとに出るように並び替えている。
    # @attendanceの箱の中に「user_id」ごとに箱を作っている。その箱に残業申請中のユーザーのattendanceの情報を入れてやる。
    @attendances = Attendance.where(application: "残業申請中").order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
    @superior = User.where(superior_flag: true)
  end
  # 残業申請のお知らせ(承認)
  def update_overtime_application_information
    # 現在ログインしているユーザーのIDを取得。
    @user = User.find(params[:user_id])
    # 上長のみができるようにvueファイルをif文作る。
    ActiveRecord::Base.transaction do # トランザクションを開始。
      # データベースの操作を保障したい処理を以下に記述。
      # Attendanceモデルオブジェクトのidと、各カラムの値が入った更新するための情報であるitemを指す。
      # 下記のコードでストロングパラメーターのカラムを取り出し、ここではいくつも残業申請者のレコードを一つ一つ更新するため、eachで回す。
      overtime_application_information_params.each do |id, item|
        attendance = Attendance.find(id)
        # !をつけている場合はfalseでは無く例外処理を返す。
        attendance.update_attributes!(item) # ここにトランザクションを適用。
      end
    end
    # 全ての繰り返し処理が問題なく完了した時は、下記の部分の処理が適用されます。
    
    flash[:success] = "残業申請を更新しました。"
    redirect_to user_url(@user)
  # トランザクションによる例外処理の分岐を以下に記述。
  rescue ActiveRecord::RecordInvalid # 以下に例外が発生した時は、以下２行の処理が実行される。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to user_edit_overtime_application_information_url(@user)
  end

  
  private
    # ストロングパラメーター　⇨　permit内のカラムをそれぞれ許可し、それ以外は許可しないよう設定。
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:designated_work_start_time, :designated_work_end_time, :basic_time)
    end
    
    # 残業申請情報
    def overtime_application_information_params
      # fields_for "attendances[]", day do |at|と言うコードを書いたときは、ストロングパラメーターはこのように書く。
      params.require(:user).permit(attendances: [:change, :application, :tomorrow])[:attendances]
    end
    
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
end
