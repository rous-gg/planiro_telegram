require_relative 'user_commands'
require_relative 'system_messages'
require_relative 'history'

class TaskOperations
  def waiting_for_type_task_tite?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::NEW_TASK) && 
      last_command_replies.keys.size == 1
  end

  def can_create_task?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::NEW_TASK) && 
      last_command_replies.has_key?(SystemMessages::TYPE_TASK_TITLE) &&
      last_command_replies.keys.size == 2
  end
end