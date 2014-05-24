class ConverterController < UIViewController
  NUMBERS_WRAPPER_HEIGHT = 169
  INITIAL_VALUE = 0

  INITIAL_COLOR = "#48CA77".to_color
  DARK_COLOR = "#3c3c3c".to_color


  def viewDidLoad
    # Половина ширина экраны
    width_half = self.view.frame.size.width/2
    self.view.backgroundColor = INITIAL_COLOR

    # левая колонка
    @leftColumnNumbersWrapper = UIView.alloc.initWithFrame [[0, 0], [width_half, NUMBERS_WRAPPER_HEIGHT]]
    @leftColumnNumbersWrapper.center = [self.view.frame.size.width*0.25, self.view.frame.size.height/2]
    self.view.addSubview(@leftColumnNumbersWrapper)

    @leftColumnNumber = createNumber(INITIAL_VALUE, @leftColumnNumbersWrapper)
    @leftColumnNumbersWrapper.addSubview @leftColumnNumber

    # # #
    # маска
    @rightColumnMask = UIView.alloc.initWithFrame [[width_half, 0], [width_half, self.view.frame.size.height]]
    @rightColumnMask.backgroundColor = DARK_COLOR
    @rightColumnMask.alpha = 0.2
    self.view.addSubview @rightColumnMask

    @rightColumnNumbersWrapper = UIView.alloc.initWithFrame [[0, 0], [width_half, NUMBERS_WRAPPER_HEIGHT]]
    @rightColumnNumbersWrapper.center = [self.view.frame.size.width*0.75, self.view.frame.size.height/2]
    self.view.addSubview(@rightColumnNumbersWrapper)

    @rightColumnNumber = createNumber(32, @rightColumnNumbersWrapper)
    @rightColumnNumbersWrapper.addSubview @rightColumnNumber

    menuButton = UIButton.buttonWithType(UIButtonTypeCustom)
    menuButton.setBackgroundImage(UIImage.imageNamed("menu"), forState:UIControlStateNormal)
    menuButton.setBackgroundImage(UIImage.imageNamed("menu_highlighted"), forState:UIControlStateHighlighted)
    menuButton.sizeToFit

    # 10 is an offset from bottom, get it from design mockup
    menuButton.center = [self.view.frame.size.width/2, self.view.frame.size.height - (menuButton.frame.size.height/2 + 10)]
    menuButton.when(UIControlEventTouchUpInside) do
      listController = ListController.alloc.init
      listController.delegate = self
      listController.baseColor = "#48CA77".to_color
      self.presentModalViewController(listController, animated: true)
    end
    self.view.addSubview menuButton

    # Arrows
    @arrows = UIImageView.alloc.initWithImage(UIImage.imageNamed("arrows"))
    @arrows.sizeToFit
    @arrows.alpha = 0
    self.view.addSubview(@arrows)

    # ------ Handle touch moves -----------

    pgr = UIPanGestureRecognizer.alloc.initWithTarget(self, action: "handlePan:")
    self.view.addGestureRecognizer(pgr)
  end

  def handlePan(pgr)
    if pgr.state == UIGestureRecognizerStateBegan
      @initialDragCoord = pgr.locationInView(pgr.view)
      @initialValue = @leftColumnNumber.text.to_i

      if pgr.locationInView(pgr.view).x < self.view.frame.size.width/2
        @initialView = @leftColumnNumbersWrapper
      else
        @initialView = @rightColumnNumbersWrapper
      end

      animateUp(@initialView)
    end

    if pgr.state == UIGestureRecognizerStateEnded
      animateDown(@initialView)
    end

    newCoord = pgr.locationInView(pgr.view)

    deltaY = newCoord.y - @initialDragCoord.y;

    new_val =  (@initialValue - deltaY/15).round # пока хардкод
    @leftColumnNumber.text = new_val.to_s
    @rightColumnNumber.text = (new_val + 32).to_s
  end

  def animateDown(view)
    animate(view, 200, false)
  end

  def animateUp(view)
    animate(view, 0, true)
  end

  def animate(view, yPosition, up)
    @arrows.center = [view.frame.size.width/2 + view.superview.frame.origin.x, self.view.frame.size.height/2]
    UIView.animateWithDuration(0.1,
      animations: lambda {
        view.alpha = 0.0
      },
      completion: lambda { |finished|
        view.frame = [[view.frame.origin.x, yPosition], view.frame.size]
        UIView.animateWithDuration(0.1,
          animations: lambda {
            view.alpha = 1.0
            up ? @arrows.alpha = 1.0 : @arrows.alpha = 0.0
          },
          completion: nil
        )
      }
    )
  end

  def resetWithNewNumbers(x, y)
    @leftColumnNumber.text = x.to_s
    @rightColumnNumber.text = y.to_s
  end

  def animateMoving
    @animatedView.frame = [[@animatedView.frame.origin.x, 0], @animatedView.frame.size]
    UIView.beginAnimations(nil, context: nil)
    UIView.setAnimationDuration(0.1)
    @animatedView.alpha = 1.0
    UIView.commitAnimations
  end

  def createNumber(value, wrapper)
    label = UILabel.alloc.initWithFrame(wrapper.frame)
    label.center = [wrapper.frame.size.width/2, wrapper.frame.size.height/2]
    label.font = UIFont.fontWithName("HelveticaNeue-Light", size: 70)
    label.textAlignment = NSTextAlignmentCenter
    label.text = value.to_s
    label.backgroundColor = UIColor.clearColor
    label.textColor = UIColor.whiteColor
    label
  end

  def preferredStatusBarStyle
    UIStatusBarStyleLightContent
  end
end
