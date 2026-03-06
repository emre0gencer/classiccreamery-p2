require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  ### Referenced PATs_v1 Implementation
  ### Relationship matchers
  should belong_to(:store)
  should belong_to(:employee)

  ### Validation matchers
  should validate_presence_of(:start_date)

  context "with assignment contexts" do
    setup do
      create_stores
      create_employees
      create_assignments
    end

    ### Test scope: current
    should "return current assignments" do
      current_assignments = Assignment.current
      assert_equal 3, current_assignments.count, "Should have 3 current assignments, got #{current_assignments.count}"
      assert current_assignments.include?(@assign1), "Should include @assign1"
      assert current_assignments.include?(@assign2), "Should include @assign2"
      assert current_assignments.include?(@assign5), "Should include @assign5"
      deny current_assignments.include?(@assign3), "Should not include @assign3"
      deny current_assignments.include?(@assign4), "Should not include @assign4"
    end

    ### Test scope: past
    should "return past assignments" do
      past_assignments = Assignment.past
      assert past_assignments.include?(@assign3)
      assert past_assignments.include?(@assign4)
      deny past_assignments.include?(@assign1)
      deny past_assignments.include?(@assign2)
    end

    ### Test scope: by_store
    should "order assignments by store name" do
      store_names = Assignment.by_store.map { |a| a.store.name }
      assert_equal store_names, store_names.sort
    end

    ### Test scope: by_employee
    should "order assignments by employee last name then first name" do
      employees = Assignment.by_employee.map { |a| a.employee.last_name }
      assert_equal employees, employees.sort
    end

    # Test scope: chronological
    should "order assignments by start date descending" do
      dates = Assignment.chronological.map(&:start_date)
      assert_equal dates, dates.sort.reverse
    end

    ### Test scope: for_store
    should "return assignments for a specific store" do
      store1_assignments = Assignment.for_store(@store1)
      assert store1_assignments.include?(@assign1)
      assert store1_assignments.include?(@assign4)
      assert store1_assignments.include?(@assign5)
      deny store1_assignments.include?(@assign2)
      deny store1_assignments.include?(@assign3)
    end

    ### Test scope: for_employee
    should "return assignments for a specific employee" do
      stephan_assignments = Assignment.for_employee(@stephan)
      assert stephan_assignments.include?(@assign2)
      assert stephan_assignments.include?(@assign4)
      deny stephan_assignments.include?(@assign1)
      deny stephan_assignments.include?(@assign3)
    end

    # Test scope: for_role
    should "return assignments for employees with specific role" do
      employee_role_assignments = Assignment.for_role(:employee)
      assert employee_role_assignments.include?(@assign1)
      deny employee_role_assignments.include?(@assign2)
      deny employee_role_assignments.include?(@assign5)
    end

    should "return assignments for managers" do
      manager_assignments = Assignment.for_role(:manager)
      assert manager_assignments.include?(@assign2)
      assert manager_assignments.include?(@assign4)
      assert manager_assignments.include?(@assign5)
      deny manager_assignments.include?(@assign1)
    end

    # Test scope: for_date
    should "return assignments active on a specific date" do
      date = 2.months.ago.to_date
      assignments_on_date = Assignment.for_date(date)
      assert assignments_on_date.include?(@assign1), "Should include @assign1 (started 6mo ago, current)"
      assert assignments_on_date.include?(@assign2), "Should include @assign2 (started 3mo ago, current)"
      deny assignments_on_date.include?(@assign3), "Should not include @assign3 (ended 4mo ago)"
      deny assignments_on_date.include?(@assign4), "Should not include @assign4 (ended 4mo ago)"
      deny assignments_on_date.include?(@assign5), "Should not include @assign5 (started 1mo ago, not yet active 2mo ago)"
    end

    should "return assignments that cover a date range" do
      old_date = 9.months.ago.to_date
      assignments_on_old_date = Assignment.for_date(old_date)
      assert assignments_on_old_date.include?(@assign3), "Should include @assign3 (started 10mo ago, ended 4mo ago)"
      deny assignments_on_old_date.include?(@assign4), "Should not include @assign4 (started 8mo ago, not yet active 9mo ago)"
    end

    ### Test validation: start_date_valid_time
    should "not allow start date in the future" do
      future_assignment = FactoryBot.build(:assignment, 
        employee: @xherdan, 
        store: @store1, 
        start_date: 1.day.from_now.to_date
      )
      deny future_assignment.valid?
      assert future_assignment.errors[:start_date].include?("must be on or before the present date")
    end

    should "allow start date today" do
      today_assignment = FactoryBot.build(:assignment,
        employee: @xherdan,
        store: @store2,
        start_date: Date.current
      )
      assert today_assignment.valid?
    end

    ### Test validation: end_date_valid_time
    should "not allow end date before start date" do
      bad_assignment = FactoryBot.build(:assignment,
        employee: @xherdan,
        store: @store2,
        start_date: 3.months.ago.to_date,
        end_date: 4.months.ago.to_date
      )
      deny bad_assignment.valid?
      assert bad_assignment.errors[:end_date].include?("must be after the start date")
    end

    should "not allow end date in the future" do
      future_end = Date.current + 1.day
      a = FactoryBot.build(
        :assignment,
        employee: @xherdan,
        store: @store2,
        start_date: 2.days.ago.to_date,
        end_date: future_end
      )
      deny a.valid?
      assert a.errors[:end_date].include?("must be on or before the present date")
    end


    should "allow end date after start date" do
      good_assignment = FactoryBot.build(:assignment,
        employee: @xherdan,
        store: @store2,
        start_date: 4.months.ago.to_date,
        end_date: 2.months.ago.to_date
      )
      @assign1.update(end_date: 5.months.ago.to_date)
      assert good_assignment.valid?
    end

    ### Test validation: store_active
    should "not allow assignment to inactive store" do
      inactive_store_assignment = FactoryBot.build(:assignment,
        employee: @xherdan,
        store: @store4,
        start_date: 1.month.ago.to_date
      )
      deny inactive_store_assignment.valid?
      assert inactive_store_assignment.errors[:store_id].include?("must be active")
    end

    ### Test validation: employee_active
    should "not allow assignment to inactive employee" do
      inactive_employee_assignment = FactoryBot.build(:assignment,
        employee: @charlie,
        store: @store1,
        start_date: 1.month.ago.to_date
      )
      deny inactive_employee_assignment.valid?
      assert inactive_employee_assignment.errors[:employee_id].include?("must be active")
    end

    # Test callback: end_previous_assignment
    should "end previous assignment when creating new assignment" do
      assert_nil @assign1.end_date
      
      new_assignment = FactoryBot.create(:assignment,
        employee: @xherdan,
        store: @store2,
        start_date: Date.current
      )
      
      @assign1.reload
      assert_equal Date.current, @assign1.end_date
      
      new_assignment.delete
    end

    should "not affect other employees' assignments when creating new assignment" do
      assert_nil @assign2.end_date
      
      new_assignment = FactoryBot.create(:assignment,
        employee: @xherdan,
        store: @store3,
        start_date: Date.current
      )
      
      @assign2.reload
      assert_nil @assign2.end_date
      
      new_assignment.delete
    end

    teardown do
      destroy_assignments
      delete_employees
      delete_stores
    end
  end
end
