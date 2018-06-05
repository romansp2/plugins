Redmine::Plugin.register :redmine_users_assignment do
  name 'Redmine Users Assignment plugin'
  author 'Mikhail Malov'
  description 'This is a plugin for Redmine to assign users by role in Issue(Author, etc) in fields of type user.'
  version '1.0.1'
  url 'https://gitlab.qazz.pw/mich.malov/redmine_users_assignment.git'
  author_url 'mailto:mich.malov@smileexpo.ru?Subject=UsersAssignment'
end

require_dependency 'redmine_users_assignment/hooks'


