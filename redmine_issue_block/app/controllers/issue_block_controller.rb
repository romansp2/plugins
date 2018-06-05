class IssueBlockController < ApplicationController
  unloadable
  before_filter :find_issue
  before_filter :authorize

  
  def edit
  end

  def update
    @issue.block = params["issue_block"]["block"] || false
    @issue.block_only_watchers = params["block_permissions"] == "block_only_watchers"
    @issue.block_all_actions   = params["block_permissions"] == "block_all_actions"
    if @issue.save
      respond_to do |format|
        format.html{redirect_to :back, flash: {notice: "Success updated"}}
      end
      return
    else
      respond_to do |format|
        format.html{redirect_to :back, flash: {error: "Fail update"}}
      end
      return
    end
    
  end

end
