//
//  CompleteRecordView.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI

struct CompleteRecordView: View {
    let viewModel: RecordViewModel
    
    var body: some View {
        VStack(spacing: 60) {
            Button {
                viewModel.startPlayingAudio(url: viewModel.fileName)
            } label: {
                Text("Play Audio")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            
            Button {
                viewModel.stopPlayingAudio(url: viewModel.fileName)
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
