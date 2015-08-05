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

module Containers
  class Start < ActiveUseCase::Base

    def execute(opts = {})
      if container.docker_id
        container_start(opts)
      else
        error_message("Container does not exist !.")
      end
    end


    def container_start(opts = {})
      update_route = opts.delete(:update_route){ false }
      begin
        container.docker_start
      rescue => e
        log_exception(e)
        error_message("Erreurs lors du démarrage du contenaire '#{container.docker_id[0..12]}'")
      else
        container.application.update_lb_route! if update_route
      end
    end

  end
end
