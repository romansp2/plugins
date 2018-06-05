require 'redmine'
require 'redmine_base_select2/hooks'

Redmine::Plugin.register :redmine_base_select2 do
  name 'Redmine Select2 plugin'
  description 'This plugin adds the Select2 component to your Redmine instance'
  author 'Jean-Baptiste BARTH'
  author_url ''
  version '4.0.1'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_base_select2.git'
  requires_redmine :version_or_higher => '2.1.0'
end
