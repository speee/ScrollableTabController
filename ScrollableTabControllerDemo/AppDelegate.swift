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

    scrollableTabController.viewControllers = [ demoTableViewController1, demoTableViewController2 ]

    window!.rootViewController = scrollableTabController
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
