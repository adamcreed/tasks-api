require 'data_mapper'
require 'json'
require 'sinatra'
require_relative '../model/user'
require_relative 'task_functions'

DataMapper.setup(:default, 'postgres://adamreed:@localhost/tasks')

get '/api/tasks' do
  if params['search'].nil? or params['user_id'].nil?
    pass
  else
    completion_filter = params['completed'] || false
    get_tasks(User.get(params['user_id']).task_users.task
                  .all(:description.like => params['search']),
                  completion_filter).to_json
  end
end

get '/api/tasks' do
  user = User.get(params['user_id'])
  completion_filter = params['completed'] || false
  if user.nil?
    [404, 'Error: No user found'.to_json]
  else
    tasks = get_tasks(user, completion_filter)
    tasks.to_json
  end
end

put '/api/tasks/:id' do |id|
  task = TaskUser.get(id)

  if task.nil?
    status 404
  else
    complete_task(task)
  end
end

post '/api/tasks' do
  task = create_task(params)
  list_item = add_task_to_list(task, params)

  { task: task, list_item: list_item }.to_json
end

post '/api/users/' do
  [400, 'Error: No name entered'.to_json]
end

post '/api/users/:name' do |name|
  create_user(name)
end

delete '/api/tasks' do
  delete_entry(params)
end
