class ListController < UIViewController
  attr_accessor :delegate, :baseColor

  DARK_COLOR_STRING = "#3c3c3c"

  OPTIONS = [
    { name: "INCH ‹› CENTIMETER", has_double: true },
    { name: "MILE ‹› KILOMETRE", has_double: true },
    { name: "FOOT ‹› METER", has_double: true },
    { name: "CELSIUS ‹› FAHRENHEIT" },
    { name: "POUND ‹› KILOGRAM" },
    { name: "OUNCE ‹› GRAM" },
    { name: "ACRE ‹› HECTARE"}
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
    OPTIONS.size
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
    attributedString = NSMutableAttributedString.alloc.initWithString(OPTIONS[indexPath.row][:name])
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

    if OPTIONS[indexPath.row][:has_double]
      iconName = indexPath.row == 0 ? "double_top" : "double"
      doubleIcon = UIImageView.alloc.initWithImage(UIImage.imageNamed(iconName))
      doubleIcon.sizeToFit
      doubleIcon.center = [cell.frame.size.width - doubleIcon.frame.size.width/2 - 30, cell.frame.size.height/2]
      cell.addSubview(doubleIcon)
    end

    cell.selectionStyle = UITableViewCellSelectionStyleNone

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    self.delegate.resetWithNewNumbers(0, 32)
    self.dismissModalViewControllerAnimated(true)
  end
end
