require_relative 'organization_query_handler'

class ListProjectTasksQueryHandler
  def initialize(access_token)
    @access_token = access_token
  end
  
  def list_project_tasks(project_id)
    PlaniroAPI.new(@access_token).list_project_tasks(project_id)
  end
end
