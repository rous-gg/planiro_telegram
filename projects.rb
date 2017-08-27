PROJECTS = []

class CreateProjectHandler
  def handle(user_id:, name:)
    puts "Creating new project: #{name}"
    PROJECTS.push(name)
  end
end