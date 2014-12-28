class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = ConverterController.alloc.init
    @window.makeKeyAndVisible

    # Start Flurry only on real device
    start_flurry unless Device.simulator?

    true
  end

  def start_flurry
    NSSetUncaughtExceptionHandler('uncaughtExceptionHandler')
    Flurry.startSession "4P7TSC9KXVQVB55MKJ2V"
  end

  #Flurry exception handler
  def uncaughtExceptionHandler(exception)
    Flurry.logError("Uncaught", message:"Crash!", exception:exception)
  end
end
