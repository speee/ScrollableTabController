//
//  TimelineViewController.swift
//  ScrollableTabController
//
//  Created by mitsuyoshi.yamazaki on 2017/08/17.
//  Copyright © 2017年 Mitsuyoshi Yamazaki and Speee, Inc. All rights reserved.
//

import UIKit

class TimelineViewController: UITableViewController {
  enum CellIdentifier: String {
    case normal = "Cell"
    case image  = "ImageCell"
  }
  
  var cellIdentifier = CellIdentifier.normal
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    switch cellIdentifier {
    case .normal:
      tableView.rowHeight = 108.0 / 375.0 * view.frame.width
    case .image:
      tableView.rowHeight = 286.0 / 375.0 * view.frame.width
    }
  }

  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 20
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue, for: indexPath)
    return cell
  }
}
