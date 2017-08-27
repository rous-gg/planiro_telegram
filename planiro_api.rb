require 'rest-client'
require 'oj'

# RestClient.log = Logger.new($stderr)

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

  def create_project(organization_id:, name:, owner_id:, flow_id:)
    RestClient.post(
      "#{SITE_URL}/commands.json",
      {
        access_token:    @access_token,
        commands: [
          '' => {
            guid: 'GUID',
            name: 'pm.projects.create_project',
            params: {
              name:            name,
              organization_id: organization_id,
              owner_id:        owner_id,
              calendar_color:  0,
              flow_id:         flow_id
            }
          }
        ]
      }
    )
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