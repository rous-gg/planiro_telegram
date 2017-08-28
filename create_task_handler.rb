require 'ostruct'
require_relative 'planiro_api'

class CreateTaskHandler
  def initialize(access_token, contract)
    @access_token = access_token
    @contract     = contract
  end
  
  def create(project_id:, title:)
    data = PlaniroAPI.new(@access_token).create_task(
      project_id: project_id,
      title:      title
    )

    task_id = Oj.load(data).first['data']['id']

    @contract.transact.create_project_task(project_id, task_id)
  end
end