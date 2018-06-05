class ChangeAuthorOfIssueController < ApplicationController
  unloadable
  before_filter :find_issue
  before_filter :permit_params
  before_filter :authorize

  def edit
    @authors_members = @project.members.to_a.delete_if{|member| !member.roles.find{|role| role.allowed_to?(:add_issues)}}
    @authors = @authors_members.map(&:principal)
  end

  def update
  	author_changed = false
  	new_author = User.find_by_id(params[:author_id])
  	if new_author.nil?
      respond_to do |format|
  	    format.html{redirect_to :back, :flash => { :error => "Cannot find user" }}
  	  end
      return
  	end
    authors_members = @project.members.to_a.delete_if{|member| !member.roles.find{|role| role.allowed_to?(:add_issues)}}
    authors = authors_members.map(&:principal)

  	if authors.include?(new_author)
  	  old_author = @issue.author
      @issue.author_id = new_author.id
      journal = Journal.new(:journalized => @issue, :user => User.current)
	    journal.details << JournalDetail.new(:property => 'issue_author', 
	                                         :prop_key =>  @issue.id, 
	                                         :old_value => old_author.id,
	                                         :value => new_author.id                                                       
	                                        )	 

	    ActiveRecord::Base.transaction do
	      unless @issue.save && journal.save
	        raise ActiveRecord::Rollback
        else
          author_changed = true
	      end
	    end   
      if author_changed
      	respond_to do |format|
  	      format.html{redirect_to :back, :flash => { :notice => "Author was change to #{view_context.link_to_user(new_author, :class => 'user')}" }}
  	    end
        return
      else
      	respond_to do |format|
  	      format.html{redirect_to :back, :flash => { :error => "Author was not change to #{view_context.link_to_user(new_author, :class => 'user')}" }}
  	    end
        return
      end
    else
      respond_to do |format|
  	      format.html{redirect_to :back, :flash => { :error => "You cannot set #{view_context.link_to_user(new_author, :class => 'user')} as author" }}
  	  end
      return
  	end
  end

  private

    def permit_params
      params.permit(:author_id)
    end
end


      