class ListController < UIViewController
  def viewDidLoad
    self.view.backgroundColor = UIColor.redColor

    @table = UITableView.alloc.initWithFrame(self.view.bounds, style: UITableViewStylePlain)

    @table.delegate = self
    @table.dataSource = self

    self.view.addSubview(@table)
  end

  def tableView(tableView, numberOfRowsInSection: section)
    10
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    self.dismissModalViewControllerAnimated(true)
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuse_identifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuse_identifier)
    end

    cell
  end
end
