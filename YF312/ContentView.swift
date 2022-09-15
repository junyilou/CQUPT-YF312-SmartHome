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
    
    static let gadget1 = Gadget(name: "大门", isOn: true, imageOn: "door.left.hand.open")
    static let gadget2 = Gadget(name: "LED", isOn: false, imageOn: "light.beacon.max.fill")
    static let gadget3 = Gadget(name: "窗帘", isOn: false, imageOn: "curtains.open")
    static let gadget4 = Gadget(name: "空调", isOn: true, imageOn: "air.conditioner.horizontal.fill")
    static let automation1 = Automation(name: "自动关门", enabled: false, comparingData: "温度", comparingMethod: "大于", comparingValue: 20.0, targetData: "大门", targetMethod: "关闭")
    static let automation2 = Automation(name: "关窗开灯", enabled: true, comparingData: "窗帘", comparingMethod: "关闭", comparingValue: -1, targetData: "LED", targetMethod: "打开/关闭")
    @StateObject var house = House(name: "YF312", gadgets: [gadget1, gadget2, gadget3, gadget4], automations: [automation1, automation2], temperature: 25, humidity: 75)
    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    Group {
                        if house.gadgets.count > 0 {
                            GridView(house: house)
                        } else {
                            Text("还没有添加设备")
                        }
                    }
                    HStack {
                        Image(systemName: "thermometer.medium")
                        Text(house.temperatureFormatted)
                        Image(systemName: "humidity")
                        Text(house.humidityFormatted)
                    }
                    .padding(.bottom)
                }
                .navigationTitle(house.name)
                .toolbar {
                    Button {
                        addGadgetShown = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $addGadgetShown) {
                AddGadgetView(house: house)
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
                    Button {
                        addAutomationShown = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(house.gadgets.count == 0)
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
