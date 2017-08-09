//
//  TouchTransparentView.swift
//  ScrollableTabController
//
//  Created by mitsuyoshi.yamazaki on 2017/08/01.
//  Copyright © 2017年 Mitsuyoshi Yamazaki and Speee, Inc. All rights reserved.
//

import UIKit

public class TouchTransparentView: UIView {

  override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)

    guard hitView !== self else {
      return nil
    }
    return hitView
  }
}
