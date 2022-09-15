//
//  AutomationView.swift
//  YF312
//
//  Created by 娄俊逸 on 2022/9/15.
//

import SwiftUI

struct SummaryModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
    }
}

struct SummaryView: View {
    @ObservedObject var house: House
    @ObservedObject var automation: Automation
    var body: some View {
        VStack {
            Toggle(isOn: $automation.enabled, label: {
                VStack(alignment: .leading) {
                    Text(automation.name)
                        .font(.headline)
                    Text(automation.description)
                        .font(.caption)
                }
            })
            HStack {
                Image(systemName: dataImage(automation.comparingData))
                    .modifier(SummaryModifier())
                Image(systemName: methodImage(automation.comparingMethod))
                    .modifier(SummaryModifier())
                Image(systemName: "arrow.right")
                    .foregroundColor(.primary)
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                Image(systemName: dataImage(automation.targetData))
                    .modifier(SummaryModifier())
                Image(systemName: methodImage(automation.targetMethod))
                    .modifier(SummaryModifier())
            }
            .padding(.top)
        }
    }
    
    func dataImage(_ value: String) -> String {
        switch value {
        case "温度":
            return "thermometer.medium"
        case "湿度":
            return "humidity"
        default:
            return house.gadgets.first{$0.name == value}!.imageOn
        }
    }
    
    func methodImage(_ value: String) -> String {
        switch value {
        case "打开":
            return "lightswitch.on"
        case "关闭":
            return "lightswitch.off"
        case "打开/关闭":
            return "togglepower"
        case "大于":
            return "arrow.up.to.line.compact"
        case "小于":
            return "arrow.down.to.line.compact"
        default:
            return "house"
        }
    }
}

struct AutomationView: View {
    @ObservedObject var house: House
    var body: some View {
        List {
            Section("\(house.name) 的自动化") {
                ForEach(house.automations) { automation in
                    SummaryView(house: house, automation: automation)
                }
            }
        }
    }
}


struct AutomationView_Previews: PreviewProvider {
    static let gadget1 = Gadget(name: "大门", isOn: true, imageOn: "door.left.hand.open")
    static let gadget2 = Gadget(name: "LED", isOn: false, imageOn: "light.beacon.max.fill")
    static let gadget3 = Gadget(name: "窗帘", isOn: false, imageOn: "curtains.open")
    static let gadget4 = Gadget(name: "空调", isOn: true, imageOn: "air.conditioner.horizontal.fill")
    static let automation1 = Automation(name: "自动关门", enabled: false, comparingData: "温度", comparingMethod: "大于", comparingValue: 20.0, targetData: "大门", targetMethod: "关闭")
    static let automation2 = Automation(name: "关窗开灯", enabled: true, comparingData: "窗帘", comparingMethod: "关闭", comparingValue: -1, targetData: "LED", targetMethod: "打开/关闭")
    static let house = House(name: "YF312", gadgets: [gadget1, gadget2, gadget3, gadget4], automations: [automation1, automation2], temperature: 25, humidity: 75)
    static var previews: some View {
        NavigationView {
            AutomationView(house: house)
        }
    }
}
