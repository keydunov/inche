class ConverterController < UIViewController
  NUMBERS_WRAPPER_HEIGHT = 169
  INITIAL_VALUE = 0


  def viewDidLoad

    # Половина ширина экраны
    width_half = self.view.frame.size.width/2

    # левая колонка
    @leftColumn = UIView.alloc.initWithFrame [[0, 0], [width_half, self.view.frame.size.height]]
    @leftColumn.backgroundColor = "#48CA77".to_color

    @leftColumnNumbersWrapper = UIView.alloc.initWithFrame [[0, 0], [@leftColumn.frame.size.width, NUMBERS_WRAPPER_HEIGHT]]
    @leftColumnNumbersWrapper.center = [@leftColumn.frame.size.width/2, @leftColumn.frame.size.height/2]
    @leftColumn.addSubview(@leftColumnNumbersWrapper)

    @leftColumnNumber = createNumber(INITIAL_VALUE, @leftColumnNumbersWrapper)
    @leftColumnNumbersWrapper.addSubview @leftColumnNumber


    # # #
    # правая колонка
    @rightColumn = UIView.alloc.initWithFrame [[width_half, 0], [width_half, self.view.frame.size.height]]
    @rightColumn.backgroundColor = "#45AD6B".to_color

    @rightColumnNumbersWrapper = UIView.alloc.initWithFrame [[0, 0], [@rightColumn.frame.size.width, NUMBERS_WRAPPER_HEIGHT]]
    @rightColumnNumbersWrapper.center = [@rightColumn.frame.size.width/2, @rightColumn.frame.size.height/2]
    @rightColumn.addSubview(@rightColumnNumbersWrapper)

    @rightColumnNumber = createNumber(32, @rightColumnNumbersWrapper)
    @rightColumnNumbersWrapper.addSubview @rightColumnNumber

    self.view.addSubview @leftColumn
    self.view.addSubview @rightColumn

    menuButton = UIButton.buttonWithType(UIButtonTypeCustom)
    menuButton.setBackgroundImage(UIImage.imageNamed("menu"), forState:UIControlStateNormal)
    menuButton.sizeToFit

    # 10 is an offset from bottom, get it from design mockup
    menuButton.center = [self.view.frame.size.width/2, self.view.frame.size.height - (menuButton.frame.size.height/2 + 10)]
    menuButton.when(UIControlEventTouchUpInside) do
      App.alert("tapped")
    end
    self.view.addSubview menuButton

    # Arrows
    @arrows = UIImageView.alloc.initWithImage(UIImage.imageNamed("arrows"))
    @arrows.sizeToFit
    @arrows.alpha = 0
    self.view.addSubview(@arrows)

    # ------ Handle touch moves -----------

    pgr = UIPanGestureRecognizer.alloc.initWithTarget(self, action: "handlePan:")
    tgr = UIPanGestureRecognizer.alloc.initWithTarget(self, action: "handleTap:")
    self.view.addGestureRecognizer(pgr)
  end

  def handleTap(tgr)
    puts "lol"
  end

  def handlePan(pgr)
    if pgr.state == UIGestureRecognizerStateBegan
      @initialDragCoord = pgr.locationInView(pgr.view)
      @initialValue = @leftColumnNumber.text.to_i

      if pgr.locationInView(pgr.view).x < self.view.frame.size.width/2
        animateUp(@leftColumnNumbersWrapper)
      else
        animateUp(@rightColumnNumbersWrapper)
      end
    end

    if pgr.state == UIGestureRecognizerStateEnded
      if pgr.locationInView(pgr.view).x < self.view.frame.size.width/2
        animateDown(@leftColumnNumbersWrapper)
      else
        animateDown(@rightColumnNumbersWrapper)
      end
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
    puts view.frame.origin.x
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
