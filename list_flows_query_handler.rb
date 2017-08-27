require_relative 'organization_query_handler'

class ListFlowsQueryHandler
  def list_flows(access_token)
    organization_id = OrganizationQueryHandler.new.get_organization_id(access_token)
    PlaniroAPI.new(access_token).list_organization_flows(organization_id)
  end
end
