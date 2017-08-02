//
//  Extensions.swift
//  ScrollableTabController
//
//  Created by mitsuyoshi.yamazaki on 2017/08/02.
//  Copyright © 2017年 Mitsuyoshi Yamazaki and Speee, Inc. All rights reserved.
//

import Foundation

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
