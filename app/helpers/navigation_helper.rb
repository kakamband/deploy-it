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

module NavigationHelper

  # Here we create zones for menus :
  # We have 3 zones :
  # 1. the header menu
  # 2. the top menu of the left sidebar
  # 3. the bottom menu of the left sidebar


  def render_topbar_menu
    TopbarMenu.new(self).render
  end


  def render_sidebar_menu_top
    return '' if !User.current.logged?
    SidebarMenuTop.new(self).render
  end


  def render_sidebar_menu_bottom
    return '' if !User.current.logged?
    SidebarMenuBottom.new(self).render
  end


  def current_menu_name
    if admin_section?
      t('label.admin')
    elsif profile_section?
      t('label.my.account')
    elsif welcome_section?
      t('label.help')
    else
      t('label.application.plural')
    end
  end


  def render_page_content(opts = {})
    sidebar = render 'layouts/sidebar'
    if sidebar.strip != ''
      sidebar + content_tag(:div, opts) do
        render 'layouts/page'
      end
    else
      content_tag(:div, class: 'col-md-12 col-sm-12') do
        render 'layouts/page'
      end
    end
  end


  # Here we create all menus we need with simple-navigation gem.
  # Each menu includes its own condition of display depending on the current user and/or the current controller.
  # This generate HTML list with Bootstrap css class.


  USER_CONTROLLERS = [ 'MyController', 'PublicKeysController', 'RegistrationsController' ]


  def welcome_section?
    !admin_section? && !dashboard_section? && !profile_section?
  end


  def admin_section?
    controller.class.name.split("::").first == 'Admin'
  end


  def dashboard_section?
    !USER_CONTROLLERS.include?(controller.class.name) && controller.class.name != 'WelcomeController'
  end


  def profile_section?
    USER_CONTROLLERS.include?(controller.class.name)
  end


  def application_section?
    controller.class.name == 'ApplicationsController'
  end


  def credential_section?
    controller.class.name == 'CredentialsController'
  end

end
