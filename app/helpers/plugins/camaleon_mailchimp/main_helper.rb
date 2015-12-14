module Plugins::CamaleonMailchimp::MainHelper
  def self.included(klass)
    # klass.helper_method [:my_helper_method] rescue "" # here your methods accessible from views
  end

  # here all actions on going to active
  # you can run sql commands like this:
  # results = ActiveRecord::Base.connection.execute(query);
  # plugin: plugin model
  def camaleon_mailchimp_on_active(plugin)
    generate_custom_field_newsletter

    current_site.set_meta('mailchimp_config', {api_key: 'XXX', list_id: 'XXX'})
  end

  # here all actions on going to inactive
  # plugin: plugin model
  def camaleon_mailchimp_on_inactive(plugin)
  end

  # here all actions to upgrade for a new version
  # plugin: plugin model
  def camaleon_mailchimp_on_upgrade(plugin)
  end

  def mailchimp_user_register_form(plugin)
    plugin[:html] << render('plugins/camaleon_mailchimp/register_form', f: plugin[:f])
  end

  def mailchimp_user_update_more_actions(plugin)
    plugin[:html] << render('plugins/camaleon_mailchimp/update_user_more_action', f: plugin[:f])
  end

  def camaleon_mailchimp_plugin_options(arg)
    arg[:links] << link_to(t('plugin.mailchimp.settings.link_name'), admin_plugins_camaleon_mailchimp_settings_path)
  end

  def mailchimp_user_after_register(plugin)
    if params[:user][:newsletter_enabled] == '1'
      user = plugin[:user]
      user.mailchimp_subscribe!
    end
  end

  def subscribe_hook(hook_data)
    subscription_date = hook_data[:fired_at]
    extra_data = hook_data[:data]
    extra_data[:list_id]
    extra_data[:email]
    if extra_data[:list_id] == the_mailchimp_list_id
      user = CamaleonCms::User.find_by_email(extra_data[:email])
      user.update_mailchimp_values(1, subscription_date, '')
    end
  end

  def unsubscribe_hook(hook_data)
    extra_data = hook_data[:data]
    user = CamaleonCms::User.find_by_email(extra_data[:email])
    user.mailchimp_unsubscribe!(extra_data[:list_id]) unless user.nil?
  end

  # Equals that unsubscribe hook
  def user_cleaned_hook(hook_data)
    unsubscribe_hook(hook_data)
  end

  def the_mailchimp_list_id
    plugin_config = current_site.get_meta('mailchimp_config')
    plugin_config[:list_id]
  end

  private

  def generate_custom_field_newsletter
    group = CamaleonCms::User.first.get_user_field_groups(current_site).where({slug: 'plugin_mailchimp_user_data'})
    unless group.present?
      new_group = group.create({name: 'Mailchimp user data', slug: 'plugin_mailchimp_user_data', description: 'Mailchimp newsletter user subscription data'})
      new_group.add_field({:name => "t('plugin.mailchimp.user.newsletter_subscribed')", :slug => 'mailchimp_newsletter_subscribed'}, {field_key: 'checkbox', default_value: false})
      new_group.add_field({:name => "t('plugin.mailchimp.user.newsletter_enabled_at')", :slug => 'mailchimp_newsletter_enabled_at'}, {field_key: 'date'})
      new_group.add_field({:name => "t('plugin.mailchimp.user.member_id')", :slug => 'mailchimp_member_id'}, {field_key: 'text_box'})
    end
  end
end
