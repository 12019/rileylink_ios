//
//  CalBGForGHGlucoseEvent.swift
//  RileyLink
//
//  Created by Timothy Mecklem on 10/16/16.
//  Copyright © 2016 Pete Schwamb. All rights reserved.
//

import Foundation

public struct CalBGForGHGlucoseEvent : GlucoseEvent {
    public let length: Int
    public let rawData: Data
    
    public init?(availableData: Data, pumpModel: PumpModel) {
        length = 6
        
        guard length <= availableData.count else {
            return nil
        }
        
        rawData = availableData.subdata(in: 0..<length)
    }
    
    public var dictionaryRepresentation: [String: Any] {
        return [
            "name": "CalBGForGH",
        ]
    }
}
