# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require ::File.expand_path('../app/api/AppBase',  __FILE__)

run Rack::Cascade.new([
    AppBase::APIV1,
    BaseServer::Application
    ])
