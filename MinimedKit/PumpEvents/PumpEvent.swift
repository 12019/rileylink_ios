//
//  PumpEvent.swift
//  RileyLink
//
//  Created by Pete Schwamb on 3/7/16.
//  Copyright © 2016 Pete Schwamb. All rights reserved.
//

import UIKit

public protocol PumpEvent {
  
  init?(availableData: NSData, pumpModel: PumpModel)
  
  var length: Int {
    get
  }

}
