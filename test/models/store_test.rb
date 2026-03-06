require "test_helper"

class StoreTest < ActiveSupport::TestCase
  ### Referenced PATs_v1 Implementation
  ### Relationship matchers
  should have_many(:assignments)
  should have_many(:employees).through(:assignments)

  ###Validation matchers
  should validate_presence_of(:name)
  should validate_presence_of(:street)
  should validate_presence_of(:city)
  should allow_value("PA").for(:state)
  should allow_value("OH").for(:state)
  should allow_value("WV").for(:state)
  should_not allow_value("NY").for(:state)
  should_not allow_value("CA").for(:state)

  should validate_presence_of(:zip)
  should allow_value("15213").for(:zip)
  should_not allow_value("1521").for(:zip)
  should_not allow_value("152134").for(:zip)

  should validate_presence_of(:phone)
  should allow_value("4122683259").for(:phone)
  should_not allow_value("412268325").for(:phone)

  context "with store contexts" do
    setup do
      create_stores
    end

    ### Test scope: active
    should "return active stores" do
      assert_equal 3, Store.active.count
      assert Store.active.include?(@store1)
      assert Store.active.include?(@store2)
      assert Store.active.include?(@store3)
      deny Store.active.include?(@store4)
    end

    ### Test scope: inactive
    should "return inactive stores" do
      assert_equal ["Old Boys"], Store.inactive.map(&:name)
      assert Store.inactive.include?(@store4)
      deny Store.inactive.include?(@store1)
    end

    ### Test scope: alphabetical
    should "order stores alphabetically" do
      assert_equal ["CMU", "McDonalds", "Old Boys", "P's Barber"],
                   Store.alphabetical.map(&:name)
    end

    ### Test method: make_active
    should "make an inactive store active" do
      assert_not @store4.active
      @store4.make_active
      assert @store4.active
    end

    ### Test method: make_inactive
    should "make an active store inactive" do
      assert @store1.active
      @store1.make_inactive
      assert_not @store1.active
    end

    ### Test callback: normalize_phone
    should "strip non-digits from store phone before saving" do
      s = FactoryBot.create(:store, phone: "(412) 268-3259")
      assert_equal "4122683259", s.phone
    end

    teardown do
      delete_stores
    end
  end
end
