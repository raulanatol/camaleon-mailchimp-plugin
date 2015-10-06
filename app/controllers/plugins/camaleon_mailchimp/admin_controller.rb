class Plugins::CamaleonMailchimp::AdminController < Apps::PluginsAdminController
  include Plugins::CamaleonMailchimp::MainHelper

  def settings
    @mailchimp = current_site.get_meta('mailchimp_config')
  end

  def save_settings
    current_site.set_meta('mailchimp_config',
                          {
                              api_key: params[:mailchimp][:api_key],
                              list_id: params[:mailchimp][:list_id]
                          })
    flash[:notice] = "#{t('plugin.mailchimp.messages.settings_saved')}"
    redirect_to action: :settings
  end


  def subscribe
    user = current_site.users.find(params[:user_id])
    user.mailchimp_subscribe_newsletter!
    render json: {message: 'update'}
  end

  def unsubscribe
    param[:user].mailchimp_unsubscribe_newsletter!
    render json: {message: 'update'}
  end
end
