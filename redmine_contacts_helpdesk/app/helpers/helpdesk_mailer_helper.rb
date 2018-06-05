# encoding: utf-8
# include RedCloth

module HelpdeskMailerHelper
  def textile(text)
    Redmine::WikiFormatting.to_html(Setting.text_formatting, text)
  end

  def message_sender(email)
    sender = email.reply_to.try(:first) || email.from_addrs.try(:first)
    sender.to_s.strip
  end
end
