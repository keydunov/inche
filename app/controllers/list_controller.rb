class ListController < UIViewController
  attr_accessor :delegate, :baseColor

  DARK_COLOR_STRING = "#3c3c3c"

  PAIRS = [
    {
      name: "INCH ‹› CENTIMETER",
      single: { x: 1, x_function: ->(y) { 0.39370078740157*y }, y_function: ->(x) { 2.54000000000003*x }, x_label: "in", y_label: "cm" },
      double: { x: 1, x_function: ->(y) { 0.15500031000062*y }, y_function: ->(x) { 6.4516*x }, x_label: "sq in", y_label: "sq cm" }
    },
    {
      name: "MILE ‹› KILOMETRE",
      single: { x: 1, x_function: ->(y) { 0.62137119223733*y }, y_function: ->(x) { 1.609344*x }, x_label: "mi", y_label: "km" },
      double: { x: 1, x_function: ->(y) { 0.38610215854245*y }, y_function: ->(x) { 2.589988110336*x }, x_label: "sq mi", y_label: "sq km" }
    },
    {
      name: "FOOT ‹› METER",
      single: { x: 1, x_function: ->(y) { 3.28084*y }, y_function: ->(x) { 0.3048*x }, x_label: "ft", y_label: "m" },
      double: { x: 1, x_function: ->(y) { 10.7639*y }, y_function: ->(x) { 0.092903*x }, x_label: "sq ft", y_label: "sq m" }
    },
    { name: "CELSIUS ‹› FAHRENHEIT",
      x: 27, y_function: ->(x) { (x-32)*(5/9) }, x_function: ->(y) { (y*(9/5)) + 32 }, degree: true },

    { name: "POUND ‹› KILOGRAM",
      x: 1, y_function: ->(x) { x * 0.453592 }, x_function: ->(y) { y*2.20462 }, x_label: "lb", y_label: "kg" },

    { name: "OUNCE ‹› GRAM",
      x: 1, y_function: ->(x) { x * 28.349523125 }, x_function: ->(y) { y*0.03527396194 }, x_label: "oz", y_label: "gr" },
    { name: "ACRE ‹› HECTARE",
      x: 1, y_function: ->(x) { x * 0.40468564224 }, x_function: ->(y) { y*2.4710538146717 }, x_label: "acre", y_label: "ha" },
  ]

  def viewDidLoad
    self.edgesForExtendedLayout = UIRectEdgeNone

    tableFrame = [[0, 20], [self.view.size.width, self.view.size.height - 20]]
    @table = UITableView.alloc.initWithFrame(self.view.bounds, style: UITableViewStylePlain)

    @table.delegate = self
    @table.dataSource = self
    @table.separatorStyle = UITableViewCellSeparatorStyleNone
    @table.alwaysBounceVertical = false

    self.view.addSubview(@table)
  end

  def tableView(tableView, numberOfRowsInSection: section)
    PAIRS.size
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    @table.frame.size.height/7
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuse_identifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier) || begin
      OptionCellView.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuse_identifier)
    end

    cell.frame = [cell.frame.origin, [@table.frame.size.width, self.view.frame.size.height/7]]

    if indexPath.row == 0
      cell.backgroundColor = DARK_COLOR_STRING.to_color
      cell.alpha = 1.0
    else
      mask = UIView.alloc.initWithFrame(cell.bounds)
      mask.backgroundColor = DARK_COLOR_STRING.to_color
      mask.alpha = 0.1 * (indexPath.row - 1)
      cell.addSubview(mask)
      cell.backgroundColor = @baseColor
    end

    label = UILabel.alloc.initWithFrame(CGRectZero)
    label.font = UIFont.fontWithName("HelveticaNeue-Medium", size: 20)
    attributedString = NSMutableAttributedString.alloc.initWithString(PAIRS[indexPath.row][:name])
    attributedString.addAttribute(NSKernAttributeName, value: 1.4, range: NSMakeRange(0,9))
    label.attributedText = attributedString
    label.sizeToFit
    label.frame = [[30, cell.frame.size.height/2 - label.frame.size.height/2], [label.frame.size.width, label.frame.size.height + 2]]
    label.tag = 100

    if indexPath.row == 0
      label.textColor = @baseColor
    else
      label.textColor = UIColor.whiteColor
    end

    cell.addSubview(label)

    if PAIRS[indexPath.row][:double]
      #TODO: extract into helper method
      color = (indexPath.row == 0 ? @baseColor : UIColor.whiteColor)

      doubleIcon = UIButton.buttonWithType(UIButtonTypeCustom)
      doubleIcon.frame = [[0, 0], [32, 32]]
      doubleIcon.layer.cornerRadius = 16;
      doubleIcon.layer.borderWidth = 2;
      doubleIcon.layer.borderColor = color.CGColor

      doubleIconLabel = UILabel.alloc.initWithFrame(doubleIcon.frame)
      doubleIconLabel.text = "2x"
      doubleIconLabel.sizeToFit
      doubleIconLabel.center = [doubleIcon.frame.size.width/2, doubleIcon.frame.size.height/2]
      doubleIconLabel.color = color
      doubleIconLabel.textAlignment = NSTextAlignmentCenter
      doubleIconLabel.font = UIFont.fontWithName("HelveticaNeue-Light", size: 16)
      doubleIcon.addSubview(doubleIconLabel)

      doubleIcon.center = [cell.frame.size.width - doubleIcon.frame.size.width/2 - 30, cell.frame.size.height/2]
      doubleIcon.when(UIControlEventTouchUpInside) do
        showConverter(PAIRS[indexPath.row][:double])
      end
      cell.addSubview(doubleIcon)
    end

    cell.selectionStyle = UITableViewCellSelectionStyleNone

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    showConverter(PAIRS[indexPath.row][:single] || PAIRS[indexPath.row])
  end

  def showConverter(pair)
    self.delegate.resetWithPair(pair)
    self.dismissModalViewControllerAnimated(true)
  end
end
