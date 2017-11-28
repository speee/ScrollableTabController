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
  
  @IBOutlet private weak var blurEffectView: UIVisualEffectView!
  @IBOutlet private weak var imageHeightConstraint: NSLayoutConstraint!
  
  // MARK: - Lifecycle
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { 
      self.imageHeightConstraint.constant *= 1.5
    }
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
