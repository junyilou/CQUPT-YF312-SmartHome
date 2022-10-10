//
//  ConnectView.swift
//  YF312
//
//  Created by 娄俊逸 on 2022/9/21.
//

import SwiftUI

struct ConnectView: View {
    @AppStorage("brokerAddress") private var brokerAddress: String = ""
    @ObservedObject var house: House
    @ObservedObject var mqttManager: MQTTManager
    @Environment (\.dismiss) var dismiss
    @FocusState private var keyboardFocus: Bool
    var body: some View {
        NavigationView {
            Form {
                Section("MQTT 信息") {
                    HStack {
                        Text("服务器")
                            .foregroundColor(.secondary)
                            .padding(.trailing)
                        TextField("地址", text: $brokerAddress)
                            .disableAutocorrection(true)
                            .textContentType(.URL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                            .focused($keyboardFocus)
                    }
                    HStack {
                        Text("订阅话题")
                            .foregroundColor(.secondary)
                            .padding(.trailing)
                        SecureField("话题", text: $house.topic)
                            .focused($keyboardFocus)
                    }
                }
                Section {
                    Button(action: { configureAndConnect() }) {
                        Text("启动连接")
                    }
                    .disabled(mqttManager.currentAppState.appConnectionState != .disconnected || brokerAddress.isEmpty)
                    Button(action: { mqttManager.disconnect() }) {
                        Text("断开连接")
                    }
                    .disabled(mqttManager.currentAppState.appConnectionState == .disconnected)
                    Button(action: { mqttManager.subscribe(topic: house.topic)} ) {
                        Text("订阅话题")
                    }
                    .disabled(mqttManager.currentAppState.appConnectionState != .connected && mqttManager.currentAppState.appConnectionState != .connectedUnSubscribed)
                    Button(action: { mqttManager.unSubscribeFromCurrentTopic() }) {
                        Text("退订话题")
                    }
                    .disabled(mqttManager.currentAppState.appConnectionState != .connectedSubscribed)
                } header: {
                    Text(mqttManager.connectionStateMessage())
                        .foregroundColor(mqttManager.isConnected() ? .green : nil)
                }
            }
            .toolbar {
                Button("关闭", action: { dismiss() })
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完成", action: { keyboardFocus = false })
                }
            }
            .navigationTitle("设置服务")
        }
    }

    private func configureAndConnect() {
        mqttManager.initializeMQTT(host: brokerAddress, identifier: UUID().uuidString, house: house)
        mqttManager.connect()
        house.client = mqttManager
    }
}

struct ConnectView_Previews: PreviewProvider {
    static let manager = MQTTManager.shared()
    static let house = House(name: "", gadgets: [], automations: [])
    static var previews: some View {
        ConnectView(house: house, mqttManager: manager)
    }
}
