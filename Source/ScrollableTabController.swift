//
//  ScrollableTabController.swift
//  ScrollableTabController
//
//  Created by Mitsuyoshi Yamazaki on 2017/07/28.
//  Copyright © 2017年 Mitsuyoshi Yamazaki and Speee, Inc. All rights reserved.
//

import UIKit

public protocol ShrinkableContent {
  var minimumHeight: CGFloat? { get }
}
extension ShrinkableContent {
  var minimumHeight: CGFloat? {
    return nil
  }
}

public protocol Scrollable {
  var scrollView: UIScrollView! { get }
}

public final class ScrollableTabController: UIViewController {

  // MARK: - Public API
  public init() {
    let klass = type(of: self)
    let bundle = Bundle.init(for: klass)
    super.init(nibName: nil, bundle: bundle)
  }

  required public init?(coder aDecoder: NSCoder) {
    Log.fatal("init(coder:) has not been implemented")
  }

  public override var title: String? {
    set {
      super.title = newValue
    }
    get {
      if let title = super.title {
        return title
      }
      return upperContentViewController?.title
    }
  }

  public var viewControllers: [UIViewController] = [] {
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

  public var selectedViewController: UIViewController? {
    guard viewControllers.isNotEmpty else {
      return nil
    }
    return viewControllers[selectedIndex]
  }

  public var selectedIndex = 0 {
    willSet {
      guard selectedViewController != nil else {
        return
      }
      stopContentObservable()
    }
    didSet {
      guard selectedIndex < viewControllers.count else {
        Log.fatal("index out of bounds. index: \(selectedIndex), viewControllers.count: \(viewControllers.count)")
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

  public var upperContentViewController: UIViewController? {
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
      didLayoutUpperContent = false

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

  public func set<T: UIViewController> (scrollableControllers: [T]) where T: Scrollable {
    viewControllers = scrollableControllers
  }

  public var tabViewHeight: CGFloat {
    return isTabViewHidden ? 0.0 : tabView.frame.size.height
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

  private var upperContentViewHeight: CGFloat {
    return upperContentView.frame.height
  }
  private var scrollInsetTop: CGFloat {
    return upperContentViewHeight + tabViewHeight
  }
  private var isUpperViewSizeFixed = false
  private var shouldIgnoreOffsetChange = false
  private var didLayoutUpperContent = false

  // MARK: - Lifecycle
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return upperContentViewController?.preferredStatusBarStyle ?? .default
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    automaticallyAdjustsScrollViewInsets = false

    isTabViewHidden = viewControllers.count <= 1
    setupUpperContentViewController()
    setupChildViewController()
    startUpperContentObservable()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    didLayoutUpperContent = true
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
      let scrollInsetTop = isUpperViewSizeFixed ? self.scrollInsetTop : 0.0
      let scrollInset = UIEdgeInsets.init(top: scrollInsetTop, left: 0.0, bottom: 0.0, right: 0.0)
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

  override public func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?) {
    switch keyPath {
    case .some("bounds"), .some("frame"):
      guard let frame = change?[.newKey] as? CGRect else {
        Log.error("Unexpected change[.newKey], expected: CGRect, actual: \(String(describing: change?[.newKey]))")
        return
      }
      observeUpperViewHeight(frame.height)

    case .some("contentOffset"):
      guard let offset = change?[.newKey] as? CGPoint else {
        Log.error("Unexpected change[.newKey], expected: CGPoint, actual: \(String(describing: change?[.newKey]))")
        return
      }
      observeScrollViewOffset(offset.y)

    default:
      break
    }
  }

  private func observeUpperViewHeight(_ height: CGFloat) {
    guard didLayoutUpperContent == false else {
      return
    }
    guard let scrollable = topScrollableContentViewController else {
      return
    }

    let scrollInsetTop = height + tabViewHeight
    isUpperViewSizeFixed = true

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
    let maxValue = (upperContentViewController as? ShrinkableContent)?.minimumHeight ?? CGFloat(0.0)
    let constant = max(offset, maxValue)

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

    if let scrollable = viewControllers[selectedIndex] as? Scrollable {
      let scrollInset = UIEdgeInsets.init(top: constant + tabViewHeight, left: 0.0, bottom: 0.0, right: 0.0)
      scrollable.scrollView.scrollIndicatorInsets = scrollInset
    }

    tabViewTopConstraint.constant = constant
    view.setNeedsLayout() // layoutIfNeeded() may not redraw the view
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
