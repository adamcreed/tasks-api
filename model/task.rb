class Task
  include DataMapper::Resource

  property :id,          Serial
  property :description, String
  property :created_at,  DateTime

  has n, :task_users, constraint: :destroy
  has n, :users, :through => :task_user
end
