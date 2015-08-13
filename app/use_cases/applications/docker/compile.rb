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

require 'fileutils'

module Applications
  module Docker
    class Compile < ActiveUseCase::Base

      include Helpers::Docker

      attr_reader :logger


      def execute(logger, archive_path)
        @logger = logger

        cleanup(application.image_name)
        receive(archive_path, docker_options_for(:receive))
      end


      def cleanup(image)
        logger.title "Cleaning up the room"
        docker_connection.remove_stopped_containers_by_name(image)
      end


      def receive(archive_path, docker_options = {})
        # Push repository data within the container in tar format
        logger.title "Creating a new Docker image with your application"
        begin
          new_image_from_file(application.image_type, application.image_name, archive_path, docker_options)
        rescue ::Docker::Error::TimeoutError => e
          error_message tt('errors.on_receive.docker_timeout')
        else
          build(docker_options_for(:build))
          release(docker_options_for(:release))
        ensure
          # Remove repository data
          FileUtils.rm(archive_path, force: true) unless archive_path.nil?
        end
      end


      def build(docker_options = {})
        # Inject BUILD_ENV file if exists
        install_build_vars

        # Execute plugins
        execute_plugins(:pre_build, docker_options)

        # Run BuildStep builder script
        run_command('/build/builder', docker_options)

        # Execute plugins
        execute_plugins(:post_build, docker_options)
      end


      def release(docker_options = {})
        # Inject ENV file if exists
        install_app_vars

        # Inject DATABASE file if exists
        install_db_vars

        # Execute plugins
        execute_plugins(:pre_deploy, docker_options)
      end


      private


        def install_build_vars
          if File.exists? application.env_file_for(:build)
            logger.title "Adding environment variables to build environment"
            copy_file_to_container application.env_file_for(:build), '/app/.env', '644'
          end
        end


        def install_app_vars
          if File.exists? application.env_file_for(:deploy)
            logger.title "Adding environment variables to runtime environment"
            copy_file_to_container application.env_file_for(:deploy), '/app/.profile.d/app-env.sh', '644', create_parent_dir: true
          end
        end


        def install_db_vars
          if File.exists? application.env_file_for(:database)
            logger.title 'Pushing database variables within the container'
            copy_file_to_container application.env_file_for(:database), '/app/.profile.d/db-env.sh', '640'
          end
        end


        def docker_connection
          DockerServerProxy.local_server
        end


        def docker_options_for(step)
          application.docker_options_for(step)
        end


        def execute_plugins(step, docker_options = {})
          DockerPlugin.execute(step, application, docker_connection, logger, docker_options)
        end

    end
  end
end
