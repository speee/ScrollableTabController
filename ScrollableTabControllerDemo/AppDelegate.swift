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

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    window = UIWindow(frame: UIScreen.main.bounds)
    
    let scrollableTabController = ScrollableTabController()

    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
    let demoTableViewController1 = storyboard.instantiateViewController(withIdentifier: "DemoTableViewController") as! UITableViewController
    let demoTableViewController2 = storyboard.instantiateViewController(withIdentifier: "DemoTableViewController") as! UITableViewController

    demoTableViewController1.title = "TableView 1"
    demoTableViewController2.title = "TableView 2"
    
    let upperContentViewController = storyboard.instantiateViewController(withIdentifier: "UpperContentViewController")
    
    scrollableTabController.viewControllers = [ demoTableViewController1, demoTableViewController2 ]
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
