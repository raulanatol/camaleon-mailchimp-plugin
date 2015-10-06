require 'gibbon'
# Extending User Model to add newsletter attributes
User.class_eval do

  def the_newsletter_subscribed?
    self.get_field_value('mailchimp_newsletter_subscribed').to_s.to_bool
  end

  def the_newsletter_enabled_at?
    self.get_field_value('mailchimp_newsletter_enabled_at').to_date
  end

  def mailchimp_subscribe_newsletter!
    begin
      if mailchimp_api_subscribe
        mailchimp_update_subscription_values!
      end
    rescue Exception => exception
      Rails.logger.warn "[Mailchimp plugin] Error trying to subscribe an new user: #{id} - Error: #{exception}"
    end
  end

  def mailchimp_unsubscribe_newsletter!
    begin
      plugin_config = current_site.get_meta('mailchimp_config')
      mailchimp_api_key = plugin_config[:api_key]
      list_id = plugin_config[:api_key]
      gibbon = Gibbon::Request.new(api_key: mailchimp_api_key)
      gibbon.lists(list_id).members.create(body: body_value)
    end
  end

  private

  def mailchimp_api_subscribe
    body_value = {
      email_address: email,
      status: 'subscribed',
      merge_fields: {
        FNAME: meta[:first_name],
        LNAME: meta[:last_name]
      }
    }
    plugin_config = current_site.get_meta('mailchimp_config')
    mailchimp_api_key = plugin_config[:api_key]
    list_id = plugin_config[:list_id]
    gibbon = Gibbon::Request.new(api_key: mailchimp_api_key)
    gibbon.lists(list_id).members.create(body: body_value)
  end

  def mailchimp_update_subscription_values!
    field_groups = self.get_user_field_groups(current_site).where({:slug => 'plugin_mailchimp_user_data'}).first
    field_newsletter_subscribed = field_groups.get_field('mailchimp_newsletter_subscribed')
    field_newsletter_enabled_at = field_groups.get_field('mailchimp_newsletter_enabled_at')

    values_to_save = {
      :mailchimp_newsletter_subscribed => {id: field_newsletter_subscribed.id, values: [1]},
      :mailchimp_newsletter_enabled_at => {id: field_newsletter_enabled_at.id, values: [Time.zone.now]}
    }

    set_field_values(values_to_save)
  end

end

