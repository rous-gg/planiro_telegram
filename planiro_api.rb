require 'rest-client'
require 'oj'

class PlaniroAPI
  SITE_URL = "https://app.planiro.com"

  def initialize(access_token)
    @access_token = access_token
  end

  def get_account_data
    get_by_path("/account/get_account_data.json")
  end

  def list_organization_flows(organization_id)
    get_by_path("/organization/stage_flow/flows/list.json", organization_id: organization_id)['data']
  end

  private
  
  def get_by_path(path, params = {})
    data = RestClient.get("#{SITE_URL}#{path}", params: params.merge(access_token: @access_token))
    Oj.load(data)
  rescue => e
    puts e.inspect
    []
  end
end