class ChatController < ApplicationController
  before_filter :require_user, :only => :show
  def show
    @api_key = @current_user.single_access_token
    render :show
  end
end
