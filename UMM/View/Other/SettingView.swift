//
//  SettingView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/19.
//

import SwiftUI
import CoreData

struct SettingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    let appID = 6470182505
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    @State private var isLatestVersion = false
    
    var body: some View {
        List {
            defaultSetting
            feedbackAndQuestion
            essentialSetting
            appVersionCheck
            //            deleteAll
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("설정")
        .navigationBarBackButtonHidden(true)
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
//                        .foregroundColor(.primary)
                })
            }
        }
        .onAppear {
            latestVersion { isLatest in
                isLatestVersion = isLatest
            }
        }
    }
    
    private var defaultSetting: some View {
        Section {
            listButton(title: "위치 설정", target: UIApplication.openSettingsURLString)
            listButton(title: "마이크 설정", target: UIApplication.openSettingsURLString)
        } header: {
            Text("기본 설정")
                .font(.caption2)
                .foregroundStyle(.gray400) // 피그마에 확정 되지 않은 부분
        }
    }
    
    private var feedbackAndQuestion: some View {
        Section {
            listButton(title: "버그 신고 및 피드백", target: "mailto:nomadwallet23@gmail.com")
            listButton(title: "앱 평가하기", target: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review")
            listButton(title: "팀 유목민 알아보기", target: "https://yejinms.notion.site/760c3405e6aa413cbd9f0463eecb8a16")
        } header: {
            Text("피드백 및 문의사항")
                .font(.caption2)
                .foregroundStyle(.gray400)
        }
    }
    
    private var essentialSetting: some View {
        Section {
            listButton(title: "약관 및 정책", target: "https://yejinms.notion.site/d5bef16aac0840d0ac56a6ef0e0580b8")
            listButton(title: "개인정보취급방침", target: "https://yejinms.notion.site/c27893465d774aca9230b7e7e6b9379c")
        } header: {
            Text("필수 설정")
                .font(.caption2)
                .foregroundStyle(.gray400)
        }
    }
    
    private var appVersionCheck: some View {
        Section {
            appUpdateButton(title: "앱 버전(\(appVersion ?? "-"))", target: "itms-apps://itunes.apple.com/app/id\(appID)")
        }
    }
    
    private var deleteAll: some View {
        Section {
            Button {
                deleteAllData()
            } label: {
                HStack(spacing: 0) {
                    Text("모든 데이터 삭제하기")
                        .font(.caption3)
                        .foregroundStyle(.red)
                }
            }
        }
    }
    
    private var chevronRight: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 16))
            .foregroundStyle(.gray300)
    }
    
    private func listButton(title: String, target: String) -> some View {
        return Button(action: {
            if let url = URL(string: target) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }, label: {
            HStack(spacing: 0) {
                Text("\(title)")
                    .font(.caption3)
                    .foregroundStyle(.black)
                Spacer()
                chevronRight
                
            }
        })
    }
    
    private func appUpdateButton(title: String, target: String) -> some View {
        return Button(action: {
            if let url = URL(string: target) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }, label: {
            HStack(spacing: 0) {
                Text("\(title)")
                    .font(.caption3)
                    .foregroundStyle(.black)
                Spacer()
                if isLatestVersion {
                    Text("최신 버전")
                        .font(.body1)
                        .foregroundStyle(.gray400)
                } else {
                    HStack(spacing: 6) {
                        Text("업데이트하기")
                            .font(.body1)
                            .foregroundStyle(.gray400)
                        chevronRight
                    }
                }
                
            }
        })
    }
    
    // 추후 확인 필요
    private func latestVersion(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=\(appID)") else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let appStoreVersion = results[0]["version"] as? String else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                completion(appStoreVersion == appVersion)
            }
        }.resume()
    }
    
    private func deleteAllData() {
        let entities = ["Expense", "Travel", "User"]
        for entity in entities {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try managedObjectContext.execute(deleteRequest)
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Error: \(error), \(error.userInfo)")
            }
        }
    }
}

#Preview {
    SettingView()
}
