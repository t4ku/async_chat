class ChatController < ApplicationController
  before_filter :require_user, :only => :show
  def show
    render :show
  end
end
