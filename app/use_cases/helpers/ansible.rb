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

module Helpers
  module Ansible

    def execute_if_exists(object, &block)
      if object.nil?
        error_message(I18n.t('ansible.errors.unavailable_server'))
      else
        yield
      end
    end


    def catch_errors(object, &block)
      begin
        object.recreate_inventory_file!
        yield
      rescue => e
        error_message(treat_ansible_exception(e))
        log_exception(e)
      end
    end


    def treat_ansible_exception(e)
      case e
      when DeployIt::Error::IOError
        I18n.t('ansible.errors.io_error')
      when DeployIt::Error::InvalidServerUpdate
        I18n.t('ansible.errors.invalid_server_update')
      when DeployIt::Error::UnreachableServer
        I18n.t('ansible.errors.unreachable_server')
      when DeployIt::Error::ServerUpdateFailed
        I18n.t('ansible.errors.server_update_failed')
      else
        I18n.t('ansible.errors.unknown_error')
      end
    end

  end
end
