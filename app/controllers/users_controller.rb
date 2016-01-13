class UsersController < ApplicationController
  before_action :require_login

  def index
  	if current_user
  		redirect_to users_path
  	end
  end

  def edit
  end

  def profile
  end

  def matches
  end
end
