//
//  NotificationView.swift
//  YF312
//
//  Created by 娄俊逸 on 2022/10/5.
//

import SwiftUI

struct NotificationView: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(text: "通知")
    }
}
