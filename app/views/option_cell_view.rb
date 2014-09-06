class OptionCellView < UITableViewCell
  attr_accessor :delegate, :indexPathRow, :double
  attr_accessor :mask, :label, :doubleIcon, :doubleIconLabel, :doubleIconLabelText, :line
  MASK_ALPHA_TAG = 101

  def addViews
    self.selectionStyle = UITableViewCellSelectionStyleNone

    @mask = UIView.alloc.initWithFrame([[0, 0], self.frame.size])
    @mask.backgroundColor = ListController::DARK_COLOR_STRING.to_color
    @mask.tag = MASK_ALPHA_TAG
    self.addSubview(@mask)

    @label = UILabel.alloc.initWithFrame(CGRectZero)
    @label.font = UIFont.fontWithName("FARRAY", size: 18)
    @label.tag = 100
    self.addSubview(@label)

    @line = UIView.alloc.initWithFrame(CGRectZero)
    line.backgroundColor = label.textColor
    line.hidden = true
    @label.addSubview(line)


    @doubleIcon = UIButton.buttonWithType(UIButtonTypeCustom)
    @doubleIcon.frame = [[0, 0], [self.frame.size.height, 80]]
    @doubleIcon.center = [self.frame.size.width - doubleIcon.frame.size.width/2, self.frame.size.height/2]

    @doubleIconLabel = UIView.alloc.initWithFrame([[0, 0], [43, 43]])
    doubleIconLabel.center = [doubleIcon.frame.size.width/2, doubleIcon.frame.size.height/2 + 2]
    doubleIconLabel.layer.cornerRadius = 21.5;
    doubleIconLabel.layer.borderWidth = 3;
    doubleIcon.addSubview(doubleIconLabel)

    @doubleIconLabelText = UILabel.alloc.initWithFrame([[0, 0], doubleIconLabel.frame.size])
    doubleIconLabelText.center = [doubleIcon.frame.size.width/2, doubleIcon.frame.size.height/2]
    doubleIconLabelText.text = "×2"
    doubleIconLabelText.font = UIFont.fontWithName("FARRAY", size: 21)
    doubleIconLabelText.textAlignment = NSTextAlignmentCenter
    doubleIcon.addSubview doubleIconLabelText

    doubleIconLabelText.userInteractionEnabled = false
    doubleIconLabel.userInteractionEnabled = false

    self.addSubview(@doubleIcon)
  end

  def touchesBegan(touches, withEvent: event)
    super
  end

  def touchesEnded(touches, withEvent: event)
    super
    delegate.showConverter(ListController::PAIRS[indexPathRow][:single] || ListController::PAIRS[indexPathRow])
  end

  def setHighlighted(highlighted, animated:animated)
    self.line.hidden = !highlighted
    super
  end
end
