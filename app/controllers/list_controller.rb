class ListController < UIViewController
  DARK_COLOR_STRING = "#3c3c3c"

  def viewDidLoad
    self.view.backgroundColor = UIColor.redColor
    @baseColor = "#48CA77"

    @table = UITableView.alloc.initWithFrame(self.view.bounds, style: UITableViewStylePlain)

    @table.delegate = self
    @table.dataSource = self
    @table.separatorStyle = UITableViewCellSeparatorStyleNone

    self.view.addSubview(@table)
  end

  def tableView(tableView, numberOfRowsInSection: section)
    7
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    self.view.frame.size.height/7
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    self.dismissModalViewControllerAnimated(true)
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuse_identifier ||= "CELL_IDENTIFIER"
    # 3c3c3c

    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuse_identifier)
    end

    #cell.textLabel.text = "Title"
    #cell.textLabel.textColor = UIColor.whiteColor

    cell.frame = [cell.frame.origin, [@table.frame.size.width, self.view.frame.size.height/7]]
    if indexPath.row == 0
      cell.backgroundColor = DARK_COLOR_STRING.to_color
    else
      mask = UIView.alloc.initWithFrame(cell.bounds)
      mask.backgroundColor = DARK_COLOR_STRING.to_color
      mask.alpha = 0.1 * (indexPath.row - 1)
      cell.addSubview(mask)
      cell.backgroundColor = @baseColor.to_color
    end

    cell
  end
end
