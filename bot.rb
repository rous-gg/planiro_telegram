TOKEN           = "447379304:AAFAlQ-_1ZqFy-uuKXD9SCXDsOl2ZL50CFw"
USERNAME        = "TheATeamBot"
BOT_NAME        = "gk-invent-hackathon"
ACCESS_TOKEN    = "kxnA72NyKVUZZzmLGUM1"
ORGANIZATION_ID = 2934
ADMIN_ID        = 4284

require 'bundler/setup'
require 'telegram/bot'
require 'byebug'

require_relative 'new_project_operations'
require_relative 'add_project_member_operations'
require_relative 'list_project_query_handler'
require_relative 'list_flows_query_handler'
require_relative 'list_users_query_handler'
require_relative 'create_project_handler'
require_relative 'add_project_member_handler'

HISTORY         = History.new

# , logger: Logger.new($stderr)
Telegram::Bot::Client.run(TOKEN) do |bot|
  new_project_operations        = NewProjectOperations.new
  add_project_member_operations = AddProjectMemberOperations.new

  bot.listen do |message|
    user_id = message.from.id

    case message.text
    when "/#{UserCommands::HELP.name}"
      HISTORY.add_user_command(user_id, UserCommands::HELP)
      HISTORY.add_system_message(user_id, SystemMessages::HELP)
    
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
    when "/#{UserCommands::ADD_PROJECT_MEMBER.name}"
      HISTORY.add_user_command(user_id, UserCommands::ADD_PROJECT_MEMBER)
      
      projects     = ListProjectQueryHandler.new.list_projects(ACCESS_TOKEN)
      projects_str = projects.map.with_index {|pr, index| "#{index + 1}. #{pr['name']}"}.join("\n")
      project_ids  = projects.map {|pr| pr['id']}

      HISTORY.add_system_message(user_id, SystemMessages::SELECT_PROJECT, projects)

      bot.api.send_message(
        chat_id: message.chat.id,
        text:    SystemMessages::SELECT_PROJECT.text % {projects: projects_str}
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
        projects_str = projects.map.with_index {|pr, index| "#{index + 1}. #{pr['name']}"}.join("\n")
        SystemMessages::LIST_PROJECTS.text % {projects: projects_str}
      end
      
      bot.api.send_message(
        chat_id: message.chat.id,
        text:    projects_str
      )
    else
      # CREATE PROJECT OPERATION
      if new_project_operations.waiting_for_type_project_name?(user_id)
        HISTORY.add_user_reply(user_id, message.text)
        
        flows     = ListFlowsQueryHandler.new.list_flows(ACCESS_TOKEN)
        flows_str = flows.map.with_index {|fl, index| "#{index + 1}. #{fl['name']}"}.join("\n")
        flow_ids  = flows.map {|fl| fl['id']}

        HISTORY.add_system_message(user_id, SystemMessages::SELECT_FLOW, flow_ids)
        
        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::SELECT_FLOW.text % {flows: flows_str}
        )
      elsif new_project_operations.waiting_for_select_flow?(user_id)
        HISTORY.add_user_reply(user_id, message.text)
        
        users     = ListUsersQueryHandler.new.list_active_organization_users(ACCESS_TOKEN)
        users_str = users.map.with_index {|user, index| "#{index + 1}. #{user['name']}"}.join("\n")
        user_ids  = users.map {|user| user['id']}
        
        HISTORY.add_system_message(user_id, SystemMessages::SELECT_PROJECT_MANAGER, user_ids)
        
        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::SELECT_PROJECT_MANAGER.text % {users: users_str}
        )
      elsif new_project_operations.can_create_project?(user_id)
        HISTORY.add_user_reply(user_id, message.text)
        HISTORY.add_system_message(user_id, SystemMessages::PROJECT_CREATED)

        last_command_replies = HISTORY.last_command_replies(user_id)
        project_name         = last_command_replies[SystemMessages::TYPE_PROJECT_NAME].message
        flow_number          = last_command_replies[SystemMessages::SELECT_FLOW].message.to_i
        flow_id              = last_command_replies[SystemMessages::SELECT_FLOW].extra[flow_number - 1]
        owner_number         = last_command_replies[SystemMessages::SELECT_PROJECT_MANAGER].message.to_i
        owner_id             = last_command_replies[SystemMessages::SELECT_PROJECT_MANAGER].extra[owner_number - 1]

        project = CreateProjectHandler.new(ACCESS_TOKEN).create(
          name:            project_name,
          organization_id: OrganizationQueryHandler.new.get_organization_id(ACCESS_TOKEN),
          flow_id:         flow_id,
          owner_id:        owner_id
        )

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::PROJECT_CREATED.text % {project_name: project.url}
        )
      # ADD PROJECT MEMBER OPERATION
      elsif add_project_member_operations.waiting_for_select_project?(user_id)
        HISTORY.add_user_reply(user_id, message.text)

        users     = ListUsersQueryHandler.new.list_active_organization_users(ACCESS_TOKEN)
        users_str = users.map.with_index {|user, index| "#{index + 1}. #{user['name']}"}.join("\n")

        HISTORY.add_system_message(user_id, SystemMessages::SELECT_USER, users)

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::SELECT_USER.text % {users: users_str}
        )
      elsif add_project_member_operations.waiting_for_select_user?(user_id)
        HISTORY.add_user_reply(user_id, message.text)
        
        last_command_replies = HISTORY.last_command_replies(user_id)
        project_number       = last_command_replies[SystemMessages::SELECT_PROJECT].message.to_i
        project              = last_command_replies[SystemMessages::SELECT_PROJECT].extra[project_number - 1]
        user_number          = last_command_replies[SystemMessages::SELECT_USER].message.to_i
        user                 = last_command_replies[SystemMessages::SELECT_USER].extra[user_number - 1]
        
        HISTORY.add_system_message(user_id, SystemMessages::PROJECT_MEMBER_ADDED)
        
        AddProjectMemberHandler.new(ACCESS_TOKEN).create(
          user_id:    user['id'],
          project_id: project['id']
        )

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::PROJECT_MEMBER_ADDED.text % {user: user['name'], project: project['name']}
        )
      else
        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::UNKNOWN_INPUT.text
        )
      end
    end
  end
end