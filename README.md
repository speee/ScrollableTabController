ScrollableTabController
====

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)


ScrollableTabController is tab based ContainerViewController with shrink-able upper content area.


## Demo

<img width=320 src="https://user-images.githubusercontent.com/904354/29101403-f44ec2b6-7cec-11e7-8207-eb11bc2abff7.gif">

## Requirement

iOS10+

## Usage

### Instantiate by code

```swift
let scrollableTabController = ScrollableTabController()

scrollableTabController.viewControllers = [ 
  someScrollViewController1, 
  someScrollViewController2
]
scrollableTabController.upperContentViewController = someContentViewController
```

### Restriction for ContentViewControllers

// TODO:

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

