require 'ostruct'
require_relative 'user_commands'

module SystemMessages
  ALL = []

  class << self
    def register_message(data)
      message = OpenStruct.new(data)
      const_set(data[:name].to_s.upcase, message)
      ALL << message
    end
  end

  register_message(
    name: :help,
    text: UserCommands::ALL.map { |c| "/#{c.name} #{c.text}" }.join("\n")
  )

  register_message(
    name: :type_project_name,
    text: "Type project name:"
  )

  register_message(
    name: :type_task_title,
    text: "Type task title:"
  )

  register_message(
    name:       :task_created,
    text:       "Task was added to %{project}"
  )

  register_message(
    name: :select_task,
    text: "Select task number:\n%{tasks}"
  )

  register_message(
    name: :task_award_set,
    text: "Task award was set to %{amount}"
  )

  register_message(
    name: :task_accepted,
    text: "Task %{task} was accepted and user %{user} was awarded with %{amount}",
    empty_text: "Task %{task} was accepted",
  )

  register_message(
    name: :enter_award,
    text: "Enter award amount (1-10):"
  )

  register_message(
    name: :select_project,
    text: "Type project number:\n%{projects}"
  )

  register_message(
    name: :select_user,
    text: "Type user number:\n%{users}"
  )

  register_message(
    name: :select_flow,
    text: "Type flow number:\n%{flows}"
  )

  register_message(
    name: :select_project_manager,
    text: "Type project manager number:\n%{users}"
  )

  register_message(
    name: :list_flows,
    text: "List of available flows:\n%{flows}"
  )

  register_message(
    name:       :list_projects,
    text:       "List of available projects:\n%{projects}",
    empty_text: "No projects found. Use /#{UserCommands::NEW_PROJECT.name} command to create new project"
  )

  register_message(
    name:       :project_created,
    text:       "Project \"%{project_name}\ was created"
  )

  register_message(
    name:       :project_member_added,
    text:       "User %{user} was added to %{project}"
  )

  register_message(
    name:       :user_assigned,
    text:       "User %{user} was assigned to task: %{task}"
  )

  register_message(
    name:       :unknown_input,
    text:       "Unknown input. Type command first or use /help to get list of available commands"
  )

  class << self
    def get(name)
      ALL.detect {|c| c.name == name}
    end
  end
end
