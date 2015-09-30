class AddEnabledToService < ActiveRecord::Migration
  def change
    add_column :services, :enabled, :boolean
    Service.all.each do |service|
      service.update_attributes(enabled: true)
    end
  end
end
