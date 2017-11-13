# This file is a part of Redmine Tags (redmine_tags) plugin,
# customer relationship management plugin for Redmine
#
# Copyright (C) 2011-2017 RedmineUP
# http://www.redmineup.com/
#
# redmine_tags is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_tags is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_tags.  If not, see <http://www.gnu.org/licenses/>.

requires_redmine_crm :version_or_higher => '0.0.31' rescue raise "\n\033[31mRedmine requires newer redmine_crm gem version.\nPlease update with 'bundle update redmine_crm'.\033[0m"

require 'redmine'
require 'redmine_tags'

TAGS_VERSION_NUMBER = '2.0.1'
TAGS_VERSION_TYPE = "Light version"

Redmine::Plugin.register :redmineup_tags do
  name "Redmine Tags plugin (#{TAGS_VERSION_TYPE})"
  author 'RedmineUP'
  description 'Redmine issues tagging support'
  version TAGS_VERSION_NUMBER
  url 'https://www.redmineup.com/pages/tags'
  author_url 'mailto:support@redmineup.com'

  requires_redmine :version_or_higher => '2.1.0'

  settings :default => {
    :issues_sidebar => 'none',
    :issues_show_count => 0,
    :issues_open_only => 0,
    :issues_sort_by => 'name',
    :issues_sort_order => 'asc'
  }, :partial => 'tags/settings'

  menu :admin_menu, :tags, {:controller => 'settings', :action => 'plugin', :id => "redmineup_tags"}, :caption => :tags, :html => {:class => 'icon'}
end

ActionDispatch::Callbacks.to_prepare do
  unless Issue.included_modules.include?(RedmineTags::Patches::IssuePatch)
    Issue.send(:include, RedmineTags::Patches::IssuePatch)
  end

  [IssuesController, CalendarsController, GanttsController, SettingsController].each do |controller|
    RedmineTags::Patches::AddHelpersForIssueTagsPatch.apply(controller)
  end
  RedmineTags::Patches::AddHelpersForIssueTagsPatch.apply(ImportsController) if Redmine::VERSION.to_s > '3.2'

  base = ActiveSupport::Dependencies::search_for_file('issue_query') ? IssueQuery : Query
  unless base.included_modules.include?(RedmineTags::Patches::QueryPatch)
    base.send(:include, RedmineTags::Patches::QueryPatch)
  end

  base = ActiveSupport::Dependencies::search_for_file('issue_queries_helper') ? IssueQueriesHelper : QueriesHelper
  unless base.included_modules.include?(RedmineTags::Patches::QueriesHelperPatch)
    base.send(:include, RedmineTags::Patches::QueriesHelperPatch)
  end
end

require 'redmine_tags/hooks/model_issue_hook'
require 'redmine_tags/hooks/views_issues_hook'
require 'redmine_tags/hooks/views_layouts_hook'
require 'redmine_tags/patches/agile_query_patch' if Redmine::Plugin.installed?(:redmine_agile) && Redmine::Plugin.find(:redmine_agile).version >= '1.4.3'
