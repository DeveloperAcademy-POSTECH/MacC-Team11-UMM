//
//  CategoryChoiceModal.swift
//  UMM
//
//  Created by Wonil Lee on 10/22/23.
//

import Foundation

import SwiftUI

struct CategoryChoiceModal: View {
    @ObservedObject private var redrawer = Redrawer()
    var viewModel: CategoryChoiceModalUsable
    
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 32)
                titleView
                Spacer()
                    .frame(height: 24)
                categoryView
            }
        }
    }
    
    private var titleView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            Text("카테고리 선택")
                .foregroundStyle(.black)
                .font(.display1)
            Spacer()
        }
    }
    
    private var categoryView: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: 20)
            // 식비 관광 교통 쇼핑 항공 숙소 기타
            let array0: [ExpenseInfoCategory] = [.food, .tour, .transportation, .shopping]
            let array1: [ExpenseInfoCategory] = [.plane, .room, .unknown]
            VStack(spacing: 0) {
                HStack {
                    ForEach(array0, id: \.self) { category in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.gray100)
                                .opacity(viewModel.category == category ? 1.0 : 0.0000001)
                                .layoutPriority(-1)
                            
                            VStack(spacing: 8) {
                                Image(category.modalImageString)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                                Text(category.visibleDescription)
                                    .foregroundStyle(.black)
                                    .font(.subhead2_2)
                            }
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                        }
                        .onTapGesture {
                            viewModel.setCategory(as: category)
                            redrawer.redraw()
                        }
                    }
                }
                Spacer()
                    .frame(height: 10)
                HStack {
                    ForEach(array1, id: \.self) { category in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.gray100)
                                .opacity(viewModel.category == category ? 1.0 : 0.0000001)
                                .layoutPriority(-1)
                            
                            VStack(spacing: 8) {
                                Image(category.modalImageString)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                                Text(category.visibleDescription)
                                    .foregroundStyle(.black)
                                    .font(.subhead2_2)
                            }
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                        }
                        .onTapGesture {
                            viewModel.setCategory(as: category)
                            redrawer.redraw()
                        }
                    }
                    Rectangle()
                        .foregroundStyle(.red)
                        .opacity(0.0000001)
                        .frame(height: 1)
                }
                Spacer()
            }
            Spacer()
                .frame(width: 20)
        }
    }
}
#Preview {
    CategoryChoiceModal(viewModel: ManualRecordViewModel())
}
