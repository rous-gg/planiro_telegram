require 'ostruct'

module UserCommands
  ALL = []

  class << self
    def register_command(data)
      command = OpenStruct.new(data)
      const_set(data[:name].to_s.upcase, command)
      ALL << command
    end
  end

  register_command(
    name: :join,
    text: "Allows user to start interacting with bot. Access token will be asked. Can be received from "
  )

  register_command(
    name: :logout,
    text: "Logout from channel"
  )

  register_command(
    name: :help,
    text: "Returns information about all available commands"
  )

  register_command(
    name: :new_project,
    text: "Creates new project. Ex: /new_project YOUR_PROJECT_NAME"
  )

  register_command(
    name: :list_projects,
    text: "Lists all available projects."
  )

  register_command(
    name: :list_flows,
    text: "Lists all organization stage flows."
  )

  register_command(
    name: :add_project_member,
    text: "Adds active organization user to project."
  )

  register_command(
    name: :new_task,
    text: "Creates new project task"
  )

  register_command(
    name: :set_task_award,
    text: "Sets task award"
  )

  register_command(
    name: :assign_user,
    text: "Assigns project member to specific task"
  )

  register_command(
    name: :accept_task,
    text: "Accepts specific project task"
  )

  register_command(
    name: :user_awards,
    text: "Returns total user awards"
  )

  class << self
    def get(name)
      ALL.detect {|c| c.name == name}
    end
  end
end