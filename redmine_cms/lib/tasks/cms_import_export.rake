namespace :redmine do
  namespace :cms do
    desc <<-END_DESC
    CMS content export rake

    Example:
      rake redmine:cms:site_export include_attachments=<true|false> RAILS_ENV="production"
    END_DESC
    task :site_export => :environment do
      include_attachments = ENV['include_attachments'] == 'true' ? 1 : 0
      cms_export = CmsExport.new('website')
      cms_export.configure(:attachment_content => include_attachments)
      File.open('./website.yaml', 'w') do |export_file|
        export_file.write(cms_export.export_website)
      end
      puts "Site was exported in #{Dir.pwd}/website.yaml"
    end

    desc <<-END_DESC
    CMS content import rake

    Example:
      redmine:cms:site_import rewrite_existed=<true|false> author=<user login> import_file RAILS_ENV="production"
    END_DESC
    task :site_import => :environment do
      rewrite_existed = ENV['rewrite_existed'] == 'true' ? 1 : 0
      author = ENV['author'] ? User.where(:login => ENV['author']).first : User.anonymous
      import_file = ARGV.last
      raise "Import file #{import_file} not found" unless File.exist?(import_file)
      raise "User with login #{ENV['author']} not found" unless author
      cms_import = CmsImport.new('website')
      cms_import.author = author
      cms_import.configure(:rewrite => rewrite_existed)
      cms_import.import_website(import_file)
      puts 'Import file was successfully applied'
    end
  end
end
