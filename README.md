ScrollableTabController
====

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


ScrollableTabController is tab based ContainerViewController with shrinkable upper content area.


## Demo

<img width=320 src="https://user-images.githubusercontent.com/904354/29101403-f44ec2b6-7cec-11e7-8207-eb11bc2abff7.gif">

## Requirement

iOS10+

## Usage

### Instantiation by code

```swift
let scrollableTabController = ScrollableTabController()

scrollableTabController.viewControllers = [ 
  someScrollableViewController1, 
  someScrollableViewController2
]
scrollableTabController.upperContentViewController = someContentViewController
```

### Restrictions for ContentViewControllers

There're some restrictions to avoid unwanted behavior.

#### UpperContentViewController

- Its view has to be able to define its height. ScrollableTabController observes the height and decides UpperContentViewController.view's container view's height.
- If you want to allow users to scroll over upper content area, consider using TouchTransparentView that passes touch events to views below it.

#### ScrollableViewController

- It has to conform to Scrollable protocol to make ScrollableTabController can observe scrolling.
- **Its scrollView.contentSize.height must not be smaller than scrollView.frame.height.** If the contentSize.height is too small, the upper content area can't shrink. See the screenshot below.

<img width=320 src="https://user-images.githubusercontent.com/904354/29102399-c738c9be-7cf3-11e7-9880-98605319dc7e.gif">

## Installation

### Carthage

```
github "speee/ScrollableTabController"
```

## Contribution

Welcome!!

## Licence

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)

## Author

[Mitsuyoshi Yamazaki](https://github.com/mitsuyoshi-yamazaki)

