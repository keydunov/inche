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
  app.deployment_target = '7.0'
  app.version = '2'
  app.short_version = '1.0.1'

  app.frameworks << "QuartzCore"

  app.fonts = ['FARRAY.otf']

  app.icons = Dir.glob("resources/Icon*.png").map{|icon| icon.split("/").last}
  app.interface_orientations = [:portrait]

  app.info_plist['UIStatusBarHidden'] = true

  app.identifier = 'com.b1nary.inche'
  app.codesign_certificate = "iPhone Developer: Mikhail Melanin (98D5N2ZGKS)"

  app.development do
    app.provisioning_profile = "/Users/artyomkeydunov/provision_profiles/Inche_Development.mobileprovision"
    app.codesign_certificate = "iPhone Developer: Mikhail Melanin (98D5N2ZGKS)"
  end

  app.release do
    app.info_plist['AppStoreRelease'] = true
    app.provisioning_profile = "/Users/artyomkeydunov/provision_profiles/Inche_Distribution.mobileprovision"
    app.codesign_certificate = "iPhone Distribution: Mikhail Melanin (JFQH7D48W5)"
  end

  # TestFlight config
  app.testflight.sdk = 'vendor/TestFlight'
  app.testflight.api_token = '602aeb365cbeeed9f6b7bbe956c31cae_MTA3MjkxNjIwMTMtMDUtMjYgMTc6MTI6MjcuOTM1MDgw'
  app.testflight.team_token = '8b4c2cc21ff4e9cad3f91bf9875e5c61_MjI4NTQyMjAxMy0wNS0yNiAxNzoxMjo1My4wMjk1MzY'
end
