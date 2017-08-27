require 'ostruct'
require_relative 'planiro_api'

class SetTaskAwardHandler
  def initialize(access_token)
    @access_token = access_token
  end
  
  def set_award(task_id:, award:)
    PlaniroAPI.new(@access_token).change_task_points(
      task_id: task_id,
      points:  award
    )
  end
end