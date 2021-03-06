namespace :db do
  namespace :wipe do
    desc "An overridable environment for rails_wipe gem"
    task environment: [:environment] do
      abort "[ERROR] Cannot wipe #{Rails.env} environment." if Rails.env.production?
    end
  end

  desc "Truncate the database (from rails_wipe gem)"
  task wipe: ["wipe:environment"] do
    Rails.application.eager_load!

    connection = ActiveRecord::Base.connection
    quoted_table_names = (ActiveRecord::Base.descendants - [ActiveRecord::SchemaMigration])
      .select(&:table_exists?)
      .map(&:quoted_table_name)

    sql = <<-SQL.strip_heredoc
      TRUNCATE TABLE #{quoted_table_names.join(",")}
    SQL

    $stderr.puts sql
    connection.execute(sql)
  end
end
