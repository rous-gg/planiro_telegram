require 'ostruct'

class History
  COMMAND_COUNT  = 20
  USER_MESSAGE   = :user_message
  USER_COMMAND   = :user_command
  SYSTEM_MESSAGE = :system_message

  def initialize
    @history = Hash.new([])
  end

  def add_user_message(user_id, message)
    puts "User message: user_id=#{user_id}, message=#{message}"
    @history[user_id] << OpenStruct.new({type: USER_MESSAGE, message: message})
    clear_history(user_id)
  end

  def add_user_command(user_id, command)
    puts "User command: user_id=#{user_id}, command=#{command}"
    @history[user_id] << OpenStruct.new({type: USER_COMMAND, command: command})
    clear_history(user_id)
  end

  def add_system_message(user_id, message)
    puts "System message: user_id=#{user_id}, message=#{message}"
    @history[user_id] << OpenStruct.new({type: SYSTEM_MESSAGE, message: message})
    clear_history(user_id)
  end

  def system_messages(user_id)
    @history[user_id].select {|command| command.type == SYSTEM_MESSAGE}
  end

  def user_messages(user_id)
    @history[user_id].select {|command| command.type == USER_MESSAGE}
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

  private

  def clear_history(user_id)
    if @history[user_id].size > COMMAND_COUNT
      @history[user_id].shift
    end
  end
end

HISTORY = History.new
