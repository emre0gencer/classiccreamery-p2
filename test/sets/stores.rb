module Contexts
  module Stores

    def create_stores
      @store1  = FactoryBot.create(:store, name: "CMU")
      @store2   = FactoryBot.create(:store, name: "P's Barber", street: "456 Oak St")
      @store3 = FactoryBot.create(:store, name: "McDonalds", street: "123 Main St")
      @store4 = FactoryBot.create(:store, name: "Old Boys", active: false)
    end

    def delete_stores
      @store1.destroy
      @store2.destroy
      @store3.destroy
      @store4.destroy
    end

  end
end
