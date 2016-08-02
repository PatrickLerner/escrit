namespace :db do
  desc 'reindex objects for elasticsearch'
  task reindex: :environment do
    [Text, Word].each do |klass|
      puts "Reindexing #{klass} ..."
      klass.reindex
    end
  end
end
