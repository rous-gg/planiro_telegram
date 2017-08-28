require 'ostruct'
require_relative 'planiro_api'

class AddProjectMemberHandler
  def initialize(access_token, contract)
    @access_token = access_token
    @contract     = contract
  end
  
  def create(project_id:, user_id:)
    PlaniroAPI.new(@access_token).add_project_member(
      user_id:    user_id,
      project_id: project_id
    )

    @contract.transact.add_member_to_project(project_id, user_id)
  end
end