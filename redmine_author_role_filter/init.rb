Redmine::Plugin.register :redmine_author_role_filter do
  name 'Redmine Author Role Filter plugin'
  author 'Mikhail Malov'
  description 'This is a plugin for Redmine adding author role filter to issues page'
  version '1.0.0'
  url 'https://gitlab.qazz.pw/mich.malov/redmine_author_role_filter.git'
  author_url 'mailto:mich.malov@smileexpo.ru?Subject=Author%20Role%20Filter'
end

require_dependency 'redmine_author_role_filter/redmine_author_role_filter'
