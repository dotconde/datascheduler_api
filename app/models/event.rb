class Event < ApplicationRecord
  belongs_to :profile

  scope :today_events, ->(user) {
    joins(profile: :user)
      .where(users: { id: user.id })
      .where('start_date >= ? AND start_date < ?', Date.today, Date.tomorrow)
      .order(:start_date)
  }

  def self.events_within_date_range(profile, start_date, end_date)
    where(profile: profile)
      .where('(start_date >= ? AND start_date < ?) OR (end_date > ? AND end_date <= ?)',
             start_date, end_date, start_date, end_date)
  end

  def self.overlapping_events(profile, start_date, end_date)
    where(profile: profile)
      .where('(start_date < :end_date AND end_date > :start_date) OR 
              (start_date < :end_date AND end_date > :start_date) OR 
              (start_date >= :start_date AND end_date <= :end_date)',
             start_date: start_date, end_date: end_date)
  end
end
