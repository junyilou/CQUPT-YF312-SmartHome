//
//  AddGadgetView.swift
//  YF312
//
//  Created by 娄俊逸 on 2022/9/15.
//

import SwiftUI

struct typeTableView: View {
    @Binding var chosen: String
    @ObservedObject var gadget: Gadget
    let rows = [GridItem(.adaptive(minimum: 60))]
    let allGadgets = ["lightbulb.fill", "light.beacon.max.fill", "sensor.fill", "curtains.open", "door.left.hand.open", "dehumidifier.fill", "air.conditioner.horizontal.fill", "ellipsis"]
    var body: some View {
        LazyVGrid(columns: rows) {
            ForEach(allGadgets, id: \.self) { gadget in
                Image(systemName: gadget)
                    .font(.system(size: 30))
                    .frame(width: 60, height: 60)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.blue, .gray)
                    .background(.blue.opacity(chosen == gadget ? 0.2 : 0))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        guard gadget == "ellipsis" else {
                            chosen = gadget
                            return
                        }
                    }
            }
        }
    }
}

struct AddGadgetView: View {
    @ObservedObject var house: House
    @Environment(\.dismiss) var dismiss
    @State private var chosen = ""
    @StateObject var gadget = Gadget(name: "", isOn: false, imageOn: "", histories: [:])
    var body: some View {
        NavigationView {
            Form {
                Section("设备名称") {
                    TextField("名称", text: $gadget.name)
                }
                Section("设备类型") {
                    typeTableView(chosen: $gadget.imageOn, gadget: gadget)
                }
            }
            .navigationTitle("添加设备")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消", action: {dismiss()})
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加", action: {
                        gadget.histories[Date()] = "添加设备"
                        house.gadgets.append(gadget)
                        dismiss()
                    })
                    .disabled([gadget.name, gadget.imageOn].contains{$0.isEmpty})
                }
            }
        }
    }
}

struct AddGadgetView_Previews: PreviewProvider {
    static let house = House(name: "", gadgets: [], automations: [], temperature: 0, humidity: 0)
    static var previews: some View {
        AddGadgetView(house: house)
    }
}
