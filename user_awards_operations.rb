require_relative 'user_commands'
require_relative 'system_messages'
require_relative 'history'

class UserAwardsOperations
  def can_return_awards?(user_id)
    last_command_replies = HISTORY.last_command_replies(user_id)

    last_command_replies.has_key?(UserCommands::USER_AWARDS) && 
      last_command_replies.keys.size == 1
  end
end