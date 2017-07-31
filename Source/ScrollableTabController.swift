//
//  ScrollableTabController.swift
//  ScrollableTabController
//
//  Created by Mitsuyoshi Yamazaki on 2017/07/28.
//  Copyright © 2017年 Mitsuyoshi Yamazaki and Speee, Inc. All rights reserved.
//

import UIKit

protocol Scrollable {
  var scrollView: UIScrollView! { get }
}

final class ScrollableTabController: UIViewController {

  // MARK: - Public API
  var viewControllers: [UIViewController] = [] {
    willSet {
      for controller in viewControllers {
        if controller.isViewLoaded {
          controller.view.removeFromSuperview()
        }
        controller.willMove(toParentViewController: nil)
        controller.removeFromParentViewController()
      }
    }
    didSet {
      guard viewControllers.isNotEmpty else {
        print("空配列を渡されることは想定していません")  // TODO: 許容するようにする
        return
      }
      if isViewLoaded {
        isTabViewHidden = viewControllers.count <= 1
      }

      segmentedControl?.removeAllSegments()

      for (index, controller) in viewControllers.enumerated() {
        addChildViewController(controller)
        controller.automaticallyAdjustsScrollViewInsets = false
        controller.didMove(toParentViewController: self)

        segmentedControl?.insertSegment(withTitle: controller.title, at: index, animated: false)
      }
      selectedIndex = 0
    }
  }

  var selectedViewController: UIViewController? {
    guard viewControllers.isNotEmpty else {
      return nil
    }
    return viewControllers[selectedIndex]
  }

  var selectedIndex = 0 {
    willSet {
      guard selectedViewController != nil else {
        return
      }
      stopContentObservable()
    }
    didSet {
      guard selectedIndex < viewControllers.count else {
        fatalError("index out of bounds. index: \(selectedIndex), viewControllers.count: \(viewControllers.count)")
      }
      guard selectedIndex != oldValue else {
        return
      }
      let previousViewController = viewControllers[oldValue]
      if previousViewController.isViewLoaded {
        previousViewController.view.removeFromSuperview()
      }

      if isViewLoaded {
        setupChildViewController()
      }

      if selectedIndex != segmentedControl?.selectedSegmentIndex {
        segmentedControl?.selectedSegmentIndex = selectedIndex
      }
    }
  }

  var upperContentViewController: UIViewController? {
    willSet {
      stopUpperContentObservable()
      guard newValue != upperContentViewController else {
        return
      }
      upperContentViewController?.willMove(toParentViewController: nil)
      upperContentViewController?.view.removeObserver(self, forKeyPath: "frame")

      if upperContentViewController?.isViewLoaded ?? false {
        upperContentViewController?.view.removeFromSuperview()
      }

      upperContentViewController?.removeFromParentViewController()
    }
    didSet {
      guard upperContentViewController != oldValue,
        let controller = upperContentViewController
        else {
          return
      }
      addChildViewController(controller)
      controller.automaticallyAdjustsScrollViewInsets = false
      controller.didMove(toParentViewController: self)

      upperContentViewController = controller
      if isViewLoaded {
        setupUpperContentViewController()
        startUpperContentObservable()
      }
    }
  }

  func set<T> (scrollableControllers: [T]) where T: UIViewController, T: Scrollable {
    viewControllers = scrollableControllers
  }

  // MARK: - Private Accessor
  @IBOutlet private weak var upperContentView: UIView!
  @IBOutlet private weak var segmentedControl: UISegmentedControl! {
    didSet {
      segmentedControl.removeAllSegments()

      for (index, controller) in viewControllers.enumerated() {
        segmentedControl.insertSegment(withTitle: controller.title, at: index, animated: false)
      }

      segmentedControl.selectedSegmentIndex = selectedIndex

      let action = #selector(self.segmentedControlDidChangeValue(sender:))
      segmentedControl.addTarget(self, action: action, for: .valueChanged)
    }
  }
  @IBAction func segmentedControlDidChangeValue(sender: AnyObject!) {
    selectedIndex = segmentedControl.selectedSegmentIndex
  }

  @IBOutlet private weak var tabView: UIView!
  @IBOutlet private weak var tabViewTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var tabContentView: UIView!

  private var topScrollableContentViewController: Scrollable? {
    guard let scrollable = selectedViewController as? Scrollable else {
      return nil
    }
    return scrollable
  }

  private var isTabViewHidden: Bool {
    set {
      tabView.isHidden = newValue
    }
    get {
      return tabView.isHidden
    }
  }

  var tabViewHeight: CGFloat {
    return isTabViewHidden ? 0.0 : tabView.frame.size.height
  }

  private var scrollInsetTop: CGFloat?
  private var shouldIgnoreOffsetChange = false

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    automaticallyAdjustsScrollViewInsets = false

    isTabViewHidden = viewControllers.count <= 1
    setupUpperContentViewController()
    setupChildViewController()
    startUpperContentObservable()
  }

  private func setupUpperContentViewController() {
    guard isViewLoaded,
      let upperContentViewController = upperContentViewController
      else {
        return
    }

    upperContentView.addSubview(upperContentViewController.view)
    upperContentView.translatesAutoresizingMaskIntoConstraints = false
    upperContentViewController.view.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [NSLayoutAttribute.top, .right, .left, .bottom].map { (attribute) -> NSLayoutConstraint in
      return NSLayoutConstraint.init(
        item: self.upperContentView,
        attribute: attribute,
        relatedBy: .equal,
        toItem: upperContentViewController.view,
        attribute: attribute,
        multiplier: 1,
        constant: 0
      )
    }
    upperContentView.addConstraints(constraints)
    upperContentView.layoutIfNeeded()
  }

  private func setupChildViewController() {
    guard isViewLoaded,
      selectedIndex < viewControllers.count
      else {
        return
    }

    let currentViewController = viewControllers[selectedIndex]
    currentViewController.view.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
    currentViewController.view.frame = tabContentView.bounds
    currentViewController.view.setNeedsLayout()

    if let scrollable = currentViewController as? Scrollable {
      let scrollInset = UIEdgeInsets.init(top: scrollInsetTop ?? 0.0, left: 0.0, bottom: 0.0, right: 0.0)
      scrollable.scrollView.contentInset = scrollInset
      scrollable.scrollView.scrollIndicatorInsets = scrollInset

      let tabViewTop = tabViewTopConstraint.constant

      if tabViewTop == 0.0 {
        if scrollable.scrollView.contentOffset.y < 0.0 {
          let offset = -tabViewHeight

          scrollable.scrollView.contentOffset = CGPoint.init(x: 0.0, y: offset)
          observeScrollViewOffset(offset)
          shouldIgnoreOffsetChange = true
        }
      } else {
        let offset = -(tabViewHeight + tabViewTop)

        scrollable.scrollView.contentOffset = CGPoint.init(x: 0.0, y: offset)
        observeScrollViewOffset(offset)
        shouldIgnoreOffsetChange = true
      }
    }

    tabContentView.addSubview(currentViewController.view)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
      self.shouldIgnoreOffsetChange = false
    }

    startContentObservable()
  }

  private func startUpperContentObservable() {
    guard isViewLoaded else {
      return
    }
    observeUpperViewHeight(upperContentView.frame.height)

    guard upperContentViewController != nil else {
      return
    }
    upperContentView.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
    upperContentView.layer.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
    upperContentView.layer.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
  }

  private func startContentObservable() {
    guard let selectedViewController = selectedViewController as? Scrollable, isViewLoaded else {
      return
    }
    selectedViewController.scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
  }

  private func stopUpperContentObservable() {
    guard upperContentViewController != nil, isViewLoaded else {
      return
    }
    upperContentView.removeObserver(self, forKeyPath: "bounds")
    upperContentView.layer.removeObserver(self, forKeyPath: "frame")
    upperContentView.layer.removeObserver(self, forKeyPath: "bounds")
  }

  private func stopContentObservable() {
    guard let selectedViewController = selectedViewController as? Scrollable, isViewLoaded else {
      return
    }
    selectedViewController.scrollView.removeObserver(self, forKeyPath: "contentOffset")
  }

  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    switch keyPath {
    case .some("bounds"), .some("frame"):
      guard let frame = change?[.newKey] as? CGRect else {
        print("change[.newKey]がCGRectではありません")  // TODO: DebugではfatalError、Releaseではログになるような挙動の何か作る
        return
      }
      observeUpperViewHeight(frame.height)

    case .some("contentOffset"):
      guard let offset = change?[.newKey] as? CGPoint else {
        print("change[.newKey]がCGPointではありません")
        return
      }
      observeScrollViewOffset(offset.y)

    default:
      break
    }
  }

  private func observeUpperViewHeight(_ height: CGFloat) {
    guard let scrollable = topScrollableContentViewController else {
      return
    }

    let scrollInsetTop = height + tabViewHeight
    self.scrollInsetTop = scrollInsetTop

    guard scrollInsetTop != scrollable.scrollView.contentInset.top else {
      return
    }

    let scrollInset = UIEdgeInsets.init(top: scrollInsetTop, left: 0.0, bottom: 0.0, right: 0.0)
    scrollable.scrollView.contentInset = scrollInset
    scrollable.scrollView.scrollIndicatorInsets = scrollInset
    scrollable.scrollView.contentOffset = CGPoint.init(x: 0.0, y: -scrollInsetTop)
  }

  private func observeScrollViewOffset(_ offsetY: CGFloat) {

    let offset = -(tabViewHeight + offsetY)
    let maxValue = CGFloat(0.0)
    let minValue = scrollInsetTop ?? CGFloat.leastNormalMagnitude

    let constant = min(max(offset, maxValue), minValue)

    guard constant != tabViewTopConstraint.constant else {
      return
    }

    guard shouldIgnoreOffsetChange == false else {
      let currentViewController = viewControllers[selectedIndex]
      if let scrollable = currentViewController as? Scrollable {
        let offset = -(self.tabViewTopConstraint.constant + self.tabViewHeight)
        DispatchQueue.main.async {
          scrollable.scrollView.contentOffset = CGPoint.init(x: 0.0, y: offset)
        }
      }
      return
    }

    tabViewTopConstraint.constant = constant
    view.setNeedsLayout() // layoutIfNeeded() では更新しないことがある
  }

  deinit {
    stopUpperContentObservable()
    stopContentObservable()
  }
}

extension UIViewController {
  var scrollableTabController: ScrollableTabController? {
    return ancestor()
  }
}

extension UIViewController {
  func ancestor<Ancestor: UIViewController>() -> Ancestor? {
    var controller: UIViewController? = self

    while controller?.parent != nil {
      if let ancestorViewController = controller?.parent as? Ancestor {
        return ancestorViewController
      }
      controller = controller?.parent
    }
    return nil
  }
}

extension Array {
  var isNotEmpty: Bool {
    return !isEmpty
  }
}
