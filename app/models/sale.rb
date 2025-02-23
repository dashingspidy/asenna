class Sale < ApplicationRecord
  before_create :generate_sale_number
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items
  belongs_to :customer, optional: true

  scope :total_by_day, ->(date = Time.zone.today) { where(created_at: date.all_day).sum(:total_price) }
  scope :total_by_month, ->(date = Time.zone.now) { where(created_at: date.all_month).sum(:total_price) }
  scope :total_by_year, ->(date = Time.zone.now) { where(created_at: date.all_year).sum(:total_price) }
  scope :total_by_week, -> { where(created_at: Time.current.beginning_of_week..Time.current.end_of_week).group_by_day_of_week(:created_at, format: "%a").sum(:total_price) }
  scope :total_customer_today, -> { where(created_at: Time.zone.today.all_day).count }

  def self.sales_insight
    today = total_by_day
    yesterday = total_by_day(1.day.ago)

    this_month = total_by_month
    last_month = total_by_month(1.month.ago)

    this_year = total_by_year
    last_year = total_by_year(1.year.ago)

    {
      sales_by_day: today,
      sales_day_change: percentage_change(yesterday, today),

      sales_by_month: this_month,
      sales_month_change: percentage_change(last_month, this_month),

      sales_by_year: this_year,
      sales_year_change: percentage_change(last_year, this_year)
    }
  end

  def self.percentage_change(previous, current)
    return "No data" if previous.zero? && current.zero?
    return "New record" if previous.zero? && current.positive?

    change = ((current - previous) / previous.to_f) * 100
    change.positive? ? "#{change.round(1)}% more than last period" : "#{change.abs.round(1)}% less than last period"
  end

  def generate_sale_number
    loop do
      self.sale_number = rand(100000..999999).to_s
      break unless Sale.exists?(sale_number: sale_number)
    end
  end
end
