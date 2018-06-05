# This file is a part of Redmin CMS (redmine_cms) plugin,
# CMS plugin for redmine
#
# Copyright (C) 2011-2016 RedmineUP
# http://www.redmineup.com/
#
# redmine_cms is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_cms is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_cms.  If not, see <http://www.gnu.org/licenses/>.

class CmsSiteController < ApplicationController
  # caches_action :sitemap, :expires_in => 1.hour

  before_filter :redirect_urls, :only => [:login, :lost_password, :register]

  def sitemap
    @projects = Project.all_public.active
    @pages = CmsPage.where(:project_id => nil).visible.all
  end

  def login

    if request.get?
      if User.current.logged?
        redirect_to @on_success_url || home_url
      elsif params[:key] && user = User.find_by_api_key(params[:key])
        successful_authentication(user)
        return
      else
        redirect_back_or_default home_url
      end
    else
      authenticate_user
    end
  end

  # Lets user choose a new password
  def lost_password
    (redirect_to(home_url); return) unless Setting.lost_password?
    if params[:token]
      @token = Token.find_token("recovery", params[:token].to_s)
      if @token.nil? || @token.expired?
        redirect_to home_url
        return
      end
      @user = @token.user
      unless @user && @user.active?
        redirect_to home_url
        return
      end
      if request.post?
        @user.password, @user.password_confirmation = params[:new_password], params[:new_password_confirmation]
        if @user.save
          @token.destroy
          Mailer.password_updated(@user)
          flash[:notice] = l(:notice_account_password_updated)
          redirect_to @on_success_url || home_url
          return
        end
      end
      render :template => "account/password_recovery"
      return
    else
      if request.post?
        email = params[:mail].to_s
        user = User.find_by_mail(email)
        # user not found
        unless user
          flash.now[:error] = l(:notice_account_unknown_email)
          redirect_to @on_falure_url || :back
          return
        end
        unless user.active?
          handle_inactive_user(user, lost_password_path)
          redirect_to @on_falure_url || :back
          return
        end
        # user cannot change its password
        unless user.change_password_allowed?
          flash.now[:error] = l(:notice_can_t_change_password)
          redirect_to @on_falure_url || :back
          return
        end
        # create a new token for password recovery
        token = Token.new(:user => user, :action => "recovery")
        if token.save
          # Don't use the param to send the email
          recipent = user.mails.detect {|e| email.casecmp(e) == 0} || user.mail
          Mailer.lost_password(token, recipent).deliver
          flash[:notice] = l(:notice_account_lost_email_sent)
          redirect_to @on_success_url || home_url
          return
        end
      end
    end
  end

  def logout

  end

  def register

  end

  def expire_cache
    Rails.cache.clear
    redirect_back_or_default home_url
  end

  private

  def invalid_credentials
    logger.warn "[CMS] Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
    flash[:error] = l(:notice_account_invalid_credentials)
    redirect_to @on_falure_url || :back
  end

  def authenticate_user
    password_authentication
  end

  def password_authentication
    login = User.find_by_mail(params[:email]).try(:login)

    user = User.try_to_login(login, params[:password], false)

    if user.nil?
      invalid_credentials
    else
      # Valid user
      if user.active?
        successful_authentication(user)
        update_sudo_timestamp! # activate Sudo Mode
      else
        handle_inactive_user(user, @on_falure_url)
      end
    end
  rescue
    invalid_credentials
  end

  def successful_authentication(user)
    logger.info "[CMS] Successful authentication for '#{user.login}' from #{request.remote_ip} at #{Time.now.utc}"
    # Valid user
    self.logged_user = user
    redirect_back_or_default @on_success_url || home_url
  end

  def handle_inactive_user(user, redirect_path=signin_path)
    if user.registered?
      account_pending(user, redirect_path)
    else
      account_locked(user, redirect_path)
    end
  end

  def account_pending(user, redirect_path=signin_path)
    if Setting.self_registration == '1'
      flash[:error] = l(:notice_account_not_activated_yet, :url => activation_email_path)
      session[:registered_user_id] = user.id
    else
      flash[:error] = l(:notice_account_pending)
    end
    redirect_to redirect_path
  end

  def account_locked(user, redirect_path=signin_path)
    flash[:error] = l(:notice_account_locked)
    redirect_to redirect_path
  end

  def redirect_urls
    @on_success_url = params[:on_success_url]
    @on_falure_url = params[:on_falure_url]

  end

end
