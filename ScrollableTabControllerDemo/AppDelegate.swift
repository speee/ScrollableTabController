//
//  AppDelegate.swift
//  ScrollableTabControllerDemo
//
//  Created by mitsuyoshi.yamazaki on 2017/07/31.
//  Copyright © 2017年 Mitsuyoshi Yamazaki and Speee, Inc. All rights reserved.
//

import UIKit
import ScrollableTabController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    window = UIWindow(frame: UIScreen.main.bounds)
    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
    
    // Setup content ViewControllers
    let timelineViewController = storyboard.instantiateViewController(withIdentifier: "TimelineViewController") as! TimelineViewController
    timelineViewController.title = "Timeline"
    timelineViewController.cellIdentifier = .normal
    
    let imageTimelineViewController = storyboard.instantiateViewController(withIdentifier: "TimelineViewController") as! TimelineViewController
    imageTimelineViewController.title = "Media"
    imageTimelineViewController.cellIdentifier = .image
    
    let upperContentViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
    
    // Setup ScrollableTabController
    let scrollableTabController = ScrollableTabController()
    scrollableTabController.viewControllers = [ timelineViewController, imageTimelineViewController ]
    scrollableTabController.upperContentViewController = upperContentViewController
    
    let navigationController = UINavigationController.init(rootViewController: scrollableTabController)
    navigationController.navigationBar.isTranslucent = false
    
    window!.rootViewController = navigationController
    window!.makeKeyAndVisible()

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
  }

  func applicationWillTerminate(_ application: UIApplication) {
  }
}

extension UITableViewController: Scrollable {
  public var scrollView: UIScrollView! {
    return tableView
  }
}

class ExpandedTableView: UITableView {
  override var contentSize: CGSize {
    set {
      let size = CGSize.init(width: newValue.width, height: max(newValue.height, minimumContentHeight))
      super.contentSize = size
    }
    get {
      return super.contentSize
    }
  }
  
  var minimumContentHeight: CGFloat {
    return frame.height
  }
}
