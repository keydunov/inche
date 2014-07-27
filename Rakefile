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
  app.name = 'Inche'

  app.frameworks << "QuartzCore"

  app.icons = ["Icon-60.png", "Icon-60@2x.png", "Icon-72.png", "Icon-72@2x.png"]
  app.interface_orientations = [:portrait]

  app.development do
    app.identifier = 'com.b1nary.inche'
    app.provisioning_profile = "/Users/artyomkeydunov/provision_profiles/Inche_Development.mobileprovision"
    app.codesign_certificate = "iPhone Developer: Mikhail Melanin (98D5N2ZGKS)"
  end
end
