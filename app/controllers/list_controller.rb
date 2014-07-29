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
      x: 27, y_function: ->(x) { (x*9/5) + 32 }, x_function: ->(y) { (y-32)*5/9 }, degree: true, x_label: "°C", y_label: "°F" },

    { name: "POUND ‹› KILOGRAM",
      x: 1, y_function: ->(x) { x * 0.453592 }, x_function: ->(y) { y*2.20462 }, x_label: "lb", y_label: "kg" },

    { name: "OUNCE ‹› GRAM",
      x: 1, y_function: ->(x) { x * 28.349523125 }, x_function: ->(y) { y*0.03527396194 }, x_label: "oz", y_label: "gr" },
    { name: "ACRE ‹› HECTARE",
      x: 1, y_function: ->(x) { x * 0.40468564224 }, x_function: ->(y) { y*2.4710538146717 }, x_label: "acre", y_label: "ha" },
  ]

  def viewDidLoad
    super
    self.edgesForExtendedLayout = UIRectEdgeNone

    tableFrame = [[0, 0], [self.view.size.width, self.view.size.height]]
    @table = UITableView.alloc.initWithFrame(self.view.bounds, style: UITableViewStylePlain)

    @table.delegate = self
    @table.dataSource = self
    @table.separatorStyle = UITableViewCellSeparatorStyleNone
    @table.alwaysBounceVertical = false
    @table.backgroundColor = DARK_COLOR_STRING.to_color

    @table.contentInset = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
    @table.showsVerticalScrollIndicator = false

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
      newCell = OptionCellView.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuse_identifier)
      newCell.frame = [newCell.frame.origin, [@table.frame.size.width, self.view.frame.size.height/PAIRS.size]]
      newCell.addViews
      newCell
    end

    cell.delegate = self
    cell.indexPathRow = indexPath.row

    attributedString = NSMutableAttributedString.alloc.initWithString(PAIRS[indexPath.row][:name])
    attributedString.addAttribute(NSKernAttributeName, value: 1.4, range: NSMakeRange(0,9))
    cell.label.attributedText = attributedString
    cell.label.sizeToFit
    cell.label.frame = [[16, cell.frame.size.height/2 - cell.label.frame.size.height/2], [cell.label.frame.size.width, cell.label.frame.size.height + 2]]

    if indexPath.row == 0
      cell.backgroundColor = DARK_COLOR_STRING.to_color
      cell.mask.alpha = 0
      cell.label.textColor = @baseColor
    else
      cell.backgroundColor = @baseColor
      cell.mask.alpha = 0.1 * (indexPath.row - 1)
      cell.label.textColor = UIColor.whiteColor
    end

    if PAIRS[indexPath.row][:double]
      #TODO: extract into helper method
      color = (indexPath.row == 0 ? @baseColor : UIColor.whiteColor)

      doubleIcon = UIButton.buttonWithType(UIButtonTypeCustom)
      doubleIcon.frame = [[0, 0], [cell.frame.size.height, 80]]
      doubleIcon.center = [cell.frame.size.width - doubleIcon.frame.size.width/2, cell.frame.size.height/2]

      doubleIconLabel = UILabel.alloc.initWithFrame([[0, 0], [43, 43]])
      doubleIconLabel.text = "×2"
      doubleIconLabel.font = UIFont.fontWithName("HelveticaNeue-Medium", size: 21)
      doubleIconLabel.center = [doubleIcon.frame.size.width/2, doubleIcon.frame.size.height/2 - 1]
      doubleIconLabel.color = color
      doubleIconLabel.textAlignment = NSTextAlignmentCenter

      doubleIconLabel.layer.cornerRadius = 21.5;
      doubleIconLabel.layer.borderWidth = 2;
      doubleIconLabel.layer.borderColor = color.CGColor


      doubleIcon.addSubview(doubleIconLabel)

      doubleIcon.when(UIControlEventTouchUpInside) do
        showConverter(PAIRS[indexPath.row][:double])
      end

      doubleIcon.when(UIControlEventTouchDown) do
        doubleIcon.layer.cornerRadius = 0;
        doubleIconLabel.frame = [doubleIcon.origin, [53, 53]]
        doubleIconLabel.layer.cornerRadius = 0;
        doubleIconLabel.center = [doubleIcon.frame.size.width/2, doubleIcon.frame.size.height/2 - 1]

        cell = @table.cellForRowAtIndexPath(indexPath)
        cell.double = true
        cell.runAnimation(cell.viewWithTag(100))
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

  def prefersStatusBarHidden
    true
  end

  #def tableView(tableView, heightForHeaderInSection: section)
  #  1
  #end

  #def tableView(tableView, viewForHeaderInSection: section)
  #  view = UIView.alloc.initWithFrame([[0, 0], [tableView.bounds.size.width, 1]])
  #  #view.backgroundColor = DARK_COLOR_STRING.to_color
  #  view.backgroundColor = UIColor.redColor
  #  view
  #end
end
