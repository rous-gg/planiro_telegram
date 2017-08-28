require 'ostruct'
require_relative 'planiro_api'

class AssignTaskUserHandler
  def initialize(access_token)
    @access_token = access_token
  end
  
  def assign_user(task_id:, user_id:)
    PlaniroAPI.new(@access_token).assign_user(
      task_id: task_id,
      user_id: user_id
    )
  end
end