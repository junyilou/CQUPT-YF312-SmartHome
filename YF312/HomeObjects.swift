//
//  HomeObjects.swift
//  YF312
//
//  Created by 娄俊逸 on 2022/9/15.
//

import Foundation

class Gadget: Identifiable, ObservableObject {
    var id = UUID()
    @Published var name: String
    @Published var isOn: Bool
    @Published var imageOn: String
    @Published var histories: [Date : String]
    
    var imageOff: String { imageOn.replacingOccurrences(of: ".fill", with: "").replacingOccurrences(of: ".open", with: ".closed") }
    var image: String { isOn ? imageOn : imageOff }
    func setStatus(_ setTo: Bool, house: House, isAutomated: Bool = false) {
        isOn = setTo
        histories[Date()] = "\(isAutomated ? "联动" : "手动")\(isOn ? "开启" : "关闭")"
        for automation in house.automations {
            if automation.targetData != name && automation.comparingData == name && automation.shouldRun(fromData: isOn ? 2 : 0) {
                automation.runner(house: house)
            }
        }
    }
    
    init(id: UUID = UUID(), name: String, isOn: Bool, imageOn: String, histories: [Date : String] = [Date(): "初始化"]) {
        self.id = id
        self.name = name
        self.isOn = isOn
        self.imageOn = imageOn
        self.histories = histories
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
        comparingValue < 0 ? "" : String(format: comparingData == "温度" ? " %.0f℃ " : " %.0f%% ", comparingValue)
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
        targetGadget.setStatus(targetStatus, house: house, isAutomated: true)
    }
    
    func shouldRun(fromData: Double) -> Bool {
        switch comparingMethod {
        case "大于":
            return fromData >= comparingValue
        case "小于":
            return fromData <= comparingValue
        case "打开":
            return fromData > 1
        case "关闭":
            return fromData < 1
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
        didSet {
            triggerAutomations(value: temperature, comparing: "温度")
        }
    }
    @Published var humidity: Double {
        didSet {
            triggerAutomations(value: humidity, comparing: "湿度")
        }
    }
    
    var temperatureFormatted: String {
        String(format: "%.2f℃", temperature)
    }
    var humidityFormatted: String {
        String(format: "%.2f%%", humidity)
    }
    
    init(id: UUID = UUID(), name: String, gadgets: [Gadget], automations: [Automation], temperature: Double, humidity: Double) {
        self.id = id
        self.name = name
        self.gadgets = gadgets
        self.automations = automations
        self.temperature = temperature
        self.humidity = humidity
    }
    
    func triggerAutomations(value: Double, comparing: String) {
        for automation in automations {
            if automation.comparingData == comparing && automation.shouldRun(fromData: value) {
                automation.runner(house: self)
            }
        }
    }
}
