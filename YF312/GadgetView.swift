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

struct GadgetView: View {
    @ObservedObject var house: House
    @ObservedObject var gadget: Gadget
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                Button {
                    gadget.setStatus(!gadget.isOn, house: house)
                } label: {
                    Image(systemName: gadget.isOn ? "lightswitch.on" : "lightswitch.off")
                        .font(.system(size: 100))
                        .frame(maxWidth: .infinity)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(gadget.isOn ? .green : .red)
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
    static let gadget1 = Gadget(name: "大门", isOn: true, imageOn: "door.left.hand.open")
    static let gadget2 = Gadget(name: "LED", isOn: false, imageOn: "light.beacon.max.fill")
    static let gadget3 = Gadget(name: "窗帘", isOn: false, imageOn: "curtains.open")
    static let gadget4 = Gadget(name: "空调", isOn: true, imageOn: "air.conditioner.horizontal.fill")
    static let automation1 = Automation(name: "自动关门", enabled: false, comparingData: "温度", comparingMethod: "大于", comparingValue: 20.0, targetData: "大门", targetMethod: "关闭")
    static let automation2 = Automation(name: "关窗开灯", enabled: true, comparingData: "窗帘", comparingMethod: "关闭", comparingValue: -1, targetData: "LED", targetMethod: "打开/关闭")
    static let house = House(name: "YF312", gadgets: [gadget1, gadget2, gadget3, gadget4], automations: [automation1, automation2], temperature: 25, humidity: 75)
    
    static var previews: some View {
        NavigationView {
            GadgetView(house:house, gadget: gadget1)
        }
    }
}
