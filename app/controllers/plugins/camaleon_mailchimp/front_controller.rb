class Plugins::CamaleonMailchimp::FrontController < CamaleonCms::Apps::PluginsFrontController
  include Plugins::CamaleonMailchimp::MainHelper

  skip_before_action :verify_authenticity_token

  def hook
    case params[:type]
      when 'subscribe' then
        subscribe_hook(params)
      when 'unsubscribe' then
        unsubscribe_hook(params)
      when 'cleaned' then
        user_cleaned_hook(param)
    end
    render :nothing => true
  end
end
