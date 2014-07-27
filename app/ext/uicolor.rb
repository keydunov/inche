class UIColor
  def to_uiimage
    rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
    UIGraphicsBeginImageContext(rect.size)
    context = UIGraphicsGetCurrentContext()

    CGContextSetFillColorWithColor(context, self.CGColor)
    CGContextFillRect(context, rect)

    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    image
  end
end
