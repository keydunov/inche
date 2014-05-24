class OptionCellView < UITableViewCell
  def setHighlighted(highlighted, animated: animated)
    label = self.viewWithTag(100)

    if highlighted
      line = UIView.alloc.initWithFrame([[0, label.frame.size.height - 2], [0, 2]])
      line.backgroundColor = label.textColor
      label.addSubview(line)

      UIView.animateWithDuration(0.5,
        animations: lambda {
          line.frame = [line.frame.origin, [label.frame.size.width, 2]]
        },
        completion: nil
      )
    else
      label.subviews.each { |sv| sv.removeFromSuperview }
    end

  end
end
