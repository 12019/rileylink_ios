//
//  SensorCalGlucoseEvent.swift
//  RileyLink
//
//  Created by Timothy Mecklem on 10/16/16.
//  Copyright © 2016 Pete Schwamb. All rights reserved.
//

import Foundation

public struct SensorCalGlucoseEvent : RelativeTimestampedGlucoseEvent {
    public let length: Int
    public let rawData: Data
    
    public init?(availableData: Data, pumpModel: PumpModel) {
        length = 2
        
        guard length <= availableData.count else {
            return nil
        }
        
        rawData = availableData.subdata(in: 0..<length)
    }
    
    public var dictionaryRepresentation: [String: Any] {
        return [
            "name": "SensorCal",
        ]
    }
}


