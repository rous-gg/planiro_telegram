require 'ostruct'
require_relative 'planiro_api'

class CreateProjectHandler
  def initialize(access_token, contract)
    @access_token = access_token
    @contract     = contract
  end
  
  def create(organization_id:, name:, flow_id:, owner_id:)
    data = PlaniroAPI.new(@access_token).create_project(
      organization_id: organization_id,
      name:            name,
      owner_id:        owner_id,
      flow_id:         flow_id
    )

    id = Oj.load(data).first['data']

    data = PlaniroAPI.new(@access_token).update_project(
      id:             id,
      name:           name,
      owner_id:       owner_id,
      flow_id:        flow_id,
      points_visible: true,
      points:         [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    )

    @contract.transact.new_project(id, owner_id)

    OpenStruct.new(
      url: "#{name} https://app.planiro.com/#/#{organization_id}/projects/#{id}/tasks"
    )

  end
end