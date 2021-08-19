require 'mechanize'
require 'selenium-webdriver'

namespace :scan do
  desc "Scan BT website"
  task run: :environment do
    retry_count = 0
    max_retry = 5

    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])

    begin
      driver = Selenium::WebDriver.for(:chrome, options: options)
      driver.get('https://www.broadbandchecker.btwholesale.com/#/ADSL')
      driver.manage.timeouts.implicit_wait = 20 # seconds

      # Get canvas
      image = Image.new(driver).store
      captcha_code = Captcha.new(image).solve

      # Retry if invalid captcha
      if captcha_code.length != 6
        raise StandardError.new "Captcha Invalid..."
      end

      # Complete inputs
      tele_input = driver.find_element(id: 'telePhoneNumber')
      tele_input.send_keys('01736794315')
      captcha_input = driver.find_element(id: 'userCaptcha')
      captcha_input.send_keys(captcha_code)

      # Submit
      driver.find_element(id: 'BtnsPublicGUi').click

      # Look for errors
      errors = driver.find_elements(class: 'errormessage')
      errors.each do |p|
        puts p.text.strip
      end

      # Retry if invalid captcha
      if errors.present?
        raise StandardError.new "Captcha Invalid..."
      end

      # Wait for new page and find elements
      begin
        a = driver.find_element(xpath: '//*[@id="t01"]/tbody[2]/tr[1]/td[6]').text.strip
        b = driver.find_element(xpath: '//*[@id="t01"]/tbody[2]/tr[2]/td[6]').text.strip
        c = driver.find_element(xpath: '//*[@id="t01"]/tbody[2]/tr[1]/td[7]').text.strip
        d = driver.find_element(xpath: '//*[@id="t01"]/tbody[2]/tr[2]/td[7]').text.strip

        puts "VDSL A FTTC – " + a
        puts "VDSL A FTTC – " + b
        puts "VDSL A SOGEA – " + c
        puts "VDSL B SOGEA – " + d

        if [a, b, c, d].exclude?("Waiting list")
          Notify.new('✅ Available!').send
        else
          Notify.new('⚠️ No space available!').send
        end
      rescue Selenium::WebDriver::Error::NoSuchElementError
        Notify.new('Error, table config changed').send
      end

    rescue StandardError => e
      puts e.message
      retry_count += 1
      if retry_count < max_retry
        driver.quit
        sleep 4
        retry
      else
        Notify.new('Error, exceeded max retries').send
      end
    ensure
      puts "Closing connection"
      driver.quit
    end
  end
end