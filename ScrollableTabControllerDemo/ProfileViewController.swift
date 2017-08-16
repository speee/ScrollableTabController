//
//  ProfileViewController.swift
//  ScrollableTabController
//
//  Created by mitsuyoshi.yamazaki on 2017/08/16.
//  Copyright © 2017年 Mitsuyoshi Yamazaki and Speee, Inc. All rights reserved.
//

import UIKit
import Social
import ScrollableTabController

class ProfileViewController: UIViewController {
  
  @IBOutlet private weak var coverImageView: UIImageView!
  @IBOutlet private weak var iconImageView: UIImageView! {
    didSet {
      iconImageView.layer.borderWidth = 4.0
      iconImageView.layer.borderColor = UIColor.white.cgColor
      iconImageView.layer.cornerRadius = iconImageView.bounds.size.width / 2.0
    }
  }
  @IBOutlet private weak var screenNameLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
}

extension ProfileViewController: ShrinkableContent {
  var minimumHeight: CGFloat? {
    return 64.0
  }
}
