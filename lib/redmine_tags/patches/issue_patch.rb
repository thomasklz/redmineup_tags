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

require_dependency 'issue'

module RedmineTags
  module Patches
    module IssuePatch

      def self.included(base)
        base.extend(ClassMethods)

        base.class_eval do
          unloadable
          rcrm_acts_as_taggable

          class << self
            alias_method_chain :available_tags, :redmine_tags
          end

          scope :on_project, lambda { |project|
            project = project.id if project.is_a? Project
            { :conditions => ["#{Project.table_name}.id=?", project] }
          }
        end
      end

      module ClassMethods
        def available_tags_with_redmine_tags(options = {})
          scope = available_tags_without_redmine_tags(options)
          return scope unless options[:open_only]
          scope.joins("JOIN #{IssueStatus.table_name} ON #{IssueStatus.table_name}.id = #{table_name}.status_id").
                where("#{IssueStatus.table_name}.is_closed = ?", false)
        end

        def all_tags(options = {})
          scope = RedmineCrm::Tag.where({})
          scope = scope.where("LOWER(#{RedmineCrm::Tag.table_name}.name) LIKE LOWER(?)", "%#{options[:name_like]}%") if options[:name_like]
          join = []
          join << "JOIN #{RedmineCrm::Tagging.table_name} ON #{RedmineCrm::Tagging.table_name}.tag_id = #{RedmineCrm::Tag.table_name}.id "
          join << "JOIN #{Issue.table_name} ON #{Issue.table_name}.id = #{RedmineCrm::Tagging.table_name}.taggable_id
            AND #{RedmineCrm::Tagging.table_name}.taggable_type = '#{Issue.name}' "
          scope = scope.joins(join.join(' '))
          scope = scope.select("#{RedmineCrm::Tag.table_name}.*, COUNT(DISTINCT #{RedmineCrm::Tagging.table_name}.taggable_id) AS count")
          scope = scope.group("#{RedmineCrm::Tag.table_name}.id, #{RedmineCrm::Tag.table_name}.name ")
          scope = scope.having('COUNT(*) > 0')
          scope.order("#{RedmineCrm::Tag.table_name}.name")
        end
      end
    end
  end
end
