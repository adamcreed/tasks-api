require 'data_mapper'
require 'json'
require 'sinatra'
require_relative '../model/user'

DataMapper.setup(:default, 'postgres://adamreed:@localhost/tasks')

def get_tasks(user)
  user.task_users(:order => [:priority]).map do |task_user|
    {
      user_name: user.name,
      description: task_user.task.description,
      priority: task_user.priority,
      completed: task_user.completed,
      do_by: task_user.do_by
    }
  end
end

get '/api/tasks' do
  [400, 'Error: No ID entered']
end

get '/api/tasks/:id' do |id|
  user = User.get(id)
  unless user.nil?
    tasks = get_tasks(user)
    tasks.to_json
  else
    [404, 'No user found']
  end
end

put '/api/task/:id' do |id|
  task = TaskUser.get(id)
  task.completed = true
  if task.valid?
    status 201
  task.save
  else
    status 404
  end
end

post '/api/task' do
  task = Task.new
  task.description = params[:description]
  if task.valid?
    task.save
  else
    status 400
  end

  list_item = TaskUser.new
  list_item.task_id = task.id
  list_item.user_id = params[:user_id]
  list_item.do_by = params[:do_by]
  list_item.priority = params[:priority]


  if list_item.valid?
    status 201
    list_item.save
  else
    status 400
  end
end

post '/api/user/:name' do |name|
  user = User.new
  user.name = name
  if user.valid?
    status 201
    user.save
  else
    status 400
  end
end

delete '/api/task' do
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
