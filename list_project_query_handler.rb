require_relative 'organization_query_handler'

class ListProjectQueryHandler
  def list_projects(access_token)
    organization = OrganizationQueryHandler.new.get_organization(access_token)
    organization['projects'].select {|pr| !pr['archived']}
  end
end
