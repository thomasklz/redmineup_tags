# encoding: utf-8
#
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

require File.expand_path('../../test_helper', __FILE__)

class AutoCompletesControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers

  def setup
    @tag = RedmineCrm::Tag.create(:name => 'Test_tag')
    @request.session[:user_id] = 1
  end

  def test_redmine_tags_should_not_be_case_sensitive
    issue = Issue.find(1)
    issue.tags << @tag
    get :redmine_tags, :project_id => 'ecookbook', :q => 'te'
    assert_response :success
    assert_not_nil assigns(:redmine_tags)
    assert_equal assigns(:redmine_tags), [@tag]
  ensure
    issue.tags = []
  end

  def test_contacts_should_return_json
    issue = Issue.find(1)
    issue.tags << @tag
    get :redmine_tags, :project_id => 'ecookbook', :q => 'te'
    assert_response :success
    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Array, json
    parsed_tag = json.last
    assert_kind_of Hash, parsed_tag
    assert_equal @tag.name, parsed_tag['id']
    assert_equal @tag.name, parsed_tag['text']
  ensure
    issue.tags = []
  end
end
