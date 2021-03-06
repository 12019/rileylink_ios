//
//  RileyLinkPumpManager.swift
//  Loop
//
//  Copyright © 2018 LoopKit Authors. All rights reserved.
//

import RileyLinkBLEKit

open class RileyLinkPumpManager {
    
    public init(rileyLinkDeviceProvider: RileyLinkDeviceProvider,
                rileyLinkConnectionManager: RileyLinkConnectionManager? = nil) {
        
        self.rileyLinkDeviceProvider = rileyLinkDeviceProvider
        self.rileyLinkConnectionManager = rileyLinkConnectionManager
        
        // Listen for device notifications
        NotificationCenter.default.addObserver(self, selector: #selector(receivedRileyLinkPacketNotification(_:)), name: .DevicePacketReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedRileyLinkTimerTickNotification(_:)), name: .DeviceTimerDidTick, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceStateDidChange(_:)), name: .DeviceStateDidChange, object: nil)
    }
    
    /// Manages all the RileyLinks - access to management is optional
    public let rileyLinkConnectionManager: RileyLinkConnectionManager?
    
    open var rileyLinkConnectionManagerState: RileyLinkConnectionManagerState?
    
    /// Access to rileylink devices
    public let rileyLinkDeviceProvider: RileyLinkDeviceProvider
    
    // TODO: Evaluate if this is necessary
    public let queue = DispatchQueue(label: "com.loopkit.RileyLinkPumpManager", qos: .utility)

    /// Isolated to queue
    // TODO: Put this on each RileyLinkDevice?
    private var lastTimerTick: Date = .distantPast

    // TODO: Isolate to queue
    open var deviceStates: [UUID: DeviceState] = [:]

    /// Called when one of the connected devices receives a packet outside of a session
    ///
    /// - Parameters:
    ///   - device: The device
    ///   - packet: The received packet
    open func device(_ device: RileyLinkDevice, didReceivePacket packet: RFPacket) { }

    open func deviceTimerDidTick(_ device: RileyLinkDevice) { }

    // MARK: - CustomDebugStringConvertible
    
    open var debugDescription: String {
        return [
            "## RileyLinkPumpManager",
            "rileyLinkConnectionManager: \(String(reflecting: rileyLinkConnectionManager))",
            "lastTimerTick: \(String(describing: lastTimerTick))",
            "deviceStates: \(String(reflecting: deviceStates))",
            "",
            String(reflecting: rileyLinkDeviceProvider),
        ].joined(separator: "\n")
    }
}

// MARK: - RileyLink Updates
extension RileyLinkPumpManager {
    @objc private func deviceStateDidChange(_ note: Notification) {
        guard
            let device = note.object as? RileyLinkDevice,
            let deviceState = note.userInfo?[RileyLinkDevice.notificationDeviceStateKey] as? RileyLinkKit.DeviceState
        else {
            return
        }

        queue.async {
            self.deviceStates[device.peripheralIdentifier] = deviceState
        }
    }

    /**
     Called when a new idle message is received by the RileyLink.

     Only MySentryPumpStatus messages are handled.

     - parameter note: The notification object
     */
    @objc private func receivedRileyLinkPacketNotification(_ note: Notification) {
        guard let device = note.object as? RileyLinkDevice,
            let packet = note.userInfo?[RileyLinkDevice.notificationPacketKey] as? RFPacket
        else {
            return
        }

        self.device(device, didReceivePacket: packet)
    }

    @objc private func receivedRileyLinkTimerTickNotification(_ note: Notification) {
        guard let device = note.object as? RileyLinkDevice else {
            return
        }

        // TODO: Do we need a queue?
        queue.async {
            self.lastTimerTick = Date()

            self.deviceTimerDidTick(device)
        }
    }
    
    open func connectToRileyLink(_ device: RileyLinkDevice) {
        rileyLinkConnectionManager?.connect(device)
    }

    open func disconnectFromRileyLink(_ device: RileyLinkDevice) {
        rileyLinkConnectionManager?.disconnect(device)
    }
    
}

// MARK: - RileyLinkConnectionManagerDelegate
extension RileyLinkPumpManager: RileyLinkConnectionManagerDelegate {
    public func rileyLinkConnectionManager(_ rileyLinkConnectionManager: RileyLinkConnectionManager, didChange state: RileyLinkConnectionManagerState) {
        self.rileyLinkConnectionManagerState = state
    }
}


