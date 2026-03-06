require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  ### Relationship matchers
  should have_many(:assignments)
  should have_many(:stores).through(:assignments)

  subject do
    FactoryBot.create(
      :employee,
      first_name: "Test",
      last_name: "User",
      phone: "4122683259",
      ssn: "999888777",
      date_of_birth: 25.years.ago.to_date,
      role: :employee
    )
  end

  ### Presence validations
  should validate_presence_of(:first_name)
  should validate_presence_of(:last_name)
  should validate_presence_of(:phone)
  should validate_presence_of(:ssn)
  should validate_presence_of(:date_of_birth)

  ### Phone validation matchers (PATS style)
  should allow_value("4122683259").for(:phone)
  should allow_value("412-268-3259").for(:phone)
  should allow_value("412.268.3259").for(:phone)
  should allow_value("(412) 268-3259").for(:phone)

  should_not allow_value("2683259").for(:phone)
  should_not allow_value("4122683259x224").for(:phone)
  should_not allow_value("800-EAT-FOOD").for(:phone)
  should_not allow_value("412/268/3259").for(:phone)
  should_not allow_value("412-2683-259").for(:phone)

  ### SSN validation matchers (PATS style)
  should allow_value("123456789").for(:ssn)
  should allow_value("123-45-6789").for(:ssn)
  should allow_value("123 45 6789").for(:ssn)

  should_not allow_value("12345678").for(:ssn)
  should_not allow_value("123-456-789").for(:ssn)
  should_not allow_value("ABC-DE-FGHI").for(:ssn)

  should "accept valid roles" do
    e = FactoryBot.build(:employee, role: :employee)
    assert e.valid?
    e.role = :manager
    assert e.valid?
    e.role = :admin
    assert e.valid?
  end

  ### Employee.rb method/ scope tests
  context "with employee contexts" do
    setup do
      create_employees
    end

    should "return active employees" do
      assert_equal 5, Employee.active.count
      assert Employee.active.include?(@xherdan)
      assert Employee.active.include?(@stephan)
      deny Employee.active.include?(@charlie)
    end

    should "return inactive employees" do
      assert_equal 3, Employee.inactive.count
      assert Employee.inactive.include?(@charlie)
      assert Employee.inactive.include?(@ethan)
      deny Employee.inactive.include?(@xherdan)
    end

    should "order employees alphabetically by last name then first name" do
      expected_order = ["Manager", "Charlie", "Ethan", "Alex", "Alex", "Xherdan", "Young", "Stephan"]
      assert_equal expected_order, Employee.alphabetical.map(&:first_name)
    end

    should "return employees 18 or older" do
      employees_18_plus = Employee.is_18_or_older
      assert employees_18_plus.include?(@xherdan)
      assert employees_18_plus.include?(@charlie)
      assert employees_18_plus.include?(@stephan)
      deny employees_18_plus.include?(@young_employee)
    end

    should "return employees younger than 18" do
      young_employees = Employee.younger_than_18
      assert young_employees.include?(@young_employee)
      deny young_employees.include?(@xherdan)
      deny young_employees.include?(@stephan)
    end

    should "return only regular employees" do
      regulars = Employee.regulars
      assert regulars.include?(@xherdan)
      assert regulars.include?(@ethan)
      deny regulars.include?(@stephan)
      deny regulars.include?(@charlie)
    end

    should "return only managers" do
      managers = Employee.managers
      assert managers.include?(@stephan)
      assert managers.include?(@manager)
      deny managers.include?(@xherdan)
      deny managers.include?(@charlie)
    end

    should "return only admins" do
      admins = Employee.admins
      assert admins.include?(@charlie)
      deny admins.include?(@xherdan)
      deny admins.include?(@stephan)
    end

    should "search employees by first name" do
      results = Employee.search("Xher")
      assert results.include?(@xherdan)
      deny results.include?(@stephan)
    end

    should "search employees by last name" do
      results = Employee.search("Dunk")
      assert results.include?(@charlie)
      deny results.include?(@xherdan)
    end

    should "search is case insensitive" do
      results = Employee.search("xher")
      assert results.include?(@xherdan)
    end

    should "search returns empty when no match" do
      results = Employee.search("Zzzz")
      assert_equal 0, results.count
    end

    should "identify employee role correctly" do
      assert @xherdan.employee_role?
      deny @stephan.employee_role?
      deny @charlie.employee_role?
    end

    should "identify manager role correctly" do
      assert @stephan.manager_role?
      assert @manager.manager_role?
      deny @xherdan.manager_role?
      deny @charlie.manager_role?
    end

    should "identify admin role correctly" do
      assert @charlie.admin_role?
      deny @xherdan.admin_role?
      deny @stephan.admin_role?
    end

    should "make an inactive employee active" do
      assert_not @charlie.active
      @charlie.make_active
      assert @charlie.active
    end

    should "make an active employee inactive" do
      assert @xherdan.active
      @xherdan.make_inactive
      assert_not @xherdan.active
    end

    should "return employee name as 'last_name, first_name'" do
      assert_equal "Sarabia, Xherdan", @xherdan.name
      assert_equal "Zugzwang, Stephan", @stephan.name
    end

    should "return employee proper name as 'first_name last_name'" do
      assert_equal "Xherdan Sarabia", @xherdan.proper_name
      assert_equal "Stephan Zugzwang", @stephan.proper_name
    end

    should "return current assignment for employee" do
      create_stores
      create_assignments
      assert_equal @assign1, @xherdan.current_assignment
      assert_equal @assign2, @stephan.current_assignment
      assert_nil @charlie.current_assignment
      destroy_assignments
      delete_stores
    end

    should "correctly identify if employee is over 18" do
      assert @xherdan.over_18?
      assert @charlie.over_18?
      assert @stephan.over_18?
      deny @young_employee.over_18?
    end

    ### Test Callback, referenced PATS
    should "strip non-digits from phone and ssn on save" do
      e = FactoryBot.create(
        :employee,
        phone: "(412) 268-3259",
        ssn: "100-20-3000",
        date_of_birth: 25.years.ago.to_date
      )

      e.reload
      assert_equal "4122683259", e.phone
      assert_equal "100203000", e.ssn
    end


    ### Test Uniqueness
    should "require ssn to be unique" do
      FactoryBot.create(:employee, ssn: "777-66-5555", phone: "412-555-1111")
      assert_raises(ActiveRecord::RecordInvalid) do
        FactoryBot.create(:employee, ssn: "777665555", phone: "412-555-2222")
      end
    end

    should "not allow employee younger than 14" do
      young = FactoryBot.build(:employee, date_of_birth: 13.years.ago.to_date)
      deny young.valid?
      assert young.errors[:date_of_birth].include?("must be at least 14 years old")
    end

    should "allow employee exactly 14 years old" do
      employee = FactoryBot.build(:employee, ssn: "555444333", date_of_birth: 14.years.ago.to_date)
      assert employee.valid?
    end

    teardown do
      delete_employees
    end
  end
end
