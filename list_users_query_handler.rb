require_relative 'planiro_api'

class ListUsersQueryHandler
  def list_active_organization_users(access_token)
    api = PlaniroAPI.new(access_token)
    data = api.get_account_data
    organization = data['organizations'].detect {|org| org['type'] == 'regular'}

    user_ids = organization['organization_users'].inject([]) do |result, user_data|
      if user_data.last['status'] == 'active'
        result.push(user_data.first.to_i)
      end

      result
    end

    users = data['users'].select {|user| user_ids.include?(user['id'])}

    users.each do |user|
      user['name'] = user['localized_names']['ru'] || user['localized_names']['en']
    end

    users
  end

  def list_active_project_users(access_token, project_id)
    api = PlaniroAPI.new(access_token)
    data = api.get_account_data
    
    project_user_ids = api.get_project(project_id)['user_ids']

    users = data['users'].select {|user| project_user_ids.include?(user['id'])}

    users.each do |user|
      user['name'] = user['localized_names']['ru'] || user['localized_names']['en']
    end

    users
  end
end
