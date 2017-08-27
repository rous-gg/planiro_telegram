require_relative 'user_commands'
require_relative 'system_messages'
require_relative 'history'

class OperationDetector
  def waiting_for_type_project_name?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::NEW_PROJECT) && 
      last_command_replies.size == 1
  end

  def waiting_for_type_select_flow?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::NEW_PROJECT) && 
      last_command_replies.has_key?(SystemMessages::TYPE_PROJECT_NAME) &&
      last_command_replies.size == 2
  end

  def can_create_project?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::NEW_PROJECT) &&
      last_command_replies.has_key?(SystemMessages::TYPE_PROJECT_NAME) &&
      last_command_replies.has_key?(SystemMessages::SELECT_FLOW) && 
      last_command_replies.size == 3
  end
end