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
    error = user.mailchimp_subscribe!
    if error.nil?
      result = {
        message: {
          title: t('plugin.mailchimp.success.subscribe.title'),
          close: t('plugin.mailchimp.close'),
        }
      }
    else
      result = {
        errors: {
          title: error[:title],
          msg: error[:message],
          close: t('plugin.mailchimp.close'),
        }
      }
    end
    render json: result
  end

  def unsubscribe
    user = current_site.users.find(params[:user_id])
    if user.mailchimp_unsubscribe!
      result = {
        message: {
          title: t('plugin.mailchimp.success.unsubscribe.title'),
          close: t('plugin.mailchimp.close'),
        }
      }
    else
      result = {
        errors: {
          title: t('plugin.mailchimp.error.unsubscribe.title'),
          msg: t('plugin.mailchimp.error.unsubscribe.message'),
          close: t('plugin.mailchimp.close'),
        }
      }
    end
    render json: result
  end
end
