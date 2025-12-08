class HomeController < ApplicationController
  before_action :authenticate_usuario 
  layout "public"   # usa layouts/public.html.erb
  def index
  end
end
