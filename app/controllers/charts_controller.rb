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

class ChartsController < ApplicationController

  ALLOWED_TYPES  = ['pushes', 'releases']
  ALLOWED_GROUPS = ['month', 'day_of_week', 'day']

  before_action :set_application
  before_action :authorize
  before_action :set_type
  before_action :set_group_by


  def charts
    result =
      case @group_by
      when 'month'
        @application.send(@type).group_by_month(:created_at).count
      when 'day_of_week'
        @application.send(@type).group_by_day_of_week(:created_at, format: '%A').count
      when 'day'
        @application.send(@type).group_by_day(:created_at).count
      end
    render json: result
  end


  private


    def set_type
      if ALLOWED_TYPES.include?(params[:type])
        @type = params[:type]
      else
        render_404
      end
    end


    def set_group_by
      if ALLOWED_GROUPS.include?(params[:group_by])
        @group_by = params[:group_by]
      else
        render_404
      end
    end

end