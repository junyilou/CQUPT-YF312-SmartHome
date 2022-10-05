//
//  GadgetView.swift
//  YF312
//
//  Created by 娄俊逸 on 2022/9/15.
//

import SwiftUI

struct historyTableView: View {
    let histories: [Date : String]
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 HH:mm:ss"
        return formatter
    }
    var body: some View {
        ScrollView {
            VStack {
                ForEach(histories.sorted(by: >), id: \.key) { key, value in
                    HStack {
                        Text(value)
                            .font(.headline)
                            .frame(maxWidth: 100, alignment: .leading)
                            .padding(.leading)
                        Text(historyTableView.dateFormatter.string(from: key))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.bottom, 1)
                }
            }
        }
    }
}

struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxHeight: 18)
            .foregroundColor(Color.init(uiColor: UIColor.systemBackground))
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
            .background(.primary)
            .clipShape(Capsule())
    }
}

struct GadgetView: View {
    @ObservedObject var house: House
    @ObservedObject var gadget: Gadget
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                Group {
                    if gadget.isMQTTDevice0 {
                        VStack {
                            HStack {
                                Text("亮度等级: \(gadget.valueMQTTFormatted)")
                                    .font(.title2)
                                Spacer()
                                Button {
                                    gadget.mqttPublish("{\"LED0\":\"breath\"}", house: house)
                                    gadget.histories[Date()] = "呼吸灯"
                                } label: {
                                    Image(systemName: "suit.heart")
                                        .modifier(ButtonModifier())
                                }
                                Button {
                                    gadget.setStatus(nil, house: house)
                                } label: {
                                    Image(systemName: "arrow.turn.down.left")
                                        .modifier(ButtonModifier())
                                }
                            }
                            Slider(value: $gadget.valueMQTT, in: 0...10, step: 1)
                        }
                    } else {
                        Button {
                            gadget.setStatus(!gadget.isOn, house: house)
                        } label: {
                            Image(systemName: gadget.isOn ? "lightswitch.on" : "lightswitch.off")
                                .font(.system(size: 100))
                                .frame(maxWidth: .infinity)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(gadget.isOn ? .green : .red)
                        }
                    }
                }
                .frame(maxHeight: geo.size.height * 0.3)
                Text("历史记录")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                Divider()
                historyTableView(histories: gadget.histories)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle(gadget.name)
    }
}

struct GadgetView_Previews: PreviewProvider {
    static let gadget1 = Gadget(name: "大门", isOn: false, imageOn: "door.left.hand.open")
    static let gadget2 = Gadget(name: "灯泡", isOn: true, imageOn: "lightbulb.fill")
    static let gadget3 = Gadget(name: "窗帘", isOn: false, imageOn: "curtains.open")
    static let gadget4 = Gadget(name: "空调", isOn: true, imageOn: "air.conditioner.horizontal.fill")
    static let gadget0 = Gadget(name: "LED0", isOn: true, imageOn: "light.beacon.max.fill")
    static let automation1 = Automation(name: "天热了开空调", enabled: false, comparingData: "温度", comparingMethod: "大于", comparingValue: 30.0, targetData: "空调", targetMethod: "打开")
    static let automation2 = Automation(name: "窗户与灯泡相互开关", enabled: true, comparingData: "窗帘", comparingMethod: "打开/关闭", comparingValue: -1, targetData: "灯泡", targetMethod: "打开/关闭")
    static let house = House(name: "YF312", gadgets: [gadget0, gadget1, gadget2, gadget3, gadget4], automations: [automation1, automation2])
    static var previews: some View {
        NavigationView {
            GadgetView(house:house, gadget: gadget0)
        }
    }
}
