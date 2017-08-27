require_relative 'planiro_api'

class OrganizationQueryHandler
  def get_organization(access_token)
    api = PlaniroAPI.new(access_token)
    data = api.get_account_data

    data['organizations'].detect {|org| org['type'] == 'regular'}
  end

  def get_organization_id(access_token)
    get_organization(access_token)['id']
  end
end