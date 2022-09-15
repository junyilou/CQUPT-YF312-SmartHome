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
    @State private var comparingData = "数据"
    @State private var comparingMethod = "变化"
    var body: some View {
        HStack {
            Text("当")
            Menu(comparingData) {
                ForEach(["温度", "湿度"], id: \.self) { data  in
                    Button(data) {
                        automation.comparingData = data
                        comparingData = automation.comparingData
                    }
                }
            }
            Menu(comparingMethod) {
                ForEach(["大于", "小于"], id: \.self) { method in
                    Button(method) {
                        automation.comparingMethod = method
                        comparingMethod = automation.comparingMethod
                    }
                }
            }
            Text(automation.comparingValueFormatted().replacingOccurrences(of: " ", with: ""))
            Slider(value: $automation.comparingValue, in: 0...100)
            Text("时")
        }
    }
}

struct DeviceSelectionView: View {
    @ObservedObject var house: House
    @ObservedObject var automation: Automation
    @State private var comparingData = "设备"
    @State private var comparingMethod = "变化"
    var body: some View {
        HStack {
            Text("当")
            Menu(comparingData) {
                ForEach(house.gadgets) { gadget in
                    Button(gadget.name) {
                        automation.comparingData = gadget.name
                        comparingData = automation.comparingData
                    }
                }
            }
            Menu(comparingMethod) {
                ForEach(["打开", "关闭"], id: \.self) { method in
                    Button(method) {
                        automation.comparingMethod = method
                        comparingMethod = automation.comparingMethod
                        automation.comparingValue = -1
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
    @State private var targetMethod = "控制"
    @State private var targetData = "设备"
    var body: some View {
        HStack {
            Menu(targetMethod) {
                ForEach(["打开/关闭", "打开", "关闭"], id: \.self) { method in
                    Button(method) {
                        automation.targetMethod = method
                        targetMethod = automation.targetMethod
                    }
                }
            }
            Menu(targetData) {
                ForEach(house.gadgets) { gadget in
                    if gadget.name != automation.comparingData {
                        Button(gadget.name) {
                            automation.targetData = gadget.name
                            targetData = automation.targetData
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
    
    let dataTypes = ["传感器数据", "设备开关"]
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
                    if dataType == "传感器数据" {
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
        }
    }
    
    func notCompleted() -> Bool {
        [automation.name, automation.comparingMethod, automation.comparingData, automation.targetMethod, automation.targetData].contains{$0.isEmpty}
    }
}

struct AddAutomationView_Previews: PreviewProvider {
    static let gadget1 = Gadget(name: "大门", isOn: true, imageOn: "door.left.hand.open")
    static let gadget2 = Gadget(name: "LED", isOn: false, imageOn: "light.beacon.max.fill")
    static let gadget3 = Gadget(name: "窗帘", isOn: false, imageOn: "curtains.open")
    static let gadget4 = Gadget(name: "空调", isOn: true, imageOn: "air.conditioner.horizontal.fill")
    static let automation1 = Automation(name: "自动关门", enabled: false, comparingData: "温度", comparingMethod: "大于", comparingValue: 20.0, targetData: "大门", targetMethod: "关闭")
    static let automation2 = Automation(name: "关窗开灯", enabled: true, comparingData: "窗帘", comparingMethod: "关闭", comparingValue: -1, targetData: "LED", targetMethod: "打开/关闭")
    static let house = House(name: "YF312", gadgets: [gadget1, gadget2, gadget3, gadget4], automations: [automation1, automation2], temperature: 25, humidity: 75)
    static var previews: some View {
        AddAutomationView(house: house)
    }
}
