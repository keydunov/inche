class CustomGestureRecognizer < UIPanGestureRecognizer
  def touchesBegan(touches, withEvent: event)
    super
    self.state = UIGestureRecognizerStateBegan
  end
end
