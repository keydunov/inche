class CustomGestureRecognizer < UIPanGestureRecognizer
  def touchesBegan(touches, withEvent: event)
    super
    self.state = UIGestureRecognizerStateBegan
  end

  def touchesEnded(touches, withEvent: event)
    super
    self.state = UIGestureRecognizerStateEnded
  end
end
