require 'rubygems'
require 'data_mapper'
require_relative 'task'
require_relative 'task_user'

class User
  include DataMapper::Resource

  property :id,          Serial
  property :name,        String
  property :created_at,  DateTime

  has n, :task_users, constraint: :destroy
  has n, :tasks, :through => :task_user
end

def main
  DataMapper.setup(:default, 'postgres://adamreed:@localhost/tasks')

  DataMapper.finalize
  DataMapper.auto_migrate!
end

main if __FILE__ == $PROGRAM_NAME
