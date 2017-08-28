require_relative 'user_commands'
require_relative 'system_messages'
require_relative 'history'

class JoinOperations
  def waiting_for_enter_email?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::JOIN) && 
      last_command_replies.keys.size == 1
  end

  def can_join?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::JOIN) && 
      last_command_replies.has_key?(SystemMessages::ENTER_EMAIL) &&
      last_command_replies.keys.size == 2
  end
end