require 'ostruct'
require_relative 'planiro_api'

class AddProjectMemberHandler
  def initialize(access_token)
    @access_token = access_token
  end
  
  def create(project_id:, user_id:)
    PlaniroAPI.new(@access_token).add_project_member(
      user_id:    user_id,
      project_id: project_id
    )
  end
end