require 'app'
require 'rspec'
require 'rack/test'

describe 'app' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe 'get /api/tasks' do
    context 'when a valid id is entered' do
      it 'returns all tasks for the id provided, starting with incomplete' do
        get '/api/tasks?user_id=2'

        expect(JSON.parse(last_response.body).first['user_name']).to eq 'Jenn'
        expect(JSON.parse(last_response.body).first['completed']).to eq false
      end
    end

    context 'when a completion filter is provided' do
      it 'filters tasks by completion' do
        get '/api/tasks?user_id=2&completed=true'

        expect(JSON.parse(last_response.body).first['completed']).to eq true
      end
    end

    context 'when a search term is provided' do
      it 'filters tasks by name' do
        get '/api/tasks?user_id=1&search=buy a horse-dagger'

        expect(JSON.parse(last_response.body).first['description'])
          .to eq 'buy a horse-dagger'
      end
    end

    context 'when an invalid id is entered' do
      it 'returns a 404' do
        get '/api/tasks/9999'

        expect(last_response.status).to eq 404
      end
    end

    context 'when no id is entered' do
      it 'returns a 404' do
        get '/api/tasks'

        expect(last_response.status).to eq 404
        expect(JSON.parse(last_response.body)).to eq 'Error: No user found'
      end
    end
  end

  describe 'put /api/tasks/:id' do
    context 'when given a valid task-user id' do
      it 'updates completed column to true' do
        put '/api/tasks/5'
        task = TaskUser.get(5)

        expect(last_response.status).to eq 201
        expect(task.completed).to eq true
      end
    end

    context 'when given an invalid task_user id' do
      it 'sends a 404 error message' do
        put '/api/tasks/9999'

        expect(last_response.status).to eq 404
      end
    end
  end

  describe 'post /api/tasks' do
    it 'creates a new task and adds a user to it' do
      post '/api/tasks?description=buy a horse-dagger' \
           '&user_id=1&do_by=2/2/2017&priority=11'

      expect(JSON.parse(last_response.body)['task']['description'])
        .to eq 'buy a horse-dagger'

      expect(JSON.parse(last_response.body)['list_item']['priority'])
        .to eq 11
    end
  end

  describe 'post /api/users/:name' do
    context 'when a user name is entered' do
      it 'creates a new user when given a name' do
        post '/api/users/tom'

        expect(JSON.parse(last_response.body)['name']).to eq 'tom'
      end
    end

    context 'when nothing is entered' do
      it 'sends a 400 error message' do
        post '/api/users/'

        expect(JSON.parse(last_response.body)).to eq 'Error: No name entered'
        expect(last_response.status).to eq 400
      end
    end
  end
end
