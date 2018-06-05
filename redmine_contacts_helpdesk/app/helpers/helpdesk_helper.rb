module HelpdeskHelper
  def helpdesk_ticket_source_icon(helpdesk_ticket)
    case helpdesk_ticket.source
    when HelpdeskTicket::HELPDESK_EMAIL_SOURCE
      "icon-email"
    when HelpdeskTicket::HELPDESK_PHONE_SOURCE
      "icon-call"
    when HelpdeskTicket::HELPDESK_WEB_SOURCE
      "icon-web"
    when HelpdeskTicket::HELPDESK_TWITTER_SOURCE
      "icon-twitter"
    else
      "icon-helpdesk"
    end
  end

  def helpdesk_tickets_source_for_select
    [[l(:label_helpdesk_tickets_email), HelpdeskTicket::HELPDESK_EMAIL_SOURCE.to_s],
     [l(:label_helpdesk_tickets_phone), HelpdeskTicket::HELPDESK_PHONE_SOURCE.to_s],
     [l(:label_helpdesk_tickets_web), HelpdeskTicket::HELPDESK_WEB_SOURCE.to_s],
     [l(:label_helpdesk_tickets_conversation), HelpdeskTicket::HELPDESK_CONVERSATION_SOURCE.to_s]
    ]
  end

  def helpdesk_send_as_for_select
    [[l(:label_helpdesk_not_send), ''],
     [l(:label_helpdesk_send_as_notification), HelpdeskTicket::SEND_AS_NOTIFICATION.to_s],
     [l(:label_helpdesk_send_as_message), HelpdeskTicket::SEND_AS_MESSAGE.to_s]
    ]
  end

  def show_customer_vote(vote, comment)
    case vote
    when 2
      generate_vote_link(vote, 'icon-awesome', comment)
    when 1
      generate_vote_link(vote, 'icon-justok', comment)
    when 0
      generate_vote_link(vote, 'icon-notgood', comment)
    end
  end

  def generate_vote_link(vote, vote_class, title)
    "<div class='icon #{ vote_class }' title='#{ title }'>#{ HelpdeskTicket.vote_message(vote) }</div>".html_safe
  end

  def render_helpdesk_chart(report_name, issues_scope)
    render :partial => 'helpdesk_reports/chart', :locals => { :report => report_name, :issues_scope => issues_scope }
  end

  def helpdesk_time_label(seconds)
    hours, minutes = seconds.divmod(60).first.divmod(60)
    "#{hours}<span>#{l(:label_helpdesk_hour)}</span> #{minutes}<span>#{l(:label_helpdesk_minute)}</span>".html_safe
  end

  def slim_helpdesk_time_label(seconds)
    hours, minutes = seconds.divmod(60).first.divmod(60)
    "#{hours}#{l(:label_helpdesk_hour)} #{minutes}#{l(:label_helpdesk_minute)}".html_safe
  end

  def progress_in_percents(value)
    return '0%'.html_safe if value.zero?
    "<span class='caret #{value > 0 ? 'pos' : 'neg'}'></span>#{value}%".html_safe
  end

  def mirror_progress_in_percents(value)
    return '0%'.html_safe if value.zero?
    "<span class='caret #{value < 0 ? 'mirror_pos' : 'mirror_neg'}'></span>#{value}%".html_safe
  end

  def process_deviation(before, now, time = true)
    ["#{l(:label_helpdesk_report_previous)}: #{time ? slim_helpdesk_time_label(before) : before}",
     "#{l(:label_helpdesk_report_deviation)}: #{time ? slim_helpdesk_time_label(calculate_deviation(before, now)) : calculate_deviation(before, now)}"].join("\n").html_safe
  end

  def calculate_deviation(before, now)
    before > now ? before - now : now - before
  end
end
