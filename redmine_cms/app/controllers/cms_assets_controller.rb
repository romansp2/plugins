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

class CmsAssetsController < ApplicationController
  unloadable
  before_filter :authorize_edit, :except => [:download, :thumbnail]
  before_filter :find_attachment, :only => [:download, :thumbnail, :destroy, :show]
  before_filter :find_attachments, :only => [:edit, :update]

  helper :attachments
  helper :cms
  helper :sort
  include SortHelper

  def index
    sort_init 'filename', 'asc'
    sort_update 'filename' => "#{Attachment.table_name}.filename",
                'description' => "#{Attachment.table_name}.description",
                'created_on' => "#{Attachment.table_name}.created_on",
                'size' => "#{Attachment.table_name}.filesize"

    @attachments = CmsSite.instance.attachments.reorder(sort_clause)
  end

  def new
  end

  def show
    if @attachment.is_text? && @attachment.filesize <= Setting.file_max_size_displayed.to_i.kilobyte
      @content = File.new(@attachment.diskfile, "rb").read
      render :template => 'attachments/file'
    elsif @attachment.is_image?
      render :template => 'attachments/image'
    else
      render :template => 'attachments/other'
    end
  end

  def create
    container = CmsSite.instance
    attachments = params[:attachments]
    attachments.each{|a| a[1][:container_type] = CmsSite.name; a[1][:container_id] = 1} if attachments
    saved_attachments = CmsSite.instance.save_attachments(attachments, User.current)
    saved_attachments[:files].each{|a| a.update_attributes(:container_id => 1, :container_type => CmsSite.name)} if saved_attachments
    render_attachment_warning_if_needed(container)

    if saved_attachments[:files].present?
      flash[:notice] = l(:label_file_added)
      redirect_to cms_assets_path
    else
      flash.now[:error] = l(:label_attachment) + " " + l('activerecord.errors.messages.invalid')
      index
      render :action => 'index'
    end
  end

  def destroy
    @attachment.destroy

    respond_to do |format|
      format.html { redirect_to_referer_or cms_assets_path }
      format.js
    end
  end

  def download
    if (@attachment.container_type == CmsSite.name) || @attachment.visible?
      # fresh_when(:etag => @attachment.digest, :last_modified => @attachment.update_on.utc, :public => true)
      expires_in RedmineCms.cache_expires_in.minutes, :public => true, :private => false
      if stale?(:etag => @attachment.digest, :public => true)
        # images are sent inline
        send_file @attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
                                        :type => detect_content_type(@attachment),
                                        :disposition => (@attachment.image? ? 'inline' : 'attachment')
      end
    else
      deny_access
    end
  end

  def edit

  end

  def update
    if params[:attachments].is_a?(Hash)
      if Attachment.update_attachments(@attachments, params[:attachments])
        redirect_back_or_default home_path
        return
      end
    end
    render :action => 'edit'
  end


  def thumbnail
    if (@attachment.container_type == CmsSite.name || @attachment.visible?) && @attachment.thumbnailable? && tbnail = @attachment.thumbnail(:size => params[:size])
      if stale?(:etag => tbnail, :public => true)
        send_file tbnail,
          :filename => filename_for_content_disposition(@attachment.filename),
          :type => detect_content_type(@attachment),
          :disposition => 'inline'
      else
        expires_in RedmineCms.cache_expires_in.minutes, :public => true, :private => false
      end
    else
      # No thumbnail for the attachment or thumbnail could not be created
      render :nothing => true, :status => 404
    end
  end
  private

  def find_layout
    @cms_layout = CmsLayout.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

   def authorize_edit
    deny_access unless RedmineCms.allow_edit?
  end

 def find_attachment
    @attachment = Attachment.find(params[:id])
    # Show 404 if the filename in the url is wrong
    raise ActiveRecord::RecordNotFound if params[:filename] && params[:filename] != @attachment.filename
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_attachments
    @attachments = Attachment.where(:container_type => CmsSite.name).where(:id => params[:id] || params[:ids]).to_a
    raise ActiveRecord::RecordNotFound if @attachments.empty?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def set_flash_from_bulk_time_entry_save(time_entries, unsaved_time_entry_ids)
    if unsaved_time_entry_ids.empty?
      flash[:notice] = l(:notice_successful_update) unless time_entries.empty?
    else
      flash[:error] = l(:notice_failed_to_save_time_entries,
                        :count => unsaved_time_entry_ids.size,
                        :total => time_entries.size,
                        :ids => '#' + unsaved_time_entry_ids.join(', #'))
    end
  end

  def detect_content_type(attachment)
    content_type = attachment.content_type
    if content_type.blank? || content_type == "application/octet-stream"
      content_type = Redmine::MimeType.of(attachment.filename)
    end
    content_type.to_s
  end

end
