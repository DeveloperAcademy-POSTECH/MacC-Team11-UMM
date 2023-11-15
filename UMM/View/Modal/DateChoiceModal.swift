//
//  DateChoiceModal.swift
//  UMM
//
//  Created by Wonil Lee on 11/6/23.
//

import SwiftUI

struct DateChoiceModal: View {
    @Binding var date: Date
    let startDate: Date
    let endDate: Date
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
        }
    }
    
    private var titleView: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 32)
            HStack {
                Spacer()
                    .frame(width: 20)
                Text("지출 일시")
                    .foregroundStyle(.black)
                    .font(.display1)
                Spacer()
            }
            Spacer()
                .frame(height: 12)
        }
    }
}

#Preview {
    DateChoiceModal(date: .constant(Date()), startDate: Date(), endDate: Date())
}
