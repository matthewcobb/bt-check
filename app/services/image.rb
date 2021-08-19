class Image
  attr_reader :driver

  def initialize(driver)
    @driver = driver
  end

  def store
    canvas = driver.find_element(id: "CaptchaCanvas")
    canvas_base64 = driver.execute_script("return arguments[0].toDataURL('image/jpeg', 1).substring(22);", canvas)
    File.open('captcha.jpeg', 'wb') do |f|
      f.write(Base64.decode64(canvas_base64))
    end

    File.new Rails.root.join "captcha.jpeg"
  end
end
