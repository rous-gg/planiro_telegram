require 'ostruct'

class History
  attr_reader :history

  ACTION_COUNT   = 20
  USER_REPLY     = :user_reply
  USER_COMMAND   = :user_command
  SYSTEM_MESSAGE = :system_message

  def initialize
    @history = Hash.new([])
    @id_seq  = 0
  end

  def add_user_reply(user_id, message)
    puts "***** User reply: user_id=#{user_id}, message=#{message} *****"
    @history[user_id] << OpenStruct.new({id: get_id, type: USER_REPLY, message: message})
    clear_history(user_id)
  end

  def add_user_command(user_id, command)
    puts "***** User command: user_id=#{user_id}, command=#{command.name} *****"
    @history[user_id] << OpenStruct.new({id: get_id, type: USER_COMMAND, command: command})
    clear_history(user_id)
  end

  def add_system_message(user_id, message, extra = nil)
    puts "***** System message: user_id=#{user_id}, message=#{message.name} *****"
    @history[user_id] << OpenStruct.new({id: get_id, type: SYSTEM_MESSAGE, message: message, extra: extra})
    clear_history(user_id)
  end

  def system_messages(user_id)
    @history[user_id].select {|command| command.type == SYSTEM_MESSAGE}
  end

  def user_replies(user_id)
    @history[user_id].select {|command| command.type == USER_REPLY}
  end

  def user_commands(user_id)
    @history[user_id].select {|command| command.type == USER_COMMAND}
  end

  def last_action(user_id)
    @history[user_id].last
  end

  def prev_action(user_id)
    @history[user_id][-2]
  end

  def last_command_replies(user_id)
    actions = []
    
    @history[user_id].reverse.each do |action|
      actions << action
      break if action.type == USER_COMMAND
    end

    result = {}
    actions.reverse!

    actions.each_with_index do |action, index|
      next if action.type == USER_REPLY
      next_action = actions[index + 1]
      break if !next_action

      if next_action.type == USER_COMMAND || next_action.type == SYSTEM_MESSAGE
        if action.type == USER_COMMAND
          result[action.command] = OpenStruct.new({
            message: nil
          })
        else
          result[action.message] = OpenStruct.new({
            message: nil,
            extra:   nil
          })
        end
      else
        if action.type == USER_COMMAND
          result[action.command] = OpenStruct.new({
            message: next_action ? next_action.message : nil
          })
        elsif action.type == SYSTEM_MESSAGE
          result[action.message] = OpenStruct.new({
            message: actions[index + 1].message,
            extra:   action.extra
          })
        end
      end
    end

    result
  end

  def clear_history(user_id)
    if @history[user_id].size > ACTION_COUNT
      @history[user_id].shift
    end
  end

  private

  def get_id
    @id_seq += 1
    @id_seq
  end
end