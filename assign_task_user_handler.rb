require 'ostruct'
require_relative 'planiro_api'

class AssignTaskUserHandler
  def initialize(access_token, contract)
    @access_token = access_token
    @contract     = contract
  end
  
  def assign_user(task_id:, user_id:)
    PlaniroAPI.new(@access_token).assign_user(
      task_id: task_id,
      user_id: user_id
    )
    @contract.transact.change_task_assignee(task_id, user_id)
  end
end