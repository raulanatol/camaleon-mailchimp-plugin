require 'gibbon'
# Extending User Model to add newsletter attributes
User.class_eval do

  def the_newsletter_subscribed?
    self.get_field_value('mailchimp_newsletter_subscribed').to_s.to_bool
  end

  def the_newsletter_enabled_at?
    self.get_field_value('mailchimp_newsletter_enabled_at').to_date
  end

  def the_mailchimp_member_id

    self.get_field_value('mailchimp_member_id').to_s
  end

  def mailchimp_subscribe!
    error = nil
    begin
      new_member = mailchimp_api_subscribe
      mailchimp_update_subscription_values!(new_member) unless new_member.nil?
      error
    rescue Gibbon::MailChimpError => mailchimp_exception
      if mailchimp_exception.title.downcase.include? 'exists'
        Rails.logger.error "[Mailchimp plugin error] EXISTS: #{mailchimp_exception} title: #{mailchimp_exception.title} detail: #{mailchimp_exception.detail} body: #{mailchimp_exception.body}"
        error = {
          :message => I18n.t('plugin.mailchimp.error.exists_subscribe.message'),
          :title => I18n.t('plugin.mailchimp.error.exists_subscribe.title')
        }
      else
        error = {
          :message => I18n.t('plugin.mailchimp.error.generic.message'),
          :title => I18n.t('plugin.mailchimp.error.generic.title')
        }
      end
    rescue Exception => exception
      Rails.logger.warn "[Mailchimp plugin] Error trying to subscribe an new user: #{id} - Error: #{exception}"
      error = {
        :message => I18n.t('plugin.mailchimp.error.generic.message'),
        :title => I18n.t('plugin.mailchimp.error.generic.title')
      }
    ensure
      error
    end
  end

  def mailchimp_unsubscribe!(list_id = nil)
    begin
      plugin_config = current_site.get_meta('mailchimp_config')
      mailchimp_api_key = plugin_config[:api_key]
      mailchimp_list_id = list_id.nil? ? plugin_config[:list_id] : list_id
      member_id = the_mailchimp_member_id
      Rails.logger.info "[Mailchimp plugin] Start unsubscribe list: #{mailchimp_list_id} api: #{mailchimp_api_key} member_id: #{member_id}"
      gibbon = Gibbon::API.new(mailchimp_api_key)
      gibbon.lists.unsubscribe(:id => mailchimp_list_id, :email => {:email => email}, :send_notify => true)
      mailchimp_update_unsubscription_values!
    rescue Gibbon::MailChimpError => exception
      Rails.logger.error "[Mailchimp plugin error] exception: #{exception} title: #{exception.title} detail: #{exception.detail} body: #{exception.body}"
      false
    rescue Exception => exception
      Rails.logger.warn "[Mailchimp plugin] Error trying to unsubscribe an new user: #{id} - Error: #{exception}"
      false
    end
  end

  def update_mailchimp_values(subscribed, enabled_at, member_id)
    field_groups = self.get_user_field_groups(current_site).where({:slug => 'plugin_mailchimp_user_data'}).first
    field_newsletter_subscribed = field_groups.get_field('mailchimp_newsletter_subscribed')
    field_newsletter_enabled_at = field_groups.get_field('mailchimp_newsletter_enabled_at')
    field_member_id = field_groups.get_field('mailchimp_member_id')

    values_to_save = {
      :mailchimp_newsletter_subscribed => {id: field_newsletter_subscribed.id, values: [subscribed]},
      :mailchimp_newsletter_enabled_at => {id: field_newsletter_enabled_at.id, values: [enabled_at]},
      :mailchimp_member_id => {id: field_member_id.id, values: [member_id]}
    }

    set_field_values(values_to_save)
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
    gibbon = Gibbon::API.new(mailchimp_api_key)
    # gibbon.lists(list_id).members.create(body: body_value)
    gibbon.lists.subscribe({:id => list_id, :email => {:email => email}, :merge_vars => {:FNAME => meta[:first_name], :LNAME => meta[:last_name]}})
  end

  def mailchimp_update_unsubscription_values!
    update_mailchimp_values(0, '', '')
  end

  def mailchimp_update_subscription_values!(new_member)
    update_mailchimp_values(1, Time.zone.now, new_member['id'])
  end
end

