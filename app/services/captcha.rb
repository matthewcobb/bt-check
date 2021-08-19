require 'rtesseract'

class Captcha
  attr_reader :image

  def initialize(image)
    @image = image
  end

  def solve
    captcha = RTesseract.new(image.path).to_s.strip
  end
end
