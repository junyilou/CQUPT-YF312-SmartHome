//
//  ConnectView.swift
//  YF312
//
//  Created by 娄俊逸 on 2022/9/21.
//

import SwiftUI

struct ConnectView: View {
    @State private var brokerAddress: String = ""
    @ObservedObject var house: House
    @ObservedObject var mqttManager: MQTTManager
    @Environment (\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            Form {
                Section("服务器信息") {
                    TextField("服务器地址", text: $brokerAddress)
                }
                Section("订阅信息") {
                    HStack {
                        Text("下载数据")
                            .foregroundColor(.secondary)
                            .padding(.trailing)
                        TextField("话题", text: $house.getURL)
                    }
                    HStack {
                        Text("上传数据")
                            .foregroundColor(.secondary)
                            .padding(.trailing)
                        TextField("话题", text: $house.setURL)
                    }
                }
                Section {
                    Button(action: {configureAndConnect()}){
                        Text("启动连接")
                    }
                    .disabled(mqttManager.currentAppState.appConnectionState != .disconnected || brokerAddress.isEmpty)
                    Button(action: {disconnect()}){
                        Text("断开连接")
                    }
                    .disabled(mqttManager.currentAppState.appConnectionState == .disconnected)
                } header: {
                    Text(mqttManager.connectionStateMessage())
                        .foregroundColor(mqttManager.isConnected() ? .green : nil)
                }
                Section {
                    Group {
                        Button(action: {mqttManager.subscribe(topic: house.getURL)}) {
                            Text("订阅下载话题")
                        }
                        Button(action: {mqttManager.subscribe(topic: house.setURL)}) {
                            Text("订阅上传话题")
                        }
                    }
                    .disabled(mqttManager.currentAppState.appConnectionState != .connected && mqttManager.currentAppState.appConnectionState != .connectedSubscribed && mqttManager.currentAppState.appConnectionState != .connectedUnSubscribed)
                    Button(action: {mqttManager.unSubscribeFromCurrentTopic()}) {
                        Text("退订话题")
                    }
                    .disabled(mqttManager.currentAppState.appConnectionState != .connectedSubscribed)
                }
            }
            .toolbar {
                Button("关闭", action: { dismiss() })
            }
            .navigationTitle("设置服务")
        }
    }

    private func configureAndConnect() {
        mqttManager.initializeMQTT(host: brokerAddress, identifier: UUID().uuidString, house: house)
        mqttManager.connect()
        house.client = mqttManager
    }

    private func disconnect() {
        mqttManager.disconnect()
    }
}

struct ConnectView_Previews: PreviewProvider {
    static let manager = MQTTManager.shared()
    static let house = House(name: "", gadgets: [], automations: [])
    static var previews: some View {
        ConnectView(house: house, mqttManager: manager)
    }
}
