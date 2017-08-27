require 'ostruct'
require_relative 'planiro_api'

class CreateProjectHandler
  def initialize(access_token)
    @access_token = access_token
  end
  
  def create(organization_id:, name:, flow_id:, owner_id:)
    data = PlaniroAPI.new(@access_token).create_project(
      organization_id: organization_id,
      name:            name,
      owner_id:        owner_id,
      flow_id:         flow_id
    )

    id = Oj.load(data).first['data']

    OpenStruct.new(
      url: "#{name} https://app.planiro.com/#/#{organization_id}/projects/#{id}/tasks"
    )
  end
end