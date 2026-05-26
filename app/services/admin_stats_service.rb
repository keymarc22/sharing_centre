class AdminStatsService

  def initialize(start_date:, end_date:)
    @start_date = start_date.beginning_of_day
    @end_date = end_date.end_of_day
    @prev_start_date = (@start_date - period_length).beginning_of_day
    @prev_end_date   = (@start_date - 1.second).end_of_day
  end

  def call
    Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
      {
        period: { start: @start_date, end: @end_date },
        previous_period: { start: @prev_start_date, end: @prev_end_date },
        students_active: compare_metric(method(:students_active_count)),
        retention_rate: compute_retention,
        classes_completed: compare_metric(method(:classes_completed_count)),
        students_by_language: students_by_language_current
      }
    end
  end

  private

  def period_length
    @end_date - @start_date
  end

  def cache_key
    "admin_stats:#{@start_date.to_date}:#{@end_date.to_date}"
  end

  def compare_metric(metric_method)
    current = metric_method.call(@start_date, @end_date)
    previous = metric_method.call(@prev_start_date, @prev_end_date)
    {
      current: current,
      previous: previous,
      change_pct: percent_change(previous, current)
    }
  end

  def students_active_count(from, to)
    # lesson_user_ids = LessonCompletion.where(created_at: from..to).select(:user_id)
    # sign_in_user_ids = User.where(last_sign_in_at: from..to).select(:id)

    # sql = <<-SQL.squish
    #   SELECT COUNT(DISTINCT id) FROM (
    #     SELECT user_id AS id FROM lesson_completions WHERE created_at BETWEEN :from AND :to
    #     UNION
    #     SELECT id FROM users WHERE last_sign_in_at BETWEEN :from AND :to
    #   ) t
    # SQL
    # ActiveRecord::Base.connection.exec_query(
    #   sql,
    #   "SQL",
    #   [
    #     ActiveRecord::Relation::QueryAttribute.new("from", from, ActiveRecord::Type::DateTime.new),
    #     ActiveRecord::Relation::QueryAttribute.new("to", to, ActiveRecord::Type::DateTime.new)
    #   ]
    # ).rows.first.first.to_i
  end

  # 2) Clases completadas: conteo simple de completions en el periodo
  def classes_completed_count(from, to)
    # LessonCompletion.where(created_at: from..to).count
  end

  def compute_retention
    prev_ids = user_ids_in_period(@prev_start_date, @prev_end_date)
    return { current: nil, previous: prev_ids.count, change_pct: nil } if prev_ids.empty?

    curr_ids = user_ids_in_period(@start_date, @end_date)
    retained = (prev_ids & curr_ids).size

    retention = (retained.to_f / prev_ids.size * 100).round(1)
    {
      value: retention,
      previous_active_count: prev_ids.size,
      retained_count: retained
    }
  end

  def user_ids_in_period(from, to)
    lesson_ids = LessonCompletion.where(created_at: from..to).distinct.pluck(:user_id)
    sign_in_ids = User.where(last_sign_in_at: from..to).distinct.pluck(:id)
    (lesson_ids + sign_in_ids).uniq
  end

  # 4) Students by language (current period)
  def students_by_language_current
    from = @start_date; to = @end_date
    # Assuming User.language contains 'en' or 'es' or 'english'/'español'
    # We count unique users active in current period and group by language.
    user_ids = user_ids_in_period(from, to)
    return {} if user_ids.empty?

    User.where(id: user_ids)
        .group("COALESCE(NULLIF(LOWER(language), ''), 'unknown')")
        .count
        .transform_keys do |k|
          case k.to_s
          when /^en/ then 'english'
          when /^es/ then 'español'
          else k
          end
        end
  end

  def percent_change(previous, current)
    return nil if previous.nil?
    return nil if previous == 0 # evita división por cero; puedes decidir mostrar 100% si previous==0 y current>0
    (((current - previous).to_f / previous) * 100).round(1)
  end
end