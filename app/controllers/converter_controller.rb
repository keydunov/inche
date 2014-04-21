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


    # ------ Handle touch moves -----------

    pgr = UIPanGestureRecognizer.alloc.initWithTarget(self, action: "handlePan:")
    self.view.addGestureRecognizer(pgr)
  end

  def handlePan(pgr)
    if pgr.state == UIGestureRecognizerStateBegan
      @initialDragCoord = pgr.locationInView(pgr.view)
      @initialValue = @leftColumnNumber.text.to_i
    end

    newCoord = pgr.locationInView(pgr.view)

    deltaY = newCoord.y - @initialDragCoord.y;

    new_val =  (@initialValue - deltaY/15).round # пока хардкод
    @leftColumnNumber.text = new_val.to_s
    @rightColumnNumber.text = (new_val + 32).to_s
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
