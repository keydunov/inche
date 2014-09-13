class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = ConverterController.alloc.init
    true
  end

  def applicationDidBecomeActive(application)
    listController = ListController.alloc.init
    listController.delegate = @window.rootViewController
    listController.baseColor = @window.rootViewController.currentColor
    @window.rootViewController.presentModalViewController(listController, animated: true)
    @window.makeKeyAndVisible
  end
end
