require 'rest-client'
require 'oj'

RestClient.log = Logger.new($stderr)

class PlaniroAPI
  SITE_URL = "https://app.planiro.com"

  def initialize(access_token)
    @access_token = access_token
  end

  def get_account_data
    get_by_path("/account/get_account_data.json")
  end

  def get_api_token(email, password)
    get_by_path("/account/get_api_token.json", {email: email, password: password})
  end

  def get_project(project_id)
    get_by_path("/pm/projects/get_project.json", {id: project_id})
  end

  def list_organization_flows(organization_id)
    get_by_path("/organization/stage_flow/flows/list.json", organization_id: organization_id)['data']
  end

  def list_project_tasks(project_id)
    get_by_path("/pm/tasks/get_uncompleted_tasks.json", project_id: project_id)['data']
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

  def update_project(id:, name:, owner_id:, flow_id:, points:, points_visible:)
    puts RestClient.post(
      "#{SITE_URL}/commands.json",
      {
        access_token:    @access_token,
        commands: [
          '' => {
            guid: 'GUID',
            name: 'pm.projects.update_project',
            params: {
              project_id:         id,
              name:               name,
              owner_id:           owner_id,
              points:             points,
              points_visible:     points_visible,
              calendar_color:     0,
              auto_milestone:     false,
              milestones_visible: false,
              time_logs_visible:  false
            }
          }
        ]
      }
    )
  end

  def add_project_member(user_id:, project_id:)
    RestClient.post(
      "#{SITE_URL}/commands.json",
      {
        access_token:    @access_token,
        commands: [
          '' => {
            guid: 'GUID',
            name: 'pm.project_members.add_user_to_project',
            params: {
              project_id: project_id,
              user_id:    user_id
            }
          }
        ]
      }
    )
  end

  def create_task(title:, project_id:)
    RestClient.post(
      "#{SITE_URL}/commands.json",
      {
        access_token:    @access_token,
        commands: [
          '' => {
            guid: 'GUID',
            name: 'pm.tasks.create_task',
            params: {
              project_id: project_id,
              title:      title
            }
          }
        ]
      }
    )
  end

  def change_task_points(task_id:, points:)
    RestClient.post(
      "#{SITE_URL}/commands.json",
      {
        access_token:    @access_token,
        commands: [
          '' => {
            guid: 'GUID',
            name: 'pm.tasks.change_points',
            params: {
              id:     task_id,
              points: points
            }
          }
        ]
      }
    )
  end

  def assign_user(task_id:, user_id:)
    RestClient.post(
      "#{SITE_URL}/commands.json",
      {
        access_token:    @access_token,
        commands: [
          '' => {
            guid: 'GUID',
            name: 'pm.tasks.change_main_assignees',
            params: {
              task_id:  task_id,
              user_ids: [user_id]
            }
          }
        ]
      }
    )
  end

  def change_task_stage(task_id:, stage_id:)
    RestClient.post(
      "#{SITE_URL}/commands.json",
      {
        access_token:    @access_token,
        commands: [
          '' => {
            guid: 'GUID',
            name: 'pm.tasks.change_stage',
            params: {
              task_id:  task_id,
              stage_id: stage_id
            }
          }
        ]
      }
    )
  end

  private
  
  def get_by_path(path, params = {})
    attrs = params

    if @access_token
      attrs = attrs.merge(access_token: @access_token)
    end
    
    data = RestClient.get("#{SITE_URL}#{path}", params: attrs)
    Oj.load(data)
  rescue => e
    puts e.inspect
    []
  end
end