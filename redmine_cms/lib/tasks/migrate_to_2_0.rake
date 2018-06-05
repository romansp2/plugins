
namespace :redmine do
  namespace :cms do
    desc <<-END_DESC
    Migrate CMS project settings from version 0.0.x to 1.x

    Example:
      rake redmine:cms:migrate_settings RAILS_ENV="production"
    END_DESC
    task :migrate_settings => :environment do
      old_settings = ContactsSetting.where("#{ContactsSetting.table_name}.name LIKE 'project_tab%' OR #{ContactsSetting.table_name}.name LIKE 'landing%'")

      old_settings.each do |old_setting|
        if RedmineCms.settings[:project][old_setting.project_id].blank?
          RedmineCms.settings[:project][old_setting.project_id] = {}
        end
        RedmineCms.settings[:project][old_setting.project_id][old_setting.name] = old_setting.value
      end
      RedmineCms.save_settings
      puts "#{old_settings.count} setting migrated"
    end

    desc <<-END_DESC
    Migrate CMS attachments from version 0.0.x to 1.x

    Example:
      rake redmine:cms:migrate_attachments RAILS_ENV="production"
    END_DESC
    task :migrate_attachments => :environment do
      Attachment.where(:container_type => 'Page').update_all(:container_type => 'CmsPage');
      Attachment.where(:container_type => 'Part').update_all(:container_type => 'CmsPart');
    end

    desc <<-END_DESC
    Migrate CMS page parts from version 0.0.x to 1.x

    Example:
      rake redmine:cms:migrate_page_parts RAILS_ENV="production"
    END_DESC
    task :migrate_page_parts => :environment do
      PagesPart.all.each{|pp| pp.part.update(:page_id => pp.page_id)}
      CmsPart.update_all("name = part_type")
    end


  end
end