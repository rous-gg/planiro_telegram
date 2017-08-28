require 'ostruct'
require_relative 'planiro_api'

class SetTaskAwardHandler
  def initialize(access_token, contract)
    @access_token = access_token
    @contract     = contract
  end
  
  def set_award(task_id:, award:)
    PlaniroAPI.new(@access_token).change_task_points(
      task_id: task_id,
      points:  award
    )

    @contract.transact.set_task_award(task_id, award)
  end
end