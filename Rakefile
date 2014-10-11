# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

require 'bubble-wrap/reactor'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Inché'

  app.frameworks << "QuartzCore"

  app.fonts = ['FARRAY.otf']

  app.icons = ["Icon-60.png", "Icon-60@2x.png", "Icon-72.png", "Icon-72@2x.png"]
  app.interface_orientations = [:portrait]

  app.info_plist['UIStatusBarHidden'] = true

  app.development do
    app.identifier = 'com.b1nary.inche'
    app.provisioning_profile = "/Users/artyomkeydunov/provision_profiles/Inche_Development.mobileprovision"
    app.codesign_certificate = "iPhone Developer: Mikhail Melanin (98D5N2ZGKS)"
  end

  # TestFlight config
  app.testflight.sdk = 'vendor/TestFlight'
  app.testflight.api_token = '602aeb365cbeeed9f6b7bbe956c31cae_MTA3MjkxNjIwMTMtMDUtMjYgMTc6MTI6MjcuOTM1MDgw'
  app.testflight.team_token = '8b4c2cc21ff4e9cad3f91bf9875e5c61_MjI4NTQyMjAxMy0wNS0yNiAxNzoxMjo1My4wMjk1MzY'
end
