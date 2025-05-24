require 'factory_bot_rails'

RSpec.configure do |config|

  config.include FactoryBot::Syntax::Methods

  config.before(:all) do
    FactoryBot.reload
  end

end