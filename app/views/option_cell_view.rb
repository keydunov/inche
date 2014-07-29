class OptionCellView < UITableViewCell
  attr_accessor :delegate, :indexPathRow, :double
  attr_accessor :mask, :label
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
  end

  def setMaskAlpha(maskAlpha)
    @mask = self.viewWithTag(MASK_ALPHA_TAG)
    @mask.alpha = maskAlpha
  end

  def setHighlighted(highlighted, animated: animated)
    label = self.viewWithTag(100)

    #if highlighted
    #  runAnimation(label)
    #else
    #  label.subviews.each { |sv| sv.removeFromSuperview }
    #end
  end

  def runAnimation(label)
    label.subviews.each { |sv| sv.removeFromSuperview }
    line = UIView.alloc.initWithFrame([[0, label.frame.size.height - 2], [0, 2]])
    line.backgroundColor = label.textColor
    label.addSubview(line)

    UIView.animateWithDuration(0.5,
      animations: lambda {
        line.frame = [line.frame.origin, [label.frame.size.width, 2]]
      },
      completion: lambda { |finished|
        if double
          pair = ListController::PAIRS[indexPathRow][:double]
        else
          pair = ListController::PAIRS[indexPathRow][:single] || ListController::PAIRS[indexPathRow]
        end
        delegate.showConverter(pair)
      }
    )
  end
end
