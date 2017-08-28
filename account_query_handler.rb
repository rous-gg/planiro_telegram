require_relative 'organization_query_handler'

class AccountQueryHandler
  def api_token(email, password)
    PlaniroAPI.new(nil).get_api_token(email, password)
  end
  def my_account_id(access_token)

    account_data(access_token)['current_user']['id']
  end

  def account_data(access_token)
    api = PlaniroAPI.new(access_token)
    api.get_account_data
  end
end
