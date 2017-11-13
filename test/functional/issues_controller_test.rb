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

class IssuesControllerTest < ActionController::TestCase
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
    @tag = RedmineCrm::Tag.create(:name => 'test_tag')
    @last_tag = RedmineCrm::Tag.create(:name => 'last_tag')
    @request.session[:user_id] = 1
  end

  def test_get_index_with_tags
    issue = Issue.find(2)
    issue.tags << @tag
    get :index, :f => ['status_id', 'issue_tags',''],
                :op => { :status_id => 'o', :issue_tags => '=' },
                :v =>  { :issue_tags => ['test_tag'] },
                :c => ["status", "priority", "subject", "tags"],
                :project_id => "ecookbook"
    assert_response :success
    assert_equal assigns(:issues), [issue]
    assert_select 'table.list.issues tr.issue td.subject', issue.subject
    assert_select 'table.list.issues tr.issue td.tags a', 'test_tag'
  ensure
    issue.tags = []
  end

  def test_get_index_with_sidebar_tags_in_list_by_count
    issue1 = Issue.find(1)
    issue1.tags << @tag
    issue2 = Issue.find(2)
    issue2.tags << @tag
    issue2.tags << @last_tag
    RedmineTags.stubs(:settings).returns({ 'issues_sidebar' => 'list',
                                           'issues_show_count' => '1',
                                           'issues_sort_by' => 'count',
                                           'issues_sort_order' => 'desc' })

    get :index, :project_id => 'ecookbook'
    assert_response :success
    assert_select '.tag-label', 'test_tag(2)'
  ensure
    issue1.tags = []
    issue2.tags = []
    RedmineTags.unstub(:settings)
  end

  def test_get_index_with_sidebar_tags_in_cloud_by_count
    issue1 = Issue.find(1)
    issue1.tags << @last_tag

    issue2 = Issue.find(2)
    issue2.tags << @tag
    issue2.tags << @last_tag

    RedmineTags.stubs(:settings).returns({ 'issues_sidebar' => 'cloud',
                                           'issues_show_count' => '1',
                                           'issues_sort_by' => 'count',
                                           'issues_sort_order' => 'desc' })
    get :index, :project_id => 'ecookbook'
    assert_response :success
    assert_select '.tag-label', 'last_tag(2)'
  ensure
    issue1.tags = []
    issue2.tags = []
    RedmineTags.unstub(:settings)
  end

  def test_post_bulk_edit_without_tags_change
    issue1 = Issue.find(1)
    issue1.tags << @tag

    issue2 = Issue.find(2)
    issue2.tags << @last_tag

    post :bulk_update, :ids => [1, 2], :issue => {:project_id => '', :tracker_id => '', :tag_list => [''] }
    assert_response :redirect
    assert_equal [@tag.name], Issue.find(1).tag_list
    assert_equal [@last_tag.name], Issue.find(2).tag_list
  ensure
    issue1.tags = []
    issue2.tags = []
    RedmineTags.unstub(:settings)
  end

  def test_post_bulk_edit_with_changed_tags
    issue1 = Issue.find(1)
    issue1.tags << @tag

    issue2 = Issue.find(2)
    issue2.tags << @last_tag

    post :bulk_update, :ids => [1, 2], :issue => {:project_id => '', :tracker_id => '', :tag_list => ['bulk_tag'] }
    assert_response :redirect
    assert_equal ['bulk_tag'], Issue.find(1).tag_list
    assert_equal ['bulk_tag'], Issue.find(2).tag_list
  ensure
    issue1.tags = []
    issue2.tags = []
    RedmineTags.unstub(:settings)
  end
end
