require 'ostruct'
require_relative 'planiro_api'

class CreateTaskHandler
  def initialize(access_token)
    @access_token = access_token
  end
  
  def create(project_id:, title:)
    PlaniroAPI.new(@access_token).create_task(
      project_id: project_id,
      title:      title
    )
  end
end