//
//  GridView.swift
//  YF312
//
//  Created by 娄俊逸 on 2022/9/15.
//

import SwiftUI

struct GridGadget: View {
    @ObservedObject var house: House
    @ObservedObject var gadget: Gadget
    var body: some View {
        VStack {
            Image(systemName: gadget.image)
                .font(.system(size: 54))
                .frame(maxHeight: 40)
                .padding(.vertical, 30)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)
            HStack {
                VStack(alignment: .leading) {
                    Text(gadget.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Text((gadget.isMQTTDevice0 ? (gadget.valueMQTT != 0) : (gadget.isOn)) ? "已开启" : "已关闭")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    gadget.setStatus(!gadget.isOn, house: house)
                } label: {
                    Image(systemName: gadget.isMQTTDevice0 ? "\(gadget.valueMQTTFormatted).circle.fill" : "power.circle.fill")
                        .font(.largeTitle)
                        .clipShape(Circle())
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle((gadget.isMQTTDevice0 ? (gadget.valueMQTT != 0) : (gadget.isOn)) ? .green : .red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
        }
        .background(Color(uiColor: UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct GridView: View {
    @ObservedObject var house: House
    let columns = [GridItem(.adaptive(minimum: 150))]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(house.gadgets) { gadget in
                    NavigationLink {
                        GadgetView(house: house, gadget: gadget)
                    } label: {
                        GridGadget(house: house, gadget: gadget)
                    }
                }
            }
        }
        .padding()
    }
}

struct GridView_Previews: PreviewProvider {
    static let gadget1 = Gadget(name: "大门", isOn: false, imageOn: "door.left.hand.open")
    static let gadget2 = Gadget(name: "灯泡", isOn: true, imageOn: "lightbulb.fill")
    static let gadget3 = Gadget(name: "窗帘", isOn: false, imageOn: "curtains.open")
    static let gadget4 = Gadget(name: "空调", isOn: true, imageOn: "air.conditioner.horizontal.fill")
    static let gadget0 = Gadget(name: "LED0", isOn: true, imageOn: "light.beacon.max.fill", valueMQTT: 10)
    static let automation1 = Automation(name: "天热了开空调", enabled: false, comparingData: "温度", comparingMethod: "大于", comparingValue: 30.0, targetData: "空调", targetMethod: "打开")
    static let automation2 = Automation(name: "窗户与灯泡相互开关", enabled: true, comparingData: "窗帘", comparingMethod: "打开/关闭", comparingValue: -1, targetData: "灯泡", targetMethod: "打开/关闭")
    static let house = House(name: "YF312", gadgets: [gadget0, gadget1, gadget2, gadget3, gadget4], automations: [automation1, automation2])
    static var previews: some View {
        GridView(house: house)
    }
}
