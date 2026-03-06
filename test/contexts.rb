require './test/sets/stores'
require './test/sets/employees'
require './test/sets/assignments'

module Contexts
  include Contexts::Stores
  include Contexts::Employees
  include Contexts::Assignments

  def create_all
    create_stores
    puts "Stores created"
    create_employees
    puts "Employees created"
    create_assignments
    puts "Assignments created"
  end
end


