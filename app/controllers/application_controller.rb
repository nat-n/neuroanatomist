class String
  def titleize!
    exceptions = ["of", "in", "and", "the", "with", "a", "an", "or", "to", "s", "may"]
    first = true
    replace split(/(\W)/).map { |word|
      if first or not exceptions.include? word.downcase
        first = false
        word.capitalize
      else
        word.downcase
      end
    }.join
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery

  def record_not_found name
    raise ActiveRecord::RecordNotFound.new("Could not find record for: #{name}")
  end
      
  private
  def authorize_admin!
    authenticate_user!
    unless current_user and current_user.admin?
      flash[:alert] = "You must be an admin to do that."
      redirect_to root_path
    end
  end
end
