# frozen_string_literal: true
# DeployIt - Docker containers management software
# Copyright (C) 2015 Nicolas Rodriguez (nrodriguez@jbox-web.com), JBox Web (http://www.jbox-web.com)
#
# This code is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License, version 3,
# as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License, version 3,
# along with this program.  If not, see <http://www.gnu.org/licenses/>

class ContainerPresenter < SimpleDelegator

  attr_reader :container


  def initialize(container, template)
    super(template)
    @container = container
  end


  def docker_name
    container.docker_name rescue "Cannot find container"
  end


  def container_actions
    content_tag(:span, class: 'pull-right') do
      case container.docker_proxy.state
      when :running
        links_for_running_container
      when :paused
        links_for_paused_container
      when :stopped
        links_for_stopped_container
      end
    end
  end


  def container_infos
    uptime = distance_of_time_in_words(DateTime.now, container.docker_proxy.uptime) rescue 'Not running'
    html_list(class: 'container-infos') do
      add_item(t('.state'), container_state_tag) +
      add_item(t('.health'), container_health_tag) +
      add_item(t('.docker_id'), container.short_id) +
      add_item(t('.uptime'), uptime) +
      add_item(t('.backend_url'), container.docker_proxy.backend_url) +
      add_item(t('.current_revision'), container.current_revision) +
      add_item(t('.current_server'), container.docker_server.to_s)
    end
  end


  private


    def add_item(label, item)
      content_tag(:li) do
        content_tag(:span, label) + content_tag(:span, item, class: 'pull-right')
      end
    end


    def container_state_tag
      case container.docker_proxy.state
      when :running
        label   = t('.running')
        method  = :label_with_success_tag
        icon    = :label_with_icon_check
      when :paused
        label   = t('.paused')
        method  = :label_with_warning_tag
        icon    = :label_with_icon_warning
      when :stopped
        label   = t('.stopped')
        method  = :label_with_danger_tag
        icon    = :label_with_icon_warning
      end

      self.send(method) do
        self.send(icon, "#{label}")
      end
    end


    def container_health_tag
      if container.infected?
        label   = t('.infected')
        method  = :label_with_danger_tag
        icon    = :label_with_icon_warning
      else
        label   = t('.healthy')
        method  = :label_with_success_tag
        icon    = :label_with_icon_check
      end

      link_name =
        self.send(method) do
          self.send(icon, "#{label}")
        end

      link_to link_name, events_application_path(container.application)
    end


    def links_for_running_container
      manage_link('pause', 'fa-pause') +
      manage_link('stop', 'fa-power-off') +
      manage_link('restart', 'fa-refresh') +
      manage_link('destroy_forever', 'fa-trash-o') +
      info_link +
      top_link
    end


    def links_for_paused_container
      manage_link('unpause', 'fa-play')
    end


    def links_for_stopped_container
      manage_link('start', 'fa-power-off') +
      manage_link('destroy_forever', 'fa-trash-o')
    end


    def manage_link(action, icon)
      link_to_icon(icon, manage_application_container_path(container.application, container, deploy_action: action), link_options(action), icon_options)
    end


    def info_link
      link_to_icon('fa-info-circle', infos_application_container_path(container.application, container), modal_options.merge(title: t('.docker_infos')), icon_options)
    end


    def top_link
      link_to_icon('fa-gears', top_application_container_path(container.application, container), modal_options.merge(title: t('.docker_top')), icon_options)
    end


    def modal_options
      { data: { toggle: 'ajax-modal', draggable: false, modal_size: 'lg' } }
    end


    def link_options(action)
      { title: t(".#{action}"), method: :post, remote: true }
    end


    def icon_options
      { fixed: true, bigger: false }
    end

end
