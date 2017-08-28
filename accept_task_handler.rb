require 'ostruct'
require_relative 'planiro_api'

class AcceptTaskHandler
  def initialize(access_token)
    @access_token = access_token
  end
  
  def accept_task(task_id:, project_id:)
    flows = ListFlowsQueryHandler.new.list_flows(@access_token)
    organizaion = OrganizationQueryHandler.new.get_organization(@access_token)

    project = organizaion['projects'].detect do |project|
      project['id'] == project_id
    end

    flow_id = project['flow_id']

    flow = flows.detect do |flow|
      flow['id'] == flow_id
    end

    stage = flow['stages'].detect do |stage|
      stage['type'] == 'completed'
    end
    
    PlaniroAPI.new(@access_token).change_task_stage(
      task_id:  task_id,
      stage_id: stage['id']
    )
  end
end