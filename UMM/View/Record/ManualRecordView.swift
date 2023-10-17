//
//  ManualRecordView.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI

struct ManualRecordView: View {
    let viewModel: RecordViewModel
    
    var body: some View {
        VStack {
            titleBlockView
            propertyView
            saveButton
        }
    }
    
    private var titleBlockView: some View {
        VStack {
            Text("지출 기록")
            HStack {
                Text("니코랑 일본")
                Text("Day 2")
            }
        }
    }
    private var propertyView: some View {
        VStack {
            HStack {
                Text("소비 내역")
            }
            Button {
                
            } label: {
                Text("")
            }
        }
    }
    private var saveButton: some View {
        Button {
            print("sdfsd")
        } label: {
            Text("Save Button")
        }
    }
}

#Preview {
    ManualRecordView(viewModel: RecordViewModel())
}
