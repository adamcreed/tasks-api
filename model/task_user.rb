class TaskUser
  include DataMapper::Resource

  property :id,          Serial
  property :task_id,     Integer
  property :user_id,     Integer
  property :do_by,       DateTime
  property :priority,    Integer
  property :completed,   Boolean
  property :created_at,  DateTime

  belongs_to :task
  belongs_to :user
end
