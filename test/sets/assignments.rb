module Contexts
  module Assignments

    def create_assignments
      ### Current Assignments
      
      @assign1 = FactoryBot.create(
        :assignment,
        employee: @xherdan,
        store: @store1,
        start_date: 6.months.ago.to_date
      )

      @assign2 = FactoryBot.create(
        :assignment,
        employee: @stephan,
        store: @store2,
        start_date: 3.months.ago.to_date
      )

      ### Past Assignments
      
      @assign3 = FactoryBot.create(
        :assignment,
        employee: @employee1,
        store: @store3,
        start_date: 10.months.ago.to_date,
        end_date: 4.months.ago.to_date
      )

      @assign4 = FactoryBot.create(
        :assignment,
        employee: @stephan,
        store: @store1,
        start_date: 8.months.ago.to_date,
        end_date: 4.months.ago.to_date
      )

      @assign5 = FactoryBot.create(
        :assignment,
        employee: @manager,
        store: @store1,
        start_date: 1.month.ago.to_date
      )
    end

    def destroy_assignments
      @assign1&.destroy
      @assign2&.destroy
      @assign3&.destroy
      @assign4&.destroy
      @assign5&.destroy
    end

  end
end
