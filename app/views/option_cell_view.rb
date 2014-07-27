class OptionCellView < UITableViewCell
  attr_accessor :delegate, :indexPathRow, :double
  def setHighlighted(highlighted, animated: animated)
    label = self.viewWithTag(100)

    if highlighted
      runAnimation(label)
    else
      label.subviews.each { |sv| sv.removeFromSuperview }
    end
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
