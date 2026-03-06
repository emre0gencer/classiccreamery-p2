module Contexts
  module Employees
    ###Referenced PATs_v1 & also tried to include edge cases
    def create_employees
      @employee1 = FactoryBot.create(:employee)
      @xherdan = FactoryBot.create(:employee, first_name: "Xherdan", last_name: "Sarabia", ssn: "987654321", date_of_birth: 25.years.ago.to_date, phone: "5551234567", role: :employee, active: true)
      @charlie = FactoryBot.create(:employee, first_name: "Charlie", last_name: "Dunkirk", ssn: "555667777", date_of_birth: 30.years.ago.to_date, phone: "5559876543", role: :admin, active: false)
      @stephan = FactoryBot.create(:employee, first_name: "Stephan", last_name: "Zugzwang", ssn: "111223333", date_of_birth: 22.years.ago.to_date, phone: "5555555555", role: :manager, active: true)
      @ethan = FactoryBot.create(:employee, first_name: "Ethan", last_name: "Hawkeye", ssn: "444556666", date_of_birth: 28.years.ago.to_date, phone: "5556667777", role: :employee, active: false)
      @inactive = FactoryBot.create(:employee, ssn: "777777777", active: false)
      @manager = FactoryBot.create(:employee, first_name: "Manager", last_name: "Boss", ssn: "999888777", date_of_birth: 35.years.ago.to_date, phone: "5554443333", role: :manager, active: true)
      @young_employee = FactoryBot.create(:employee, first_name: "Young", last_name: "Worker", ssn: "222333444", date_of_birth: 16.years.ago.to_date, phone: "5552221111", role: :employee, active: true)
    end

    def delete_employees
      @employee1&.destroy
      @xherdan&.destroy
      @charlie&.destroy
      @stephan&.destroy
      @ethan&.destroy
      @inactive&.destroy
      @manager&.destroy
      @young_employee&.destroy
    end
  end
end