require_relative 'user_commands'
require_relative 'system_messages'
require_relative 'history'

class SetTaskAwardOperations
  def waiting_for_select_project?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::SET_TASK_AWARD) && 
      last_command_replies.keys.size == 1
  end

  def waiting_for_select_task?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::SET_TASK_AWARD) && 
      last_command_replies.has_key?(SystemMessages::SELECT_PROJECT) &&
      last_command_replies.keys.size == 2
  end

  def can_set_award?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::SET_TASK_AWARD) && 
      last_command_replies.has_key?(SystemMessages::SELECT_PROJECT) &&
      last_command_replies.has_key?(SystemMessages::SELECT_TASK) &&
      last_command_replies.keys.size == 3
  end
end