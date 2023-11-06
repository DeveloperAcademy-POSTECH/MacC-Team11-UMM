//
//  SettingView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/19.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            defaultSetting
            feedbackAndQuestion
            essentialSetting
            appVersion
            deleteAll
        }
        .navigationTitle("설정")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                })
            }
        }
    }
    
    private var defaultSetting: some View {
        Section {
            NavigationLink(destination: Text("기본 설정 앱")) {
                HStack(spacing: 0) {
                    Text("알림 설정")
                        .font(.subhead2_2)
                }
            }
            NavigationLink(destination: Text("기본 설정 앱")) {
                HStack(spacing: 0) {
                    Text("마이크 설정")
                        .font(.subhead2_2)
                }
            }
        } header: {
            Text("기본 설정")
                .font(.caption2)
                .foregroundStyle(.gray400) // 피그마에 확정 되지 않은 부분
        }
    }
    
    private var feedbackAndQuestion: some View {
        Section {
            NavigationLink(destination: Text("기본 설정 앱")) {
                HStack(spacing: 0) {
                    Text("버그 신고 및 피드백")
                        .font(.subhead2_2)
                }
            }
            NavigationLink(destination: Text("기본 설정 앱")) {
                HStack(spacing: 0) {
                    Text("앱 평가하기")
                        .font(.subhead2_2)
                }
            }
            NavigationLink(destination: Text("기본 설정 앱")) {
                HStack(spacing: 0) {
                    Text("팀 유목민 알아보기")
                        .font(.subhead2_2)
                }
            }
        } header: {
            Text("피드백 및 문의사항")
                .font(.caption2)
                .foregroundStyle(.gray400)
        }
    }
    
    private var essentialSetting: some View {
        Section {
            NavigationLink(destination: Text("기본 설정 앱")) {
                HStack(spacing: 0) {
                    Text("약관 및 정책")
                        .font(.subhead2_2)
                }
            }
            NavigationLink(destination: Text("기본 설정 앱")) {
                HStack(spacing: 0) {
                    Text("개인정보취급방침")
                        .font(.subhead2_2)
                }
            }
        } header: {
            Text("필수 설정")
                .font(.caption2)
                .foregroundStyle(.gray400)
        }
    }
    
    private var appVersion: some View {
        Section {
            HStack(spacing: 0) {
                Text("앱 버전(1.1.01")
                    .font(.subhead2_2)
                Spacer()
                Text("최신 버전")
                    .font(.subhead2_2)
                    .foregroundStyle(.gray400)
            }
        }
    }
    
    private var deleteAll: some View {
        Section {
            HStack(spacing: 0) {
                Text("모든 데이터 삭제하기")
                    .font(.subhead2_2)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    SettingView()
}
