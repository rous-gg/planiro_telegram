require_relative 'user_commands'
require_relative 'system_messages'
require_relative 'history'

class AssignUserOperations
  def waiting_for_select_project?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::ASSIGN_USER) && 
      last_command_replies.keys.size == 1
  end

  def waiting_for_select_task?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::ASSIGN_USER) && 
      last_command_replies.has_key?(SystemMessages::SELECT_PROJECT) &&
      last_command_replies.keys.size == 2
  end

  def can_assign_user?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::ASSIGN_USER) && 
      last_command_replies.has_key?(SystemMessages::SELECT_PROJECT) &&
      last_command_replies.has_key?(SystemMessages::SELECT_TASK) &&
      last_command_replies.keys.size == 3
  end
end