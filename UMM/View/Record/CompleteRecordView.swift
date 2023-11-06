//
//  CompleteRecordView.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI

struct CompleteRecordView: View {
    @ObservedObject var viewModel: RecordViewModel
    
    var body: some View {
        VStack(spacing: 60) {
            Button {
                if let fileName = viewModel.soundRecordFileName {
//                    viewModel.startPlayingAudio(url: fileName)
                }
            } label: {
                Text("Play Audio")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            
            Button {
                if let fileName = viewModel.soundRecordFileName {
//                    viewModel.stopPlayingAudio()
                }
            } label: {
                Text("Stop Audio")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    CompleteRecordView(viewModel: RecordViewModel())
}
