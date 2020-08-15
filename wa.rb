require 'uri'
require 'csv'
require 'capybara'
require 'selenium-webdriver'

contacts = CSV.read("numbers.csv").flatten
message = URI.encode_www_form_component(File.open("message.txt").read)

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.default_driver = :selenium

session = Capybara.current_session

contacts.each do |contact|
  session.visit "https://web.whatsapp.com/send?phone=#{contact}&text=#{message}"

  until session.has_css?('._1U1xa')
    puts 'Scan QR pls'
  end

  session.find('._1U1xa').click
  sleep(1)

  # Rescueing from StaleElementReferenceError
  begin
    last_chat_bubble = session.all('._1qPwk').last

    until !last_chat_bubble.has_css?('span[aria-label=" Pending "]')
      puts 'Message pending'
      sleep(1)
    end
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    retry
  end
end
