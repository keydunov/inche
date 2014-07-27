class ConverterController < UIViewController
  NUMBERS_WRAPPER_HEIGHT = 169
  INITIAL_HUE = 142/360.0

  #INITIAL_COLOR = "#48CA77".to_color
  INITIAL_COLOR = UIColor.colorWithHue((142/360.0), saturation: (64/100.0), brightness: (79/100.0), alpha: 1)
  DARK_COLOR = "#3c3c3c".to_color

  def viewDidLoad
    @pair = ListController::PAIRS[0][:single]
    # Половина ширина экраны
    width_half = self.view.frame.size.width/2
    @currentHue = INITIAL_HUE
    @currentColor = INITIAL_COLOR

    self.view.backgroundColor = @currentColor
    columnsWrapper = UIView.alloc.initWithFrame(self.view.bounds)
    self.view.addSubview(columnsWrapper)

    # левая колонка
    @leftColumnNumbersWrapper = UIView.alloc.initWithFrame [[0, 0], [width_half, NUMBERS_WRAPPER_HEIGHT]]
    @leftColumnNumbersWrapper.center = [self.view.frame.size.width*0.25, self.view.frame.size.height/2]
    columnsWrapper.addSubview(@leftColumnNumbersWrapper)

    @leftColumnNumber = createNumber(@pair[:x], @leftColumnNumbersWrapper)

    @leftColumnNumberLabel = UILabel.alloc.initWithFrame( [[100, 50], [0, 0]] )
    @leftColumnNumberLabel.font = UIFont.fontWithName("HelveticaNeue-Regular", size: 18)
    @leftColumnNumberLabel.textAlignment = NSTextAlignmentRight
    @leftColumnNumberLabel.text = @pair[:x_label].to_s
    @leftColumnNumberLabel.sizeToFit

    origin_x = @leftColumnNumbersWrapper.frame.size.width-32.5-@leftColumnNumberLabel.frame.size.width
    origin_y = @leftColumnNumber.frame.origin.y + @leftColumnNumber.frame.size.height - 75 - @leftColumnNumberLabel.frame.size.height

    @leftColumnNumberLabel.frame = [[origin_x, origin_y], @leftColumnNumberLabel.frame.size]
    @leftColumnNumberLabel.textColor = UIColor.whiteColor
    @leftColumnNumbersWrapper.addSubview(@leftColumnNumberLabel)

    @leftColumnNumbersWrapper.addSubview @leftColumnNumber

    # # #
    # маска
    @rightColumnMask = UIView.alloc.initWithFrame [[width_half, 0], [width_half, self.view.frame.size.height]]
    @rightColumnMask.backgroundColor = DARK_COLOR
    @rightColumnMask.alpha = 0.2
    columnsWrapper.addSubview @rightColumnMask

    @rightColumnNumbersWrapper = UIView.alloc.initWithFrame [[0, 0], [width_half, NUMBERS_WRAPPER_HEIGHT]]
    @rightColumnNumbersWrapper.center = [self.view.frame.size.width*0.75, self.view.frame.size.height/2]
    columnsWrapper.addSubview(@rightColumnNumbersWrapper)

    @rightColumnNumber = createNumber(@pair[:y_function].call(@pair[:x]).round(1), @rightColumnNumbersWrapper)
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
      listController.baseColor = @currentColor
      self.presentModalViewController(listController, animated: true)
    end
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
  end

  def handlePan(pgr)
    # Start draging
    if pgr.state == UIGestureRecognizerStateBegan
      @initialDragCoord = pgr.locationInView(pgr.view)
      @initialInterationHue = @currentHue

      if pgr.locationInView(pgr.view).x < self.view.frame.size.width/2
        @initialView = @leftColumnNumbersWrapper
        @changing = :x
        @initialValue = @leftColumnNumber.text.to_i
      else
        @initialView = @rightColumnNumbersWrapper
        @changing = :y
        @initialValue = @rightColumnNumber.text.to_i
      end

      animateUp(@initialView)
    end

    # Stop draging
    if pgr.state == UIGestureRecognizerStateEnded
      animateDown(@initialView)
    end

    newCoord = pgr.locationInView(pgr.view)

    deltaY = newCoord.y - @initialDragCoord.y;

    unless @leftColumnNumber.text.to_i == 0 && deltaY > 0
      updateBackgroundColor(deltaY)

      new_val =  (@initialValue - deltaY/15).round # пока хардкод
      updateValues(new_val, @changing)
    end
  end

  def updateBackgroundColor(deltaY)
    @currentHue = @initialInterationHue - deltaY/(self.view.frame.size.height*1.5).to_f
    @currentHue > 1 && (@currentHue = @currentHue - 1)
    @currentHue < 0 && (@currentHue = @currentHue + 1)

    @currentColor = UIColor.colorWithHue(@currentHue, saturation: (64/100.0), brightness: (79/100.0), alpha: 1)
    self.view.backgroundColor = @currentColor
  end

  def updateValues(newVal, changing)
    if changing == :x
      updateNumber(@leftColumnNumber, nil, newVal)
      updateNumber(@rightColumnNumber, nil, @pair[:y_function].call(newVal))
    else
      updateNumber(@rightColumnNumber, nil, newVal)
      updateNumber(@leftColumnNumber, nil, @pair[:x_function].call(newVal))
    end
  end

  def updateNumber(viewInteger, viewFraction, value)
    value = value.round(2).to_s
    integer_part = value.split(".")[0]
    fraction_part = value.split(".")[1]

    viewInteger.text = integer_part
    viewInteger.sizeToFit
    viewInteger.center = [viewInteger.superview.frame.size.width/2, viewInteger.superview.frame.size.height/2]
  end

  def animateDown(view)
    animate(view, 200, false)
  end

  def animateUp(view)
    animate(view, 0, true)
  end

  def animate(view, yPosition, up)
    @arrows.center = [view.frame.size.width/2 + view.frame.origin.x, self.view.frame.size.height/2]
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

  def resetWithPair(pair)
    @pair = pair
    @leftColumnNumber.text = @pair[:x].to_s
    @rightColumnNumber.text = @pair[:y_function].call(@pair[:x]).round(1).to_s
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
    label.font = UIFont.fontWithName("HelveticaNeue-Light", size: 70)
    label.textAlignment = NSTextAlignmentCenter
    label.text = value.to_s
    label.sizeToFit
    label.center = [wrapper.frame.size.width/2, wrapper.frame.size.height/2]
    label.backgroundColor = UIColor.clearColor
    label.textColor = UIColor.whiteColor
    label
  end

  def preferredStatusBarStyle
    UIStatusBarStyleLightContent
  end
end
