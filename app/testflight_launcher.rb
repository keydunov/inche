# This file is automatically generated. Do not edit.

if Object.const_defined?('TestFlight') and !UIDevice.currentDevice.model.include?('Simulator')
  NSNotificationCenter.defaultCenter.addObserverForName(UIApplicationDidFinishLaunchingNotification, object:nil, queue:nil, usingBlock:lambda do |notification|
  
  TestFlight.takeOff('8b4c2cc21ff4e9cad3f91bf9875e5c61_MjI4NTQyMjAxMy0wNS0yNiAxNzoxMjo1My4wMjk1MzY')
  end)
end
