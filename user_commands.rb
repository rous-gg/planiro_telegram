require 'ostruct'

module UserCommands
  HELP = OpenStruct.new({
    name: :help,
    text: "Returns information about all available commands"
  })

  NEW_PROJECT = OpenStruct.new({
    name: :new_project,
    text: "Creates new project. Ex: /new_project YOUR_PROJECT_NAME"
  })

  LIST_PROJECTS = OpenStruct.new({
    name: :list_projects,
    text: "Lists all available projects."
  })

  LIST_FLOWS = OpenStruct.new({
    name: :list_flows,
    text: "Lists all organization stage flows."
  })

  ALL = [
    HELP, NEW_PROJECT, LIST_PROJECTS, LIST_FLOWS
  ]

  class << self
    def get(name)
      ALL.detect {|c| c.name == name}
    end
  end
end