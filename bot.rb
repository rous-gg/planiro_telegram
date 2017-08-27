TOKEN           = "447379304:AAFAlQ-_1ZqFy-uuKXD9SCXDsOl2ZL50CFw"
USERNAME        = "TheATeamBot"
BOT_NAME        = "gk-invent-hackathon"
ACCESS_TOKEN    = "kxnA72NyKVUZZzmLGUM1"
ORGANIZATION_ID = 2934
ADMIN_ID        = 4284

require 'bundler/setup'
require 'telegram/bot'
require 'byebug'

require_relative 'projects'
require_relative 'operation_detector'
require_relative 'list_project_query_handler'
require_relative 'list_flows_query_handler'

Telegram::Bot::Client.run(TOKEN, logger: Logger.new($stderr)) do |bot|
  operation_detector = OperationDetector.new

  bot.listen do |message|
    user_id = message.from.id

    case message.text
    when "/#{UserCommands::HELP.name}"
      HISTORY.add_user_command(user_id, UserCommands::HELP.name)
      HISTORY.add_system_message(user_id, SystemMessages::HELP.name)
    
      bot.api.send_message(
        chat_id: message.chat.id,
        text:    SystemMessages::HELP.text
      )
    when "/#{UserCommands::NEW_PROJECT.name}"
      HISTORY.add_user_command(user_id, UserCommands::NEW_PROJECT)
      HISTORY.add_system_message(user_id, SystemMessages::TYPE_PROJECT_NAME)
      
      bot.api.send_message(
        chat_id: message.chat.id,
        text:    SystemMessages::TYPE_PROJECT_NAME.text
      )
    when "/#{UserCommands::LIST_FLOWS.name}"
      HISTORY.add_user_command(user_id, UserCommands::LIST_FLOWS)
      HISTORY.add_system_message(user_id, SystemMessages::LIST_FLOWS)
    
      flows     = ListFlowsQueryHandler.new.list_flows(ACCESS_TOKEN)
      flows_str = flows.map.with_index {|fl, index| "#{index + 1}. #{fl['name']}"}.join("\n")

      bot.api.send_message(
        chat_id: message.chat.id,
        text:    SystemMessages::LIST_FLOWS.text % {flows: flows_str}
      )
    when "/#{UserCommands::LIST_PROJECTS.name}"
      HISTORY.add_user_command(user_id, UserCommands::LIST_PROJECTS)
      HISTORY.add_system_message(user_id, SystemMessages::LIST_PROJECTS)

      projects = ListProjectQueryHandler.new.list_projects(ACCESS_TOKEN)

      projects_str = if projects.size == 0
        SystemMessages::LIST_PROJECTS.empty_text
      else
        projects_str = projects.map {|pr| pr['name']}.join("\n")
        SystemMessages::LIST_PROJECTS.text % {projects: projects_str}
      end
      
      bot.api.send_message(
        chat_id: message.chat.id,
        text:    projects_str
      )
    else
      if operation_detector.waiting_for_type_project_name?(user_id)
        project_name = message.text

        HISTORY.add_system_message(user_id, SystemMessages::PROJECT_CREATED)
        CreateProjectHandler.new.handle(user_id: user_id, name: project_name)
    

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::PROJECT_CREATED.text % {project_name: project_name}
        )
      end
    end
  end
end