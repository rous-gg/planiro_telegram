require_relative 'user_commands'

module SystemMessages
  HELP = OpenStruct.new({
    name: :help,
    text: UserCommands::ALL.map { |c| "/#{c.name} #{c.text}" }.join("\n")
  })

  TYPE_PROJECT_NAME = OpenStruct.new({
    name: :help,
    text: "Type project name:"
  })

  LIST_FLOWS = OpenStruct.new({
    name: :list_flows,
    text: "List of available flows:\n%{flows}"
  })

  LIST_PROJECTS = OpenStruct.new({
    name:       :list_projects,
    text:       "List of available projects:\n%{projects}",
    empty_text: "No projects found. Use /#{UserCommands::NEW_PROJECT.name} command to create new project"
  })

  PROJECT_CREATED = OpenStruct.new({
    name:       :project_created,
    text:       "Project \"%{project_name}\ was created"
  })

  ALL = [HELP, TYPE_PROJECT_NAME, LIST_FLOWS, LIST_PROJECTS]

  class << self
    def get(name)
      ALL.detect {|c| c.name == name}
    end
  end
end