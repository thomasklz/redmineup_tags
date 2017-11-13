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

require_dependency 'queries_helper'
if ActiveSupport::Dependencies::search_for_file('issue_queries_helper')
  require_dependency 'issue_queries_query'
end

module RedmineTags
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :column_value, :tags
        end
      end

      module InstanceMethods
        include TagsHelper

        def column_value_with_tags(column, list_object, value)
          if column.name == :tags && list_object.is_a?(Issue)
            [value].flatten.collect{ |t| render_issue_tag_link(t) }.join(RedmineTags.settings['issues_use_colors'].to_i > 0 ? ' ' : ', ')
          else
            column_value_without_tags(column, list_object, value)
          end
        end
      end
    end
  end
end
