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

  class << self
    def get(name)
      ALL.detect {|c| c.name == name}
    end
  end
end