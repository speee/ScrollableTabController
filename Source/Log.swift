//
//  Log.swift
//  ScrollableTabController
//
//  Created by mitsuyoshi.yamazaki on 2017/08/09.
//  Copyright © 2017年 Mitsuyoshi Yamazaki and Speee, Inc. All rights reserved.
//

import Foundation

internal struct Log {
  static func error(_ message: String) {
    #if DEBUG
      fatalError(message)
    #else
      print(message)
    #endif
  }

  static func fatal(_ message: String) -> Never {
    fatalError(message)
  }
}
