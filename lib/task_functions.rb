# Using a more procedural approach rather than an OO one
# makes more sense to me here, given the fleeting nature of each function.

def get_tasks(search, completion_filter)
  search.task_users(:order => [:priority]).all(:completed => completion_filter)
        .map do |task_user|
    {
      user_name: task_user.user.name,
      description: task_user.task.description,
      priority: task_user.priority,
      completed: task_user.completed,
      do_by: task_user.do_by
    }
  end
end

def create_task(params)
  task = Task.new
  task.description = params[:description]

  if task.valid?
    task.save
    task
  else
    halt status 400
  end
end

def add_task_to_list(task, params)
  list_item = TaskUser.new
  list_item.task_id = task.id
  list_item.user_id = params[:user_id]
  list_item.do_by = params[:do_by]
  list_item.priority = params[:priority]

  if list_item.valid?
    status 201
    list_item.save
    list_item
  else
    status 400
  end
end

def complete_task(task)
  task.completed = true
  task.save
  status 201
  task.to_json
end

def create_user(name)
  user = User.new
  user.name = name
  user.save
  status 201
  user.to_json
end

def delete_entry(params)
  case params[:thing]
  when 'task'
    item = Task.get(params[:id])
  when 'user'
    item = User.get(params[:id])
  when 'task_user'
    item = TaskUser.get(params[:id])
  end

  item.destroy
end
