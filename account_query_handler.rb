require_relative 'organization_query_handler'

class AccountQueryHandler
  def api_token(email, password)
    PlaniroAPI.new(nil).get_api_token(email, password)
  end
end
