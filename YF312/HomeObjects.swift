//
//  HomeObjects.swift
//  YF312
//
//  Created by 娄俊逸 on 2022/9/15.
//

import Foundation
import SwiftUI

class Gadget: Identifiable, ObservableObject {
    var id = UUID()
    @Published var name: String
    @Published var isOn: Bool
    @Published var imageOn: String
    @Published var histories: [Date : String]
    @Published var valueMQTT: Double
    
    var imageOff: String { imageOn.replacingOccurrences(of: ".fill", with: "").replacingOccurrences(of: ".open", with: ".closed") }
    var image: String { isOn ? imageOn : imageOff }
    var isMQTTDevice0: Bool { name == "LED0" }
    var isMQTTDevice1: Bool { name == "LED1" }
    var valueMQTTFormatted: String { String(format: "%.0f", valueMQTT) }
    
    func setStatus(_ setTo: Bool?, house: House, isAutomated: Bool = false) {
        if isMQTTDevice0 || isMQTTDevice1 {
            if setTo != nil {
                valueMQTT = setTo! ? 10 : 0
            }
            isOn = valueMQTT > 0
            let published = mqttPublish("{\"\(name)\":\(isMQTTDevice0 ? valueMQTTFormatted : (isOn ? "1" : "0"))}", house: house)
            if published {
                histories[Date()] = "\(isAutomated ? "联动" : "手动")设为 \(valueMQTTFormatted)"
            }
        } else {
            isOn = setTo!
            histories[Date()] = "\(isAutomated ? "联动" : "手动")\(isOn ? "开启" : "关闭")"
        }
        for automation in house.automations {
            if automation.targetData != name && automation.comparingData == name && automation.shouldRun(fromData: isOn ? 2 : 0) {
                automation.runner(house: house)
            }
        }
    }
    
    func mqttPublish(_ data: String, house: House) -> Bool {
        if let Client = house.client {
            if Client.currentAppState.appConnectionState == .connectedSubscribed {
                Client.publish(with: data)
                return true
            } else {
                house.popNotification("请先订阅话题再操作设备", 3)
            }
        } else {
            house.popNotification("请先连接 MQTT 服务再操作设备", 3)
        }
        return false
    }
    
    init(id: UUID = UUID(), name: String, isOn: Bool, imageOn: String, histories: [Date : String] = [Date(): "初始化"], valueMQTT: Double = 0) {
        self.id = id
        self.name = name
        self.isOn = isOn
        self.imageOn = imageOn
        self.histories = histories
        self.valueMQTT = valueMQTT
    }
}

class Automation: Identifiable, ObservableObject {
    var id = UUID()
    @Published var name: String
    @Published var enabled: Bool
    @Published var comparingData: String
    @Published var comparingMethod: String
    @Published var comparingValue: Double
    @Published var targetData: String
    @Published var targetMethod: String
    
    func comparingValueFormatted() -> String {
        if comparingValue <= 0 {
            return ""
        } else {
            if comparingData == "温度" { return String(format: " %.0f℃ ", comparingValue)}
            else if comparingData == "湿度" { return String(format: " %.0f%% ", comparingValue) }
            else { return "" }
        }
    }
    var description: String {
        "当 \(comparingData) \(comparingMethod)\(comparingValueFormatted())时 \(targetMethod) \(targetData)"
    }
    
    init(id: UUID = UUID(), name: String = "", enabled: Bool = true, comparingData: String = "", comparingMethod: String = "", comparingValue: Double = 0.0, targetData: String = "", targetMethod: String = "") {
        self.id = id
        self.name = name
        self.enabled = enabled
        self.comparingData = comparingData
        self.comparingMethod = comparingMethod
        self.comparingValue = comparingValue
        self.targetData = targetData
        self.targetMethod = targetMethod
    }
    
    func runner(house: House) {
        let targetStatus: Bool
        let targetGadget = house.gadgets.first{$0.name == targetData}!
        switch targetMethod {
        case "打开":
            targetStatus = true
        case "关闭":
            targetStatus = false
        case "打开/关闭":
            targetStatus = !targetGadget.isOn
        default:
            targetStatus = targetGadget.isOn
        }
        if targetStatus != targetGadget.isOn {
            targetGadget.setStatus(targetStatus, house: house, isAutomated: true)
        }
        house.popNotification("已触发「\(name)」: \(targetMethod) \(targetData)")
    }
    
    func shouldRun(fromData: Double, previousValue: Double = 0) -> Bool {
        switch comparingMethod {
        case "大于":
            return fromData >= comparingValue
        case "小于":
            return fromData <= comparingValue
        case "打开":
            return fromData > 1
        case "关闭":
            return fromData < 1
        case "打开/关闭":
            return true
        case "变亮":
            return ((Int(previousValue) ^ Int(fromData)) != 0) && (fromData == 1)
        case "变暗":
            return ((Int(previousValue) ^ Int(fromData)) != 0) && (fromData == 0)
        case "变亮/变暗":
            return (Int(previousValue) ^ Int(fromData)) != 0
        default:
            return false
        }
    }
}

class House: Identifiable, ObservableObject {
    var id = UUID()
    @Published var name: String
    @Published var gadgets: [Gadget]
    @Published var automations: [Automation]
    @Published var temperature: Double {
        didSet { triggerAutomations(value: temperature, comparing: "温度") }
    }
    @Published var humidity: Double {
        didSet { triggerAutomations(value: humidity, comparing: "湿度") }
    }
    @Published var ambient: Double {
        willSet { triggerAutomations(value: newValue, comparing: "亮度", previousValue: ambient) }
    }
    @Published var topic: String
    @Published var notificationText: String
    @Published var notificationShown: Bool
    @Published var lastUpdate: Date?
    var client: MQTTManager?
    
    var temperatureFormatted: String {
        String(format: "%.0f℃", temperature)
    }
    var humidityFormatted: String {
        String(format: "%.0f%%", humidity)
    }
    var ambientFormatted: String {
        ambient < 0 ? "未知" : ( ambient == 1 ? "亮" : "暗" )
    }
    
    init(id: UUID = UUID(), name: String,
         gadgets: [Gadget], automations: [Automation], lastUpdate: Date? = nil,
         temperature: Double = 0, humidity: Double = 0, ambient: Double = -1,
         notificationText: String = "", notificationShown: Bool = false,
         topic: String = "subscribe", client: MQTTManager? = nil) {
        self.id = id
        self.name = name
        self.gadgets = gadgets
        self.automations = automations
        self.temperature = temperature
        self.humidity = humidity
        self.ambient = ambient
        self.topic = topic
        self.notificationText = notificationText
        self.notificationShown = notificationShown
        self.lastUpdate = lastUpdate
        self.client = client
    }
    
    func triggerAutomations(value: Double, comparing: String, previousValue: Double = 0) {
        for automation in automations {
            if automation.comparingData == comparing && automation.shouldRun(fromData: value, previousValue: previousValue) {
                automation.runner(house: self)
            }
        }
    }
    
    struct remoteInfo: Codable {
        var Temp: Double
        var Hum: Double
        var Light: Double
    }
    
    func getRemoteInfo(_ data: String) {
        guard let decoded = try? JSONDecoder().decode(remoteInfo.self, from: data.data(using: .utf8)!) else {
            return
        }
        // popNotification("数据已更新", 1)
        temperature = decoded.Temp
        humidity = decoded.Hum
        ambient = decoded.Light == 1 ? 0 : 1
        lastUpdate = Date()
    }
    
    func popNotification(_ text: String, _ delay: Double = 3) {
        notificationText = text
        withAnimation { notificationShown = true }
        withAnimation(Animation.easeInOut.delay(delay)) { notificationShown = false }
    }
}
