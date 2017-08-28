TOKEN           = "447379304:AAFAlQ-_1ZqFy-uuKXD9SCXDsOl2ZL50CFw"
USERNAME        = "TheATeamBot"
BOT_NAME        = "gk-invent-hackathon"

require 'bundler/setup'
require 'telegram/bot'
require 'byebug'

require_relative 'new_project_operations'
require_relative 'add_project_member_operations'
require_relative 'task_operations'
require_relative 'assign_user_operations'
require_relative 'set_task_award_operations'
require_relative 'accept_task_operations'
require_relative 'user_awards_operations'
require_relative 'join_operations'
require_relative 'list_project_query_handler'
require_relative 'list_flows_query_handler'
require_relative 'list_users_query_handler'
require_relative 'list_project_tasks_query_handler'
require_relative 'create_project_handler'
require_relative 'add_project_member_handler'
require_relative 'set_task_award_handler'
require_relative 'set_task_award_handler'
require_relative 'create_task_handler'
require_relative 'accept_task_handler'
require_relative 'assign_task_user_handler'
require_relative 'account_query_handler'
require_relative 'ethereum'

HISTORY         = History.new

# , logger: Logger.new($stderr)
Telegram::Bot::Client.run(TOKEN) do |bot|
  new_project_operations        = NewProjectOperations.new
  add_project_member_operations = AddProjectMemberOperations.new
  task_operations               = TaskOperations.new
  set_task_award_operations     = SetTaskAwardOperations.new
  assign_user_operations        = AssignUserOperations.new
  accept_task_operations        = AcceptTaskOperations.new
  user_awards_operations        = UserAwardsOperations.new
  join_operations               = JoinOperations.new
  users_auth_file_path          = File.join(__dir__, 'users_auth.json')

  users_auth = if File.exists?(users_auth_file_path)
    Oj.load(File.read(users_auth_file_path))
  else
    {}
  end

  invalid_proc = Proc.new do |user_id, bot, chat_id|
    bot.api.send_message(
      chat_id: chat_id,
      text:    SystemMessages::INVALID_INPUT.text
    )

    HISTORY.clear_history(user_id)
  end

  bot.listen do |message|
    user_id      = message.from.id
    user_auth    = users_auth[user_id]

    if user_auth
      access_token = user_auth['token']
    end

    if !user_auth
      case message.text
      when "/#{UserCommands::JOIN.name}"
        HISTORY.add_user_command(user_id, UserCommands::JOIN)
        HISTORY.add_system_message(user_id, SystemMessages::ENTER_EMAIL)

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::ENTER_EMAIL.text
        )
      else
        if join_operations.waiting_for_enter_email?(user_id)
          HISTORY.add_user_reply(user_id, message.text)
          HISTORY.add_system_message(user_id, SystemMessages::ENTER_PASSWORD)
          
          bot.api.send_message(
            chat_id: message.chat.id,
            text:    SystemMessages::ENTER_PASSWORD.text
          )
        elsif join_operations.can_join?(user_id)
          HISTORY.add_user_reply(user_id, message.text)

          last_command_replies = HISTORY.last_command_replies(user_id)
          email                = last_command_replies[SystemMessages::ENTER_EMAIL].message.strip.downcase
          password             = last_command_replies[SystemMessages::ENTER_PASSWORD].message.strip

          token = AccountQueryHandler.new.api_token(email, password)

          if token == []
            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::INVALID_EMAIL_OR_PASSWORD.text
            )
          else
            access_token = token
            account_id = AccountQueryHandler.new.my_account_id(access_token)

            users_auth[user_id] = {
              'token'      => token,
              'planiro_id' => account_id,
              'chat_id'    => message.chat.id
            }

            File.write(users_auth_file_path, Oj.dump(users_auth))

            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::JOIN_SUCCESSFULL.text
            )
          end
        else
          bot.api.send_message(
            chat_id: message.chat.id,
            text:    SystemMessages::JOIN_REQUIRED.text
          )
        end
      end
    else
      case message.text
      when "/#{UserCommands::LOGOUT.name}"
        HISTORY.add_user_command(user_id, UserCommands::LOGOUT)

        users_auth.delete(user_id)
        File.write(users_auth_file_path, Oj.dump(users_auth))

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::LOGGED_OUT.text
        )
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
      when "/#{UserCommands::NEW_TASK.name}"
        HISTORY.add_user_command(user_id, UserCommands::NEW_TASK)
        HISTORY.add_system_message(user_id, SystemMessages::TYPE_TASK_TITLE)
        
        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::TYPE_TASK_TITLE.text
        )
      when "/#{UserCommands::ADD_PROJECT_MEMBER.name}"
        HISTORY.add_user_command(user_id, UserCommands::ADD_PROJECT_MEMBER)
        
        projects     = ListProjectQueryHandler.new.list_projects(access_token)
        projects_str = projects.map.with_index {|pr, index| "#{index + 1}. #{pr['name']}"}.join("\n")

        HISTORY.add_system_message(user_id, SystemMessages::SELECT_PROJECT, projects)

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::SELECT_PROJECT.text % {projects: projects_str}
        )
      when "/#{UserCommands::ASSIGN_USER.name}"
        HISTORY.add_user_command(user_id, UserCommands::ASSIGN_USER)
        
        projects     = ListProjectQueryHandler.new.list_projects(access_token)
        projects_str = projects.map.with_index {|pr, index| "#{index + 1}. #{pr['name']}"}.join("\n")

        HISTORY.add_system_message(user_id, SystemMessages::SELECT_PROJECT, projects)

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::SELECT_PROJECT.text % {projects: projects_str}
        )
      when "/#{UserCommands::ACCEPT_TASK.name}"
        HISTORY.add_user_command(user_id, UserCommands::ACCEPT_TASK)
        
        projects     = ListProjectQueryHandler.new.list_projects(access_token)
        projects_str = projects.map.with_index {|pr, index| "#{index + 1}. #{pr['name']}"}.join("\n")

        HISTORY.add_system_message(user_id, SystemMessages::SELECT_PROJECT, projects)

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::SELECT_PROJECT.text % {projects: projects_str}
        )
      when "/#{UserCommands::SET_TASK_AWARD.name}"
        HISTORY.add_user_command(user_id, UserCommands::SET_TASK_AWARD)
        
        projects     = ListProjectQueryHandler.new.list_projects(access_token)
        projects_str = projects.map.with_index {|pr, index| "#{index + 1}. #{pr['name']}"}.join("\n")

        HISTORY.add_system_message(user_id, SystemMessages::SELECT_PROJECT, projects)

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::SELECT_PROJECT.text % {projects: projects_str}
        )
      when "/#{UserCommands::LIST_FLOWS.name}"
        HISTORY.add_user_command(user_id, UserCommands::LIST_FLOWS)
        HISTORY.add_system_message(user_id, SystemMessages::LIST_FLOWS)
      
        flows     = ListFlowsQueryHandler.new.list_flows(access_token)
        flows_str = flows.map.with_index {|fl, index| "#{index + 1}. #{fl['name']}"}.join("\n")

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::LIST_FLOWS.text % {flows: flows_str}
        )
      when "/#{UserCommands::USER_AWARDS.name}"
        HISTORY.add_user_command(user_id, UserCommands::USER_AWARDS)

        users     = ListUsersQueryHandler.new.list_active_organization_users(access_token)
        users_str = users.map.with_index {|user, index| "#{index + 1}. #{user['name']}"}.join("\n")

        HISTORY.add_system_message(user_id, SystemMessages::SELECT_USER, users)

        bot.api.send_message(
          chat_id: message.chat.id,
          text:    SystemMessages::SELECT_PROJECT_MANAGER.text % {users: users_str}
        )
      when "/#{UserCommands::LIST_PROJECTS.name}"
        HISTORY.add_user_command(user_id, UserCommands::LIST_PROJECTS)
        HISTORY.add_system_message(user_id, SystemMessages::LIST_PROJECTS)

        projects = ListProjectQueryHandler.new.list_projects(access_token)

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
          
          flows     = ListFlowsQueryHandler.new.list_flows(access_token)
          flows_str = flows.map.with_index {|fl, index| "#{index + 1}. #{fl['name']}"}.join("\n")
          flow_ids  = flows.map {|fl| fl['id']}

          HISTORY.add_system_message(user_id, SystemMessages::SELECT_FLOW, flow_ids)
          
          bot.api.send_message(
            chat_id: message.chat.id,
            text:    SystemMessages::SELECT_FLOW.text % {flows: flows_str}
          )
        elsif new_project_operations.waiting_for_select_flow?(user_id)
          HISTORY.add_user_reply(user_id, message.text)
          
          users     = ListUsersQueryHandler.new.list_active_organization_users(access_token)
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

          if flow_id && owner_id
            project = CreateProjectHandler.new(access_token, ORG_CONTRACT).create(
              name:            project_name,
              organization_id: OrganizationQueryHandler.new.get_organization_id(access_token),
              flow_id:         flow_id,
              owner_id:        owner_id
            )

            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::PROJECT_CREATED.text % {project_name: project.url}
            )
          else
            invalid_proc.call(user_id, bot, message.chat.id)
          end
        # CREATE TASK OPERATION
        elsif task_operations.waiting_for_type_task_tite?(user_id)
          HISTORY.add_user_reply(user_id, message.text)

          projects     = ListProjectQueryHandler.new.list_projects(access_token)
          projects_str = projects.map.with_index {|pr, index| "#{index + 1}. #{pr['name']}"}.join("\n")

          HISTORY.add_system_message(user_id, SystemMessages::SELECT_PROJECT, projects)
    
          bot.api.send_message(
            chat_id: message.chat.id,
            text:    SystemMessages::SELECT_PROJECT.text % {projects: projects_str}
          )
        elsif task_operations.can_create_task?(user_id)
          HISTORY.add_user_reply(user_id, message.text)
          
          last_command_replies = HISTORY.last_command_replies(user_id)
          task_title           = last_command_replies[SystemMessages::TYPE_TASK_TITLE].message
          project_number       = last_command_replies[SystemMessages::SELECT_PROJECT].message.to_i
          project              = last_command_replies[SystemMessages::SELECT_PROJECT].extra[project_number - 1]

          if project
            HISTORY.add_system_message(user_id, SystemMessages::PROJECT_CREATED)

            CreateTaskHandler.new(access_token, ORG_CONTRACT).create(
              title:      task_title,
              project_id: project['id']
            )

            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::TASK_CREATED.text % {project: project['name']}
            )
          else
            invalid_proc.call(user_id, bot, message.chat.id)
          end
        # ADD PROJECT MEMBER OPERATION
        elsif add_project_member_operations.waiting_for_select_project?(user_id)
          HISTORY.add_user_reply(user_id, message.text)

          users     = ListUsersQueryHandler.new.list_active_organization_users(access_token)
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
          
          if project && user
            HISTORY.add_system_message(user_id, SystemMessages::PROJECT_MEMBER_ADDED)
            
            AddProjectMemberHandler.new(access_token, ORG_CONTRACT).create(
              user_id:    user['id'],
              project_id: project['id']
            )

            users_auth.each do |u_id, u_data|
              if u_data['planiro_id'] == user['id']

                actor = ListUsersQueryHandler.new.user_by_id(access_token, u_data['planiro_id'])

                bot.api.send_message(
                  chat_id: u_data['chat_id'],
                  text:    SystemMessages::ADDED_TO_PROJECT.text % {actor: actor['name'], project: project['name']}
                )

                break
              end
            end
            
            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::PROJECT_MEMBER_ADDED.text % {user: user['name'], project: project['name']}
            )
          else
            invalid_proc.call(user_id, bot, message.chat.id)
          end
        # SET TASK AWARD OPERATION
        elsif set_task_award_operations.waiting_for_select_project?(user_id)
          HISTORY.add_user_reply(user_id, message.text)

          last_command_replies = HISTORY.last_command_replies(user_id)
          project_number       = last_command_replies[SystemMessages::SELECT_PROJECT].message.to_i
          project              = last_command_replies[SystemMessages::SELECT_PROJECT].extra[project_number - 1]

          if project
            tasks                = ListProjectTasksQueryHandler.new(access_token).list_project_tasks(project['id'])
            tasks_str            = tasks.map.with_index {|task, index| "#{index + 1}. #{task['title']}"}.join("\n")

            HISTORY.add_system_message(user_id, SystemMessages::SELECT_TASK, tasks)

            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::SELECT_TASK.text % {tasks: tasks_str}
            )
          else
            invalid_proc.call(user_id, bot, message.chat.id)
          end
        elsif set_task_award_operations.waiting_for_select_task?(user_id)
          HISTORY.add_user_reply(user_id, message.text)
          HISTORY.add_system_message(user_id, SystemMessages::ENTER_AWARD)

          bot.api.send_message(
            chat_id: message.chat.id,
            text:    SystemMessages::ENTER_AWARD.text
          )
        elsif set_task_award_operations.can_set_award?(user_id)
          HISTORY.add_user_reply(user_id, message.text)

          last_command_replies = HISTORY.last_command_replies(user_id)
          task_number          = last_command_replies[SystemMessages::SELECT_TASK].message.to_i
          task                 = last_command_replies[SystemMessages::SELECT_TASK].extra[task_number - 1]
          award                = last_command_replies[SystemMessages::ENTER_AWARD].message.to_s.to_i

          if task
            SetTaskAwardHandler.new(access_token, ORG_CONTRACT).set_award(task_id: task['id'], award: award)
            HISTORY.add_system_message(user_id, SystemMessages::TASK_AWARD_SET, tasks)

            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::TASK_AWARD_SET.text % {amount: award}
            )
          else
            invalid_proc.call(user_id, bot, message.chat.id)
          end
        # ASSIGN USER TO TASK
        elsif assign_user_operations.waiting_for_select_project?(user_id)
          HISTORY.add_user_reply(user_id, message.text)

          last_command_replies = HISTORY.last_command_replies(user_id)
          project_number       = last_command_replies[SystemMessages::SELECT_PROJECT].message.to_i
          project              = last_command_replies[SystemMessages::SELECT_PROJECT].extra[project_number - 1]
          
          if project
            tasks                = ListProjectTasksQueryHandler.new(access_token).list_project_tasks(project['id'])
            tasks_str            = tasks.map.with_index {|task, index| "#{index + 1}. #{task['title']}"}.join("\n")

            HISTORY.add_system_message(user_id, SystemMessages::SELECT_TASK, tasks)

            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::SELECT_TASK.text % {tasks: tasks_str}
            )
          else
            invalid_proc.call(user_id, bot, message.chat.id)
          end
        elsif assign_user_operations.waiting_for_select_task?(user_id)
          HISTORY.add_user_reply(user_id, message.text)

          last_command_replies = HISTORY.last_command_replies(user_id)
          project_number = last_command_replies[SystemMessages::SELECT_PROJECT].message.to_i
          project        = last_command_replies[SystemMessages::SELECT_PROJECT].extra[project_number - 1]

          if project
            users          = ListUsersQueryHandler.new.list_active_project_users(access_token, project['id'])
            users_str      = users.map.with_index {|user, index| "#{index + 1}. #{user['name']}"}.join("\n")

            HISTORY.add_system_message(user_id, SystemMessages::SELECT_USER, users)

            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::SELECT_USER.text % {users: users_str}
            )
          else
            invalid_proc.call(user_id, bot, message.chat.id)
          end
        elsif assign_user_operations.can_assign_user?(user_id)
          HISTORY.add_user_reply(user_id, message.text)

          last_command_replies = HISTORY.last_command_replies(user_id)
          task_number          = last_command_replies[SystemMessages::SELECT_TASK].message.to_i
          task                 = last_command_replies[SystemMessages::SELECT_TASK].extra[task_number - 1]
          user_number          = last_command_replies[SystemMessages::SELECT_USER].message.to_s.to_i
          user                 = last_command_replies[SystemMessages::SELECT_USER].extra[user_number - 1]

          if task && user
            AssignTaskUserHandler.new(access_token, ORG_CONTRACT).assign_user(task_id: task['id'], user_id: user['id'])
            HISTORY.add_system_message(user_id, SystemMessages::USER_ASSIGNED)

            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::USER_ASSIGNED.text % {user: user['name'], task: task['title']}
            )
          else
            invalid_proc.call(user_id, bot, message.chat.id)
          end
        # ACCEPT TASK OPERATION
        elsif accept_task_operations.waiting_for_select_project?(user_id)
          HISTORY.add_user_reply(user_id, message.text)

          last_command_replies = HISTORY.last_command_replies(user_id)
          project_number       = last_command_replies[SystemMessages::SELECT_PROJECT].message.to_i
          project              = last_command_replies[SystemMessages::SELECT_PROJECT].extra[project_number - 1]

          if project
            tasks                = ListProjectTasksQueryHandler.new(access_token).list_project_tasks(project['id'])
            tasks_str            = tasks.map.with_index {|task, index| "#{index + 1}. #{task['title']}"}.join("\n")

            HISTORY.add_system_message(user_id, SystemMessages::SELECT_TASK, tasks)

            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::SELECT_TASK.text % {tasks: tasks_str}
            )
          else
            invalid_proc.call(user_id, bot, message.chat.id)
          end
        elsif accept_task_operations.can_accept_task?(user_id)
          HISTORY.add_user_reply(user_id, message.text)

          last_command_replies = HISTORY.last_command_replies(user_id)
          project_number       = last_command_replies[SystemMessages::SELECT_PROJECT].message.to_i
          project              = last_command_replies[SystemMessages::SELECT_PROJECT].extra[project_number - 1]
          task_number          = last_command_replies[SystemMessages::SELECT_TASK].message.to_i
          task                 = last_command_replies[SystemMessages::SELECT_TASK].extra[task_number - 1]
          
          if project && task
            stage = task['info_for_stages'].detect {|ifs| ifs['user_ids'].size > 0}

            user = if stage
              user_id = stage['user_ids'].first
              users = ListUsersQueryHandler.new.list_active_project_users(access_token, project['id'])
              users.detect {|u| u['id'] == user_id}
            end

            points = task['points']

            AcceptTaskHandler.new(access_token, ORG_CONTRACT).accept_task(task_id: task['id'], project_id: project['id'])
            HISTORY.add_system_message(user_id, SystemMessages::TASK_ACCEPTED, tasks)

            if user && points
              bot.api.send_message(
                chat_id: message.chat.id,
                text:    SystemMessages::TASK_ACCEPTED.text % {user: user['name'], task: task['title'], amount: points}
              )
            else
              bot.api.send_message(
                chat_id: message.chat.id,
                text:    SystemMessages::TASK_ACCEPTED.empty_text % {task: task['title']}
              )
            end
          else
            invalid_proc.call(user_id, bot, message.chat.id)
          end
        # USER AWARDS OPERATION
        elsif user_awards_operations.can_return_awards?(user_id)
          HISTORY.add_user_reply(user_id, message.text)

          last_command_replies = HISTORY.last_command_replies(user_id)
          user_number          = last_command_replies[SystemMessages::SELECT_USER].message.to_s.to_i
          user                 = last_command_replies[SystemMessages::SELECT_USER].extra[user_number - 1]

          if user
            amount = ORG_CONTRACT.call.get_user_balance(user['id'])
            HISTORY.add_system_message(user_id, SystemMessages::TOTAL_USER_AWARDS)

            bot.api.send_message(
              chat_id: message.chat.id,
              text:    SystemMessages::TOTAL_USER_AWARDS.text % {user: user['name'], amount: amount.to_s.to_i}
            )
          else
            invalid_proc.call(user_id, bot, message.chat.id)
          end
        else
          bot.api.send_message(
            chat_id: message.chat.id,
            text:    SystemMessages::UNKNOWN_INPUT.text
          )
        end
      end
    end
  end
end