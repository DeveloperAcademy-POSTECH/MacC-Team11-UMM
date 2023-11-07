//
//      CompleteRecordView.swift
//      UMM
//
//      Created by Wonil Lee on 10/16/23.
//

import AVFoundation
import SwiftUI

struct CompleteRecordView: View {
    
    var viewModel = CompleteRecordViewModel()
    
    var body: some View {
        VStack(spacing: 60) {
            Button { // 코어 데이터의 소리 데이터 재생하는 예시
                var expenseArray: [Expense] = []
                do {
                    expenseArray = try PersistenceController.shared.container.viewContext.fetch(Expense.fetchRequest()).filter {
                        $0.voiceRecordFile != nil
                    }.sorted {
                        $0.payDate ?? Date.distantPast >= $1.payDate ?? Date.distantPast
                    } // 실제로는 디테일 뷰에 해당하는 expense를 다루면 될 것이다.
                } catch {
                    print("error fetching expenseArray: \(error.localizedDescription)")
                }
                
                guard let expense = expenseArray.first else { return }
                
                if let audioData = expense.voiceRecordFile {
                    let audioURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY HH:mm:ss")).m4a")
                    try? audioData.write(to: audioURL)
                    
                    viewModel.startPlayingAudio(url: audioURL)
                }
                
            } label: {
                Text("Play Audio in Core Data")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            
            Button {
                viewModel.stopPlayingAudio()
            } label: {
                Text("Stop Audio")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    CompleteRecordView()
}

class CompleteRecordViewModel: NSObject, ObservableObject {
    
    private var audioPlayer: AVAudioPlayer?
    
    func startPlayingAudio(url: URL) {
        
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
        } catch {
            print("Playing Failed")
        }
    }
    
    func stopPlayingAudio() {
        audioPlayer?.stop()
    }
}

extension CompleteRecordViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            if flag {
                // 재생이 성공적으로 끝났을 때 실행할 코드
            } else {
                // 재생이 실패했을 때 실행할 코드
                print("Failed to play recorded audio.")
            }
        }
}
