require_relative 'user_commands'
require_relative 'system_messages'
require_relative 'history'

class AcceptTaskOperations
  def waiting_for_select_project?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::ACCEPT_TASK) && 
      last_command_replies.keys.size == 1
  end

  def can_accept_task?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::ACCEPT_TASK) && 
      last_command_replies.has_key?(SystemMessages::SELECT_PROJECT) &&
      last_command_replies.keys.size == 2
  end
end