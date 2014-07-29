class OptionCellView < UITableViewCell
  attr_accessor :delegate, :indexPathRow, :double
  attr_accessor :mask, :label, :doubleIcon, :doubleIconLabel
  MASK_ALPHA_TAG = 101

  def addViews
    @mask = UIView.alloc.initWithFrame([[0, 0], self.frame.size])
    @mask.backgroundColor = ListController::DARK_COLOR_STRING.to_color
    @mask.tag = MASK_ALPHA_TAG
    self.addSubview(@mask)

    @label = UILabel.alloc.initWithFrame(CGRectZero)
    @label.font = UIFont.fontWithName("HelveticaNeue-Medium", size: 20)
    @label.tag = 100
    self.addSubview(@label)


    @doubleIcon = UIButton.buttonWithType(UIButtonTypeCustom)
    @doubleIcon.frame = [[0, 0], [self.frame.size.height, 80]]
    @doubleIcon.center = [self.frame.size.width - doubleIcon.frame.size.width/2, self.frame.size.height/2]

    @doubleIconLabel = UILabel.alloc.initWithFrame([[0, 0], [43, 43]])
    doubleIconLabel.text = "×2"
    doubleIconLabel.font = UIFont.fontWithName("HelveticaNeue-Medium", size: 21)
    doubleIconLabel.center = [doubleIcon.frame.size.width/2, doubleIcon.frame.size.height/2 - 1]
    doubleIconLabel.textAlignment = NSTextAlignmentCenter

    doubleIconLabel.layer.cornerRadius = 21.5;
    doubleIconLabel.layer.borderWidth = 2;

    @doubleIcon.addSubview(doubleIconLabel)

    self.addSubview(@doubleIcon)
  end

  def setMaskAlpha(maskAlpha)
    @mask = self.viewWithTag(MASK_ALPHA_TAG)
    @mask.alpha = maskAlpha
  end

  def setHighlighted(highlighted, animated: animated)
    if highlighted
      @line ||= begin
        line = UIView.alloc.initWithFrame([[0, label.frame.size.height - 2], [label.frame.size.width, 2]])
        line.backgroundColor = label.textColor
        @label.addSubview(line)
        line
      end
      @line.alpha = 1.0
    else
      @line.alpha = 0.0 if @line
    end
  end
end
