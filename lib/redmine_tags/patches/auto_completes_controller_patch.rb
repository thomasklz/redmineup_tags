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

require_dependency 'auto_completes_controller'

module RedmineContacts
  module Patches
    module AutoCompletesControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
        end
      end

      module InstanceMethods
        def redmine_tags
          @redmine_tags = []
          q = (params[:q] || params[:term]).to_s.strip
          scope = Issue.all_tags(:name_like => q)
          scope = scope.limit(params[:limit] || 10)
          @redmine_tags = scope.to_a.sort! { |x, y| x.name <=> y.name }
          render :layout => false, :partial => 'redmine_tags'
        end
      end
    end
  end
end

unless AutoCompletesController.included_modules.include?(RedmineContacts::Patches::AutoCompletesControllerPatch)
  AutoCompletesController.send(:include, RedmineContacts::Patches::AutoCompletesControllerPatch)
end
