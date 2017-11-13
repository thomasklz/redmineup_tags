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

module RedmineTags
  module Patches

    module IssuesControllerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          alias_method_chain :update_issue_from_params, :redmine_tags
        end
      end

      module InstanceMethods
        def update_issue_from_params_with_redmine_tags
          is_updated = update_issue_from_params_without_redmine_tags
          return false unless is_updated
          if params[:issue] && params[:issue][:tag_list]
            @issue.tag_list = params[:issue][:tag_list].reject(&:empty?)
          end
          is_updated
        end
      end
    end
  end
end

unless IssuesController.included_modules.include?(RedmineTags::Patches::IssuesControllerPatch)
  IssuesController.send(:include, RedmineTags::Patches::IssuesControllerPatch)
end
