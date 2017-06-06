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

SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |menu|
    menu.dom_id = 'side-menu'
    menu.dom_class = 'nav'
    menu.item :my_profile,      label_with_icon(t('layouts.sidebar.my_account'), 'fa-user'), my_account_path
    menu.item :change_password, label_with_icon(t('layouts.sidebar.change_password'), 'fa-lock'), edit_user_registration_path
    menu.item :ssh_keys,        label_with_icon(t('layouts.sidebar.my_ssh_keys'), 'octicon octicon-key'), public_keys_path
  end
end