class ConverterController < UIViewController
  NUMBERS_WRAPPER_HEIGHT = 169
  INITIAL_HUE = 160/360.0

  #INITIAL_COLOR = "#48CA77".to_color
  INITIAL_COLOR = UIColor.colorWithHue((160/360.0), saturation: (54/100.0), brightness: (78/100.0), alpha: 1)
  DARK_COLOR = "#3c3c3c".to_color

  INTEGER_PART_FONT_SIZE_REGULAR     = 70
  INTEGER_PART_FONT_SIZE_SCALED_DOWN = 55

  def viewDidLoad
    @pair = ListController::PAIRS[0][:single]
    # Половина ширина экраны
    width_half = self.view.frame.size.width/2
    @currentHue = INITIAL_HUE
    @currentColor = INITIAL_COLOR

    self.view.backgroundColor = @currentColor
    columnsWrapper = @columnsWrapper = UIView.alloc.initWithFrame(self.view.bounds)
    @columnsWrapper.alpha = 0
    self.view.addSubview(columnsWrapper)

    # левая колонка
    @leftColumnNumbersWrapper = UIView.alloc.initWithFrame [[0, 0], [width_half, NUMBERS_WRAPPER_HEIGHT]]
    @leftColumnNumbersWrapper.center = [self.view.frame.size.width*0.25, self.view.frame.size.height/2 - 30]
    columnsWrapper.addSubview(@leftColumnNumbersWrapper)

    @leftColumnNumber = createNumber(@pair[:x], @leftColumnNumbersWrapper)
    @leftColumnFractionNumber = createFractionNumber("0", @leftColumnNumber, @leftColumnNumbersWrapper)
    @leftColumnNumberLabel = createNumberLabel(@pair[:x_label], @leftColumnNumber, @leftColumnNumbersWrapper)

    @leftColumnNumbersWrapper.addSubview @leftColumnNumberLabel
    @leftColumnNumbersWrapper.addSubview @leftColumnNumber
    @leftColumnNumbersWrapper.addSubview @leftColumnFractionNumber

    # # #
    # маска
    @rightColumnMask = UIView.alloc.initWithFrame [[width_half, 0], [width_half, self.view.frame.size.height]]
    @rightColumnMask.backgroundColor = DARK_COLOR
    @rightColumnMask.alpha = 0.2
    columnsWrapper.addSubview @rightColumnMask

    @rightColumnNumbersWrapper = UIView.alloc.initWithFrame [[0, 0], [width_half, NUMBERS_WRAPPER_HEIGHT]]
    @rightColumnNumbersWrapper.center = [self.view.frame.size.width*0.75, self.view.frame.size.height/2 - 30]
    columnsWrapper.addSubview(@rightColumnNumbersWrapper)

    value = @pair[:y_function].call(@pair[:x]).round(2).to_s
    integer_part = value.split(".")[0]
    fraction_part = value.split(".")[1]
    @rightColumnNumber = createNumber(integer_part, @rightColumnNumbersWrapper)
    @rightColumnFractionNumber = createFractionNumber(fraction_part, @rightColumnNumber, @rightColumnNumbersWrapper)
    @rightColumnNumberLabel = createNumberLabel(@pair[:y_label], @rightColumnNumber, @rightColumnNumbersWrapper)

    @rightColumnNumbersWrapper.addSubview @rightColumnNumber
    @rightColumnNumbersWrapper.addSubview @rightColumnNumberLabel
    @rightColumnNumbersWrapper.addSubview @rightColumnFractionNumber

    menuButton = UIButton.buttonWithType(UIButtonTypeCustom)
    menuButton.setImage(UIImage.imageNamed("menu"), forState:UIControlStateNormal)
    menuButton.setImage(UIImage.imageNamed("menu_highlighted"), forState:UIControlStateHighlighted)
    menuButton.frame = [[0, 0], [120, 120]]

    # 10 is an offset from bottom, get it from design mockup
    menuButton.center = [self.view.frame.size.width/2, self.view.frame.size.height - (menuButton.frame.size.height/2 - 30)]

    menuButton.when(UIControlEventTouchUpInside) do
      listController = ListController.alloc.init
      listController.delegate = self
      listController.baseColor = @currentColor
      self.presentModalViewController(listController, animated: true)
    end
    menuButton.imageEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);

    self.view.addSubview menuButton
    @menuButton = menuButton

    # Arrows
    @arrows = UIImageView.alloc.initWithImage(UIImage.imageNamed("arrows"))
    @arrows.sizeToFit
    @arrows.alpha = 0
    columnsWrapper.addSubview(@arrows)

    # ------ Handle touch moves -----------

    pgr = CustomGestureRecognizer.alloc.initWithTarget(self, action: "handlePan:")
    columnsWrapper.addGestureRecognizer(pgr)

    # ------ Show splash screen image ------
    # Doing it to make transition from splash to actual app smooth
    @splash_view = UIImageView.alloc.initWithImage(UIImage.imageNamed("Default-568h@2x"))
    @splash_view.sizeToFit
    self.view.addSubview(@splash_view)

    resetWithPair(ListController::PAIRS[0][:single])
  end

  def viewDidAppear(animated)
    super
    auto_present_modal unless @already_auto_presented_modal
  end

  def auto_present_modal
    listController = ListController.alloc.init
    listController.delegate = self
    listController.baseColor = @currentColor
    self.presentModalViewController(listController, animated: false)
    EM.add_timer 0.1 {
      @already_auto_presented_modal = true
      @columnsWrapper.alpha = 1
      @splash_view.removeFromSuperview
    }
  end

  def handlePan(pgr)
    @downAnimationTimers ||= []
    # Start draging
    if pgr.state == UIGestureRecognizerStateBegan
      @initialDragCoord = pgr.locationInView(pgr.view)
      @initialInterationHue = @currentHue

      if pgr.locationInView(pgr.view).x < self.view.frame.size.width/2
        @initialView = @leftColumnNumbersWrapper
        @changing = :x
        @initialValue = @currentX
      else
        @initialView = @rightColumnNumbersWrapper
        @changing = :y
        @initialValue = @currentY
      end
      EM.cancel_timer @downAnimationTimers.each { |timer| EM.cancel_timer timer }
      @downAnimationTimers = []

      readyToConvert(@changing, pgr.locationInView(pgr.view).y)
    end


    newCoord = pgr.locationInView(pgr.view)
    deltaY = newCoord.y - @initialDragCoord.y;
    newVal =  (@initialValue - deltaY/15).round # пока хардкод
    newValSecond = (@changing == :x ? @pair[:y_function].call(newVal) : @pair[:x_function].call(newVal))

    if newVal.abs < 1000 && newValSecond.abs < 1000
      updateBackgroundColor(deltaY)
      updateValues(newVal, @changing)
    end

    updateArrowsPosition(newCoord.y)

    # Stop draging
    if pgr.state == UIGestureRecognizerStateEnded
      @downAnimationTimers << EM.add_timer(0.15) { animateDown }
      @changing = nil
    end
  end

  def updateBackgroundColor(deltaY)
    @currentHue = @initialInterationHue - deltaY/(self.view.frame.size.height*1.5).to_f
    @currentHue > 1 && (@currentHue = @currentHue - 1)
    @currentHue < 0 && (@currentHue = @currentHue + 1)

    @currentColor = UIColor.colorWithHue(@currentHue, saturation: (54/100.0), brightness: (78/100.0), alpha: 1)
    self.view.backgroundColor = @currentColor
  end

  def updateValues(newVal, changing)
    if changing == :x
      @currentX = newVal.to_i
      @currentY = @pair[:y_function].call(newVal)
      updateNumber(@leftColumnNumber, @leftColumnFractionNumber, @currentX)
      updateNumber(@rightColumnNumber, @rightColumnFractionNumber, @currentY)
    else
      @currentY = newVal.to_i
      @currentX = @pair[:x_function].call(newVal)
      updateNumber(@rightColumnNumber, @rightColumnFractionNumber, @currentY)
      updateNumber(@leftColumnNumber, @leftColumnFractionNumber, @currentX)
    end
  end

  def updateNumber(viewInteger, viewFraction, value)
    value = value.abs unless @pair[:degree]
    value = value.round(2).to_s
    integer_part = value.split(".")[0]
    fraction_part = value.split(".")[1]

    viewInteger.font = UIFont.fontWithName("FARRAY", size: fontSizeForInteger)

    viewInteger.text = integer_part
    viewInteger.sizeToFit
    viewInteger.center = [viewInteger.superview.frame.size.width/2, viewInteger.superview.frame.size.height/2]

    updateFractionNumber(fraction_part, viewFraction, viewInteger, viewFraction.superview)
  end

  # Font size for integer part depends on current values.
  # If absolute value of any current value
  # (currentY or currentX) is >= the font should be scaled dowb  otherwise regular
  def fontSizeForInteger
    if [@currentX.abs, @currentY.abs].any? { |i| i >= 100 }
      INTEGER_PART_FONT_SIZE_SCALED_DOWN
    else
      INTEGER_PART_FONT_SIZE_REGULAR
    end
  end

  def readyToConvert(changing, arrowsCenterY)
    self.view.layer.removeAllAnimations
    if changing == :x
      activeView, passiveView = @leftColumnNumbersWrapper, @rightColumnNumbersWrapper
    else
      passiveView, activeView = @leftColumnNumbersWrapper, @rightColumnNumbersWrapper
    end

    arrowsY = arrowsCenterY - @arrows.frame.size.height/2 + 15
    @arrows.frame = [[activeView.frame.size.width/2 + activeView.frame.origin.x - @arrows.frame.size.width/2, arrowsY], @arrows.frame.size]
    @arrows.alpha = 1.0
    activeView.frame = [[activeView.frame.origin.x, -10], activeView.frame.size]
    passiveView.frame = [[passiveView.frame.origin.x, -10], passiveView.frame.size]
  end

  def updateArrowsPosition(arrowsCenterY)
    arrowsY = arrowsCenterY - @arrows.frame.size.height/2 + 15
    arrowsY = [self.view.frame.size.height - @arrows.frame.size.height, arrowsY].min
    arrowsY = [0, arrowsY].max
    @arrows.frame = [[@arrows.frame.origin.x, arrowsY], @arrows.frame.size]
  end

  def animateDown
    @arrows.center = [view.frame.size.width/2 + view.frame.origin.x, self.view.frame.size.height/2]
    @arrows.alpha = 0.0
    yPosition = (self.view.frame.size.height/2 - 30) - @leftColumnNumbersWrapper.frame.size.height/2
    UIView.animateWithDuration(0.1,
      animations: lambda {
        @leftColumnNumbersWrapper.alpha = 0.0
        @rightColumnNumbersWrapper.alpha = 0.0
      },
      completion: lambda { |finished|
        @leftColumnNumbersWrapper.frame = [[@leftColumnNumbersWrapper.frame.origin.x, yPosition], @leftColumnNumbersWrapper.frame.size]
        @rightColumnNumbersWrapper.frame = [[@rightColumnNumbersWrapper.frame.origin.x, yPosition], @rightColumnNumbersWrapper.frame.size]
        UIView.animateWithDuration(0.2,
          animations: lambda {
            @leftColumnNumbersWrapper.alpha = 1.0
            @rightColumnNumbersWrapper.alpha = 1.0
          },
          completion: lambda { |finished|
            readyToConvert(@changing, @initialDragCoord.y) if @changing
          }
        )
      }
    )
  end

  def resetWithPair(pair)
    @pair = pair
    @currentX = @pair[:x]
    @currentY = @pair[:y_function].call(@pair[:x])

    updateNumber(@leftColumnNumber, @leftColumnFractionNumber, @currentX)
    updateNumber(@rightColumnNumber, @rightColumnFractionNumber, @currentY)

    updateNumberLabel(@pair[:x_label], @leftColumnNumberLabel, @leftColumnNumber, @leftColumnNumbersWrapper)
    updateNumberLabel(@pair[:y_label], @rightColumnNumberLabel, @rightColumnNumber, @rightColumnNumbersWrapper)

    resetViews
  end

  def resetViews
    @arrows.alpha = 0.0
    yPosition = (self.view.frame.size.height/2 - 30) - @leftColumnNumbersWrapper.frame.size.height/2
    @leftColumnNumbersWrapper.frame = [[@leftColumnNumbersWrapper.frame.origin.x, yPosition], @leftColumnNumbersWrapper.frame.size]
    @rightColumnNumbersWrapper.frame = [[@rightColumnNumbersWrapper.frame.origin.x, yPosition], @rightColumnNumbersWrapper.frame.size]
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
    label.font = UIFont.fontWithName("FARRAY", size: 70)
    label.textAlignment = NSTextAlignmentCenter
    label.text = value.to_s
    label.sizeToFit
    label.center = [wrapper.frame.size.width/2, wrapper.frame.size.height/2]
    label.backgroundColor = UIColor.clearColor
    label.textColor = UIColor.whiteColor
    label
  end

  def createFractionNumber(value, numberView, wrapper)
   view = UILabel.alloc.initWithFrame(wrapper.frame)
   view.font = UIFont.fontWithName("FARRAY", size: 18)
   view.textColor = UIColor.whiteColor
   updateFractionNumber(value, view, numberView, wrapper)
  end

  def updateFractionNumber(value, view, numberView, wrapper)
   origin_x = numberView.frame.origin.x+numberView.frame.size.width
   origin_y = numberView.frame.origin.y + numberView.frame.size.height - view.frame.size.height - (numberView.frame.size.height*0.04)
   view.frame = [[origin_x, origin_y], view.frame.size]
   view.text = "." + value.to_s
   view.sizeToFit
   view.hidden = (value.to_i <= 0)
   view
  end

  def createNumberLabel(value, numberView, wrapper)
    view = UILabel.alloc.initWithFrame( [[100, 50], [0, 0]] )
    view.font = UIFont.fontWithName("FARRAY", size: 18)
    view.textAlignment = NSTextAlignmentRight
    view.textColor = UIColor.whiteColor
    updateNumberLabel(value, view, numberView, wrapper)
  end

  def updateNumberLabel(value, view, numberView, wrapper)
    view.text = value.to_s
    view.sizeToFit
    origin_x = wrapper.frame.size.width-40-view.frame.size.width
    origin_y = numberView.frame.origin.y + numberView.frame.size.height - 75 - view.frame.size.height
    view.frame = [[origin_x, origin_y], view.frame.size]
    view
  end


  def prefersStatusBarHidden
    true
  end
end
