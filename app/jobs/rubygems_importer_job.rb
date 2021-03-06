class RubygemsImporterJob < SidekiqJobBase
  sidekiq_options unique: :while_executing

  def perform
    Rails.logger.info "==== RubygemsImporterJob START ===="
    start_time = Time.now

    rubygems_instance = Client::Rubygems.new

    Rails.logger.info "==== RubygemsImporterJob gems count: #{rubygems_instance.size} ===="

    new_gems_names = (rubygems_instance.names - GemObject.all.pluck(:name))

    # first process new gems
    new_gems_names.each do |new_gem_name|
      Services::RubygemsImporter.new.import(new_gem_name)
    end

    new_gems_names = nil

    # process gems ordered by oldest rubygems sync
    count = GemObject.count
    batch = 100
    (0..(count - batch)).step(batch) do |i|
      GemObject.order(rubygems_sync_at: :asc).offset(i).limit(batch).each do |gem_object|
        Services::RubygemsImporter.new.import(gem_object.name)
      end
    end

    Rails.logger.info "==== RubygemsImporterJob END - GemObjects count: #{GemObject.count}; It took: #{TimeDifference.between(start_time, Time.now).in_general} ===="
  end

end
