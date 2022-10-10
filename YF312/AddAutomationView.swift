//
//  AddAutomationView.swift
//  YF312
//
//  Created by 娄俊逸 on 2022/9/15.
//

import SwiftUI

struct SensorSelectionView: View {
    @ObservedObject var house: House
    @ObservedObject var automation: Automation
    var body: some View {
        HStack {
            Text("当")
            Menu(automation.comparingData) {
                ForEach(["温度", "湿度", "亮度"], id: \.self) { data  in
                    Button(data) {
                        automation.comparingData = data
                        if automation.comparingData != "亮度" {
                            automation.comparingMethod = "大于"
                            automation.comparingValue = 50
                        } else {
                            automation.comparingMethod = "变亮/变暗"
                            automation.comparingValue = 0
                        }
                    }
                }
            }
            if automation.comparingData != "亮度" {
                Menu(automation.comparingMethod) {
                    ForEach(["大于", "小于"], id: \.self) { method in
                        Button(method) {
                            automation.comparingMethod = method
                        }
                    }
                }
                Stepper(automation.comparingValueFormatted().replacingOccurrences(of: " ", with: ""), value: $automation.comparingValue, in: 0...100)
            } else {
                Menu(automation.comparingMethod) {
                    ForEach(["变亮/变暗", "变亮", "变暗"], id: \.self) { method in
                        Button(method) {
                            automation.comparingMethod = method
                        }
                    }
                }
            }
            Text("时")
        }
    }
}

struct DeviceSelectionView: View {
    @ObservedObject var house: House
    @ObservedObject var automation: Automation
    var body: some View {
        HStack {
            Text("当")
            Menu(automation.comparingData) {
                ForEach(house.gadgets) { gadget in
                    Button(gadget.name) {
                        automation.comparingData = gadget.name
                    }
                }
            }
            Menu(automation.comparingMethod) {
                ForEach(["打开/关闭", "打开", "关闭"], id: \.self) { method in
                    Button(method) {
                        automation.comparingMethod = method
                    }
                }
            }
            Spacer()
            Text("时")
        }
    }
}

struct TargetSelectionView: View {
    @ObservedObject var house: House
    @ObservedObject var automation: Automation
    var body: some View {
        HStack {
            Menu(automation.targetMethod) {
                ForEach(["打开/关闭", "打开", "关闭"], id: \.self) { method in
                    Button(method) {
                        automation.targetMethod = method
                    }
                }
            }
            Menu(automation.targetData) {
                ForEach(house.gadgets) { gadget in
                    if gadget.name != automation.comparingData {
                        Button(gadget.name) {
                            automation.targetData = gadget.name
                        }
                    }
                }
            }
        }
    }
}

struct AddAutomationView: View {
    @ObservedObject var house: House
    @StateObject var automation = Automation()
    @Environment(\.dismiss) var dismiss
    @State private var dataType = ""
    
    let dataTypes = ["环境信息", "设备开关"]
    var body: some View {
        NavigationView {
            Form {
                if (!notCompleted()) {
                    Section {
                        SummaryView(house: house, automation: automation)
                    }
                }
                Section("自动化名称") {
                    TextField("名称", text: $automation.name)
                }
                Section("触发条件") {
                    Picker("触发数据类型", selection: $dataType) {
                        ForEach(dataTypes, id: \.self){
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    if dataType == "环境信息" {
                        SensorSelectionView(house:house, automation: automation)
                    } else if dataType == "设备开关" {
                        DeviceSelectionView(house:house, automation: automation)
                    }
                }
                if dataType != "" {
                    Section("触发任务") {
                        TargetSelectionView(house: house, automation: automation)
                    }
                }
            }
            .navigationTitle("添加自动化")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消", action: {dismiss()})
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加", action: {
                        house.automations.append(automation)
                        dismiss()
                    })
                    .disabled(notCompleted())
                }
            }
            .onChange(of: dataType) { _ in
                if dataType == "环境信息" {
                    automation.comparingData = "温度"
                    automation.comparingMethod = "大于"
                    automation.comparingValue = 50
                } else if dataType == "设备开关" {
                    automation.comparingData = house.gadgets[0].name
                    automation.comparingMethod = "打开/关闭"
                    automation.comparingValue = -1
                }
                automation.targetMethod = "打开/关闭"
                automation.targetData = house.gadgets[0].name
            }
        }
    }
    
    func notCompleted() -> Bool {
        [automation.name, automation.comparingMethod, automation.comparingData, automation.targetMethod, automation.targetData].contains{$0.isEmpty}
    }
}

struct AddAutomationView_Previews: PreviewProvider {
    static let gadget1 = Gadget(name: "大门", isOn: false, imageOn: "door.left.hand.open")
    static let gadget2 = Gadget(name: "灯泡", isOn: true, imageOn: "lightbulb.fill")
    static let gadget3 = Gadget(name: "窗帘", isOn: false, imageOn: "curtains.open")
    static let gadget4 = Gadget(name: "空调", isOn: true, imageOn: "air.conditioner.horizontal.fill")
    static let automation1 = Automation(name: "天热了开空调", enabled: false, comparingData: "温度", comparingMethod: "大于", comparingValue: 30.0, targetData: "空调", targetMethod: "打开")
    static let automation2 = Automation(name: "窗户与灯泡相互开关", enabled: true, comparingData: "窗帘", comparingMethod: "打开/关闭", comparingValue: -1, targetData: "灯泡", targetMethod: "打开/关闭")
    static let house = House(name: "YF312", gadgets: [gadget1, gadget2, gadget3, gadget4], automations: [automation1, automation2])
    static var previews: some View {
        AddAutomationView(house: house)
    }
}
