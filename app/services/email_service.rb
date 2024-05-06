class EmailService
  def initialize(event, weather)
    @event = event
    @weather = weather
  end

  def call
    subject = 'New Event Created'
    body = "A new event with title '#{@event.title}' has been created.\n" +
           "Start Date: #{@event.start_date}\n" +
           "End Date: #{@event.end_date}\n" +
           "Location: #{@event.location}\n" +
           "Weather: #{@weather&.main&.temp}"

    client = Postmark::ApiClient.new(ENV['POSTMARK_API_KEY'])
    client.deliver(from: 'deyvi@popualert.com', to: 'deyvi@popualert.com', subject: subject, text_body: body)
  end
end
