class RemoveAboutTextFromStores < ActiveRecord::Migration[7.0]
  def up
    Store.find_each do |store|
      store.update(about: store.about_text)
    end
  end

  def down
    Store.find_each do |store|
      store.update(about_text: store.about)
      store.update(about: nil)
    end
  end
end
