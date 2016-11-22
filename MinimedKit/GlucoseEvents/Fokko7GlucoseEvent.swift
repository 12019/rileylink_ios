//
//  Fokko7GlucoseEvent.swift
//  RileyLink
//
//  Created by Timothy Mecklem on 10/16/16.
//  Copyright © 2016 Pete Schwamb. All rights reserved.
//

import Foundation

public struct Fokko7GlucoseEvent: GlucoseEvent {
    public let length: Int
    public let rawData: Data
    public var timestamp: DateComponents
    
    public init?(availableData: Data) {
        length = 2
        
        guard length <= availableData.count else {
            return nil
        }
        
        rawData = availableData.subdata(in: 0..<length)
        timestamp = DateComponents()
    }
    
    public var dictionaryRepresentation: [String: Any] {
        return [
            "name": "Fokko-7",
        ]
    }
}
