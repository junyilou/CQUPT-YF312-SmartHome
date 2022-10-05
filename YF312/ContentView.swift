//
//  ContentView.swift
//  YF312
//
//  Created by 娄俊逸 on 2022/9/15.
//

import SwiftUI

struct ContentView: View {

    @State private var addGadgetShown = false
    @State private var addAutomationShown = false
    @State private var connectViewShown = false
    
    static let gadget1 = Gadget(name: "大门", isOn: false, imageOn: "door.left.hand.open")
    static let gadget2 = Gadget(name: "灯泡", isOn: true, imageOn: "lightbulb.fill")
    static let gadget3 = Gadget(name: "窗帘", isOn: false, imageOn: "curtains.open")
    static let gadget4 = Gadget(name: "空调", isOn: true, imageOn: "air.conditioner.horizontal.fill")
    static let automation1 = Automation(name: "天热了开空调", enabled: false, comparingData: "温度", comparingMethod: "大于", comparingValue: 30.0, targetData: "空调", targetMethod: "打开")
    static let automation2 = Automation(name: "窗户与灯泡相互开关", enabled: true, comparingData: "窗帘", comparingMethod: "打开/关闭", comparingValue: -1, targetData: "灯泡", targetMethod: "打开/关闭")
    @StateObject var house = House(name: "YF312", gadgets: [gadget1, gadget2, gadget3, gadget4], automations: [automation1, automation2])
    @StateObject var mqttManager = MQTTManager.shared()
    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    if house.notificationShown {
                        NotificationView(text: house.notificationText)
                            .padding([.horizontal, .top])
                    }
                    Group {
                        if house.gadgets.count > 0 {
                            GridView(house: house)
                        } else {
                            Text("还没有添加设备")
                        }
                    }
                    VStack(spacing: 6) {
                        HStack {
                            Image(systemName: "thermometer.medium")
                            Text(house.temperatureFormatted)
                            Image(systemName: "humidity")
                            Text(house.humidityFormatted)
                            Image(systemName: "light.max")
                            Text(house.ambientFormatted)
                        }
                        .font(.headline)
                        Text("最后更新: \(house.lastUpdate.formatted(date: .omitted, time: .standard))")
                            .font(.caption)
                    }
                    .padding(.bottom)
                }
                .navigationTitle(house.name)
                .toolbar {
                    HStack {
                        Button {
                            connectViewShown = true
                        } label: {
                            Image(systemName: "network")
                        }
                        Button {
                            addGadgetShown = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $addGadgetShown) {
                AddGadgetView(house: house)
            }
            .sheet(isPresented: $connectViewShown) {
                ConnectView(house: house, mqttManager: mqttManager)
            }
            .tabItem {
                Label("家", systemImage: "house.circle.fill")
            }
            .navigationViewStyle(.stack)
            NavigationView {
                Group {
                    if house.automations.count > 0 {
                        AutomationView(house: house)
                    } else {
                        Text("还没有添加自动化")
                    }
                }
                .navigationTitle("自动化")
                .toolbar {
                    HStack {
                        Button {
                            addAutomationShown = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .disabled(house.gadgets.count == 0)
                    }
                }
            }
            .sheet(isPresented: $addAutomationShown) {
                AddAutomationView(house: house)
            }
            .tabItem {
                Label("自动化", systemImage: "gearshape.2.fill")
            }
            .navigationViewStyle(.stack)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
