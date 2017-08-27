require_relative 'user_commands'
require_relative 'system_messages'
require_relative 'history'

class OperationDetector
  def waiting_for_type_project_name?(user_id)
    action = HISTORY.prev_action(user_id)
    return false if !action

    action.type == History::SYSTEM_MESSAGE && action.message == SystemMessages::TYPE_PROJECT_NAME_MESSAGE
  end
end