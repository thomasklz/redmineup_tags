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

require 'digest/md5'

module TagsHelper
  include RedmineCrm::TagsHelper

  def render_issue_tag_link(tag, options = {})
    filters = [[:issue_tags, '=', tag.name]]
    filters << [:status_id, 'o'] if options[:open_only]
    if options[:use_search]
      content =  link_to(tag, {:controller => "search", :action => "index", :id => @project, :q => tag.name, :wiki_pages => true, :issues => true})
    else
      content = link_to_issue_filter tag.name, filters, :project_id => @project
    end
    if options[:show_count]
      content << content_tag('span', "(#{tag.count})", :class => 'tag-count')
    end

    style = RedmineTags.settings['issues_use_colors'].to_i > 0 ? {:class => "tag-label-color", :style => "background-color: #{tag_color(tag)}"} : {:class => "tag-label"}
    content_tag('span', content, style)
  end

  def tag_color(tag)
    tag_name = tag.respond_to?(:name) ? tag.name : tag
    "##{Digest::MD5.hexdigest(tag_name)[0..5]}"
  end

  def render_tags_list(tags, options = {})
    unless tags.nil? or tags.empty?
      content, style = '', options.delete(:style)

      tags = tags.all.to_a if tags.respond_to?(:all)

      case sorting = "#{RedmineTags.settings['issues_sort_by']}:#{RedmineTags.settings['issues_sort_order']}"
        when "name:asc";    tags.sort! { |a,b| a.name <=> b.name }
        when "name:desc";   tags.sort! { |a,b| b.name <=> a.name }
        when "count:asc";   tags.sort! { |a,b| a.count <=> b.count }
        when "count:desc";  tags.sort! { |a,b| b.count <=> a.count }
        # Unknown sorting option. Fallback to default one
        else
          logger.warn "[redmine_tags] Unknown sorting option: <#{sorting}>"
          tags.sort! { |a,b| a.name <=> b.name }
      end

      if :list == style
        list_el, item_el = 'ul', 'li'
      elsif :simple_cloud == style
        list_el, item_el = 'div', 'span'
      elsif :cloud == style
        list_el, item_el = 'div', 'span'
      else
        raise "Unknown list style"
      end

      content = content.html_safe
      if :list == style && RedmineTags.settings['issues_sort_by'] == 'name'
        tags.group_by { |tag| tag.name.downcase.first }.each do |letter, grouped_tags|
          content << content_tag(item_el, letter.upcase, :class => 'letter', :style => '')
          add_tags(style, grouped_tags, content, item_el, options)
        end
      else
        add_tags(style, tags, content, item_el, options)
      end

      content_tag(list_el, content, :class => 'tags-cloud', :style => (:simple_cloud == style ? "text-align: left;" : ""))
    end
  end

def link_to_issue_filter(title, filters, options = {})
    options.merge! link_to_issue_filter_options(filters)
    link_to title, options
  end


  # returns hash suitable for passing it to the <tt>to_link</tt>
  # === parameters
  # * <i>filters</i> = array of arrays. each child array is an array of strings:
  #                    name, operator and value
  # === example
  # link_to 'foobar', link_to_issue_filter_options [[ :tags, '~', 'foobar' ]]
  #
  # filters = [[ :tags, '~', 'bazbaz' ], [:status_id, 'o']]
  # link_to 'bazbaz', link_to_issue_filter_options filters
  def link_to_issue_filter_options(filters)
    options = {
      :controller => 'issues',
      :action => 'index',
      :set_filter => 1,
      :fields => [],
      :values => {},
      :operators => {}
    }

    filters.each do |f|
      name, operator, value = f
      options[:fields].push(name)
      options[:operators][name] = operator
      options[:values][name] = [value]
    end

    options
  end

  private

  def add_tags(style, tags, content, item_el, options)
    tag_cloud tags, (1..8).to_a do |tag, weight|
      content << ' '.html_safe + content_tag(item_el, render_issue_tag_link(tag, options), :class => "tag-nube-#{weight}", :style => (:simple_cloud == style ? "font-size: 1em;" : "")) + " ".html_safe
    end
  end

end
