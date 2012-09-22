class UserController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user, :only => [:index, :update]
  before_filter :student_permissions, :only => [:update]
  
  def index
    if request.method == "GET"
      user_page
    elsif request.method == "POST" and params["_method"] = "put"
      update
    elsif request.method == "POST"
      submit_usage_data
    end
  end
  
  def user_page
    render :action => "user_page"
  end
  
  def submit_log_data
    user = (User.find(params[:logs][:user]) rescue current_user) or current_user
    # update log count of this user to get the id of this log dump
    log_id = "#{user.id}-#{user.next_data_count}"
    log_id += "###{params[:sid]}" if params[:sid]
    save_quiz_stats user, params[:quiz_stats] if user and params[:quiz_stats]
    params[:logs][:user] = user.email
    params[:logs][:ip] = request.ip
    DataMailer.data(params[:logs],log_id).deliver
    render :text => "logs saved"
  end
  
  def save_quiz_stats user, stats
    stats = JSON.load(stats) if stats.is_a? String
    quiz_stats = (JSON.load(user.quiz_stats) or {})
    stats.each do |region_name, s|
      quiz_stats[region_name] ||= {}
      stats[region_name].each do |mode, counts|
        quiz_stats[region_name][mode] = [0,0] unless quiz_stats[region_name][mode]
        quiz_stats[region_name][mode][0] += stats[region_name][mode][0].to_i
        quiz_stats[region_name][mode][1] += stats[region_name][mode][1].to_i
      end
    end
    user.quiz_stats = JSON.dump(quiz_stats)
    user.save
  end
  
  def update
    return submit_log_data if params[:logs]
    params[:user][:alias].strip.squeeze(' ')
    params[:user][:alias] = nil if params[:user][:alias].empty?
    @user.alias = params[:user][:alias] if params[:user][:alias]
    if @user.save
      render action: "user_page", notice: 'Account updated.'
    else
      render action: "user_page"
    end
  end
  
  private
    def find_user
      @user = current_user
    end
    def student_permissions
      return true unless @user.group == "student"
      params[:user].delete :email
      params[:user].delete :group
    end
end
