class Notify
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def send
    TerminalNotifier.notify(message, title: 'BT check', open: 'https://www.broadbandchecker.btwholesale.com/#/ADSL', appIcon:'/Users/jonkob/Code/bt-check/bt-logo.jpg')
  end
end
