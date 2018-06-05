Redmine::WikiFormatting::Macros.macro :view_information_about_letter, :desc => '' do |obj, args|
  if obj.class.name == "Journal"
    res = link_to(t(:macros_information_about_letter, scope: [:redmine_issue_mailer]), show_from_issue_issue_email_from_clients_path(id: args[1], issue_id: obj.journalized_id))  
    if User.current.allowed_to?(:see_information_about_letter_from_issue, @project)
      letter_inf = obj.issue_email_from_client
      res += content_tag(:p, "From: #{h letter_inf.try(:from)}")
      res += content_tag(:p, "To: #{h letter_inf.try(:to)}")
    end
    res
  else
    res = link_to t(:macros_information_about_letter, scope: [:redmine_issue_mailer]), show_from_issue_issue_email_from_clients_path(id: args[1], issue_id: obj.id)
    if User.current.allowed_to?(:see_information_about_letter_from_issue, @project)
      letter_inf = obj.issue_email_from_clients.find_by_id(args[1])
      res += content_tag(:p, "From: #{h letter_inf.try(:from)}")
      res += content_tag(:p, "To: #{h letter_inf.try(:to)}")
    end
    res
  end
end

Redmine::WikiFormatting::Macros.macro :view_information_about_sent_letter, :desc => '' do |obj, args|
  res = link_to t(:macros_view_information_about_sent_letter, journal_id: obj.id, scope: [:redmine_issue_mailer]), show_from_issue_issue_sent_on_client_emails_path(id: args[1], issue_id: obj.journalized_id)
  if User.current.allowed_to?(:see_information_about_letter_from_issue, @project)
    letter_inf = obj.issue_sent_on_client_email
    res += content_tag(:p, "From: #{h letter_inf.try(:from)}")
    res += content_tag(:p, "To: #{h letter_inf.try(:to)}")
  end
  res
end