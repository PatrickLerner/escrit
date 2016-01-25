namespace :export do
  desc "Prints seeds.rb content"
  task :seeds_format => :environment do
    Language.order(:id).all.each do |language|
      puts "Language.create(#{language.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    Service.order(:id).where(user_id: 0).each do |service|
      puts "Service.create(#{service.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    Replacement.all.each do |replacement|
      puts "Replacement.create(#{replacement.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
  end
end
