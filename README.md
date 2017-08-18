ScrollableTabController
====

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


ScrollableTabController is tab based ContainerViewController with shrinkable and expandable upper content area.


## Demo

<img width=320 src="https://user-images.githubusercontent.com/904354/29403196-8f674c24-8372-11e7-9902-e5c7d0a7a39f.gif">

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

There're some restrictions to use it properly.

#### UpperContentViewController

- UpperContentViewController.view has to define its height with **900 to 950 constraints priority**. 
	- First, ScrollableTabController observes the height and set it as default height(the upper content height when the scrollable area is not scrolled).
	- Then when the user scrolls, the upper content area shrinks / expands, 
	- The default view height(the height when the scrollable area is not scrolled) should be fixed when viewDidLoad is called. Changing the height is not supported.
- If you want to allow users to scroll over upper content area, consider using TouchTransparentView that passes touch events to views below it.

#### ScrollableViewController

- It has to conform to Scrollable protocol to make ScrollableTabController can observe scrolling.
- **Its scrollView.contentSize.height must not be smaller than scrollView.frame.height.** If the contentSize.height is too small, the upper content area can't shrink. See the screenshot below.

<img width=320 src="https://user-images.githubusercontent.com/904354/29102399-c738c9be-7cf3-11e7-9880-98605319dc7e.gif">

- priority 900 - 950
	- conflicting xx to achieve
- example

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

