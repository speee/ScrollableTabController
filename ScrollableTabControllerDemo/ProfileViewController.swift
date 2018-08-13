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

class ProfileViewController: UIViewController, UpperContent {

  let maximumHeight: CGFloat = 266.0

  @IBOutlet private weak var blurEffectView: UIVisualEffectView!
  
  // MARK: - Lifecycle
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let defaultHeight: CGFloat = 266.0
    let minimumHeight: CGFloat = 64.0
    let transparency = min((view.frame.height - minimumHeight) / (defaultHeight - minimumHeight), 1.0)
    
    blurEffectView?.alpha = CGFloat(1.0) - transparency
  }
}
