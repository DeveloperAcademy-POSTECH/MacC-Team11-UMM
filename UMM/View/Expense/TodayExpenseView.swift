//
//  TodayExpenseView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct TodayExpenseView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @ObservedObject var dummyRecordViewModel: DummyRecordViewModel
    @Binding var selectedTab: Int
    let namespace: Namespace.ID
    var pickerId: String { "picker" }
    
    init(selectedTab: Binding<Int>, namespace: Namespace.ID) {
        self.expenseViewModel = ExpenseViewModel()
        self.dummyRecordViewModel = DummyRecordViewModel()
        self._selectedTab = selectedTab
        self.namespace = namespace
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                travelPicker
                Spacer()
                settingView
            }
            todayExpenseHeader
            tabViewButton
            datePicker
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    drawExpensesByCountry // 결제 데이터 그리기: 국가 > 결제수단 순서로 분류
                    // dummyExpenseAddButton
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .onAppear {
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            
            expenseViewModel.filteredExpenses = expenseViewModel.getFilteredExpenses()
            expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.country })
        }
    }
    
    private var travelChoiceView: some View {
        Button {
            expenseViewModel.travelChoiceHalfModalIsShown = true
            print("expenseViewModel.travelChoiceHalfModalIsShown = true")
        } label: {
            ZStack {
                Capsule()
                    .foregroundStyle(.white)
                    .layoutPriority(-1)
                
                Capsule()
                    .strokeBorder(.mainPink, lineWidth: 1.0)
                    .layoutPriority(-1)
                
                HStack(spacing: 12) {
                    Text(expenseViewModel.selectedTravel?.name != "Default" ? expenseViewModel.selectedTravel?.name ?? "-" : "-")
                        .font(.subhead2_2)
                        .foregroundStyle(.black)
                    Image("recordTravelChoiceDownChevron")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                .padding(.vertical, 6)
                .padding(.leading, 16)
                .padding(.trailing, 12)
            }
        }
        .padding(.top, 80)
    }
    
    private var travelPicker: some View {
        Picker("현재 여행", selection: $expenseViewModel.selectedTravel) {
            ForEach(dummyRecordViewModel.savedTravels, id: \.self) { travel in
                Text(travel.name ?? "no name").tag(travel as Travel?) // travel의 id가 선택지로
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onReceive(expenseViewModel.$selectedTravel) { _ in
            DispatchQueue.main.async {
                expenseViewModel.filteredExpenses = expenseViewModel.getFilteredExpenses()
                expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.country })
                print("TodayExpenseView | onReceive | done")
            }
        }
    }
    
    private var settingView: some View {
        Button(action: {}, label: {
            Image(systemName: "wifi")
                .font(.system(size: 16))
                .foregroundStyle(.gray300)
        })
    }
    
    private var todayExpenseHeader: some View {
        HStack(spacing: 0) {
            Text("지출 관리")
                .font(.display2)
                .padding(.top, 12)
            Spacer()
        }
    }
    
    private var tabViewButton: some View {
        HStack(spacing: 0) {
            ForEach((TabbedItems.allCases), id: \.self) { item in
                TabBarItem(selectedTab: $selectedTab, namespace: namespace, title: item.title, tab: item.rawValue)
                    .padding(.top, 8)
            }
        }
        .padding(.top, 32)
    }
    
    private var datePicker: some View {
        CustomDatePicker(expenseViewModel: expenseViewModel, selectedDate: $expenseViewModel.selectedDate, pickerId: pickerId)
            .padding(.top, 16)
            .padding(.bottom, 20)
    }
    
    private var dummyExpenseAddButton: some View {
        Button {
            expenseViewModel.addExpense(travel: expenseViewModel.selectedTravel ?? Travel(context: dummyRecordViewModel.viewContext))
            DispatchQueue.main.async {
                expenseViewModel.filteredExpenses = expenseViewModel.getFilteredExpenses()
                expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.country })
            }
        } label: {
            Text("지출 추가")
        }
    }
    
    // 국가별 + 결제수단별 지출액 표시
    private var drawExpensesByCountry: some View {
        let countryArray = [Int64](Set<Int64>(expenseViewModel.groupedExpenses.keys)).sorted { $0 < $1 }
        return ForEach(countryArray, id: \.self) { country in
            let paymentMethodArray = Array(Set((expenseViewModel.groupedExpenses[country] ?? []).map { $0.paymentMethod })).sorted { $0 < $1 }
            let expenseArray = expenseViewModel.groupedExpenses[country] ?? []
            let totalSum = expenseArray.reduce(0) { $0 + $1.payAmount }
            let currencies = Array(Set(expenseArray.map { $0.currency })).sorted { $0 < $1 }
            
            VStack(alignment: .leading, spacing: 0) {
                // 국기 + 국가명
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text("국기: \(country)").font(.subhead3_1)
                        Text("나라: \(country)").font(.subhead3_1)
                    }
                    
                    // 결제 수단: 전체: 합계
                    NavigationLink {
                        TodayExpenseDetailView(
                            selectedTravel: expenseViewModel.selectedTravel,
                            selectedDate: expenseViewModel.selectedDate,
                            selectedCountry: country,
                            selectedPaymentMethod: -2 // paymentMethod와 상관 없이 모든 expense를 보여주기 위해 임의 값을 설정
                        )
                    } label: {
                        HStack(spacing: 0) {
                            Text("금액 합: \(expenseViewModel.formatSum(totalSum))")
                                .font(.display3)
                                .foregroundStyle(.black)
                            Image(systemName: "wifi")
                                .font(.system(size: 16))
                                .padding(.leading, 16)
                                .foregroundStyle(.gray300)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 16)
                
                // 결제 수단: 개별: 합계
                ForEach(paymentMethodArray, id: \.self) { paymentMethod in
                    VStack(alignment: .leading, spacing: 0) {
                        let filteredExpenseArray = expenseArray.filter { $0.paymentMethod == paymentMethod }
                        // let sumPaymentMethod = filteredExpenseArray.reduce(0) { $0 + $1.payAmount }
                        
                        NavigationLink {
                            TodayExpenseDetailView(
                                selectedTravel: expenseViewModel.selectedTravel,
                                selectedDate: expenseViewModel.selectedDate,
                                selectedCountry: country,
                                selectedPaymentMethod: paymentMethod
                            )
                        } label: {
                            HStack(alignment: .center, spacing: 0) {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 0) {
                                        Text("결제 수단 : \(paymentMethod)")
                                            .font(.subhead2_1)
                                            .foregroundStyle(.gray300)
                                    }
                                    // 결제 수단: 개별, 화폐: 개별: 합계
                                    HStack(spacing: 0) {
                                        ForEach(currencies.indices, id: \.self) { index in
                                            let currency = currencies[index]
                                            let sum = filteredExpenseArray.filter({ $0.currency == currency }).reduce(0) { $0 + $1.payAmount }
                                            
                                            Text("\(currency): \(expenseViewModel.formatSum(sum))")
                                                .font(.subhead3_1)
                                                .foregroundStyle(.black)
                                            
                                            if index != currencies.count - 1 {
                                                Divider()
                                                    .font(.subhead2_1)
                                                    .foregroundStyle(.gray200)
                                                    .padding(.horizontal, 5)
                                            }
                                        }
                                    }
                                    .padding(.top, 12)
                                }
                                Spacer()
                                Image(systemName: "wifi")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.gray300)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.bottom, 10)
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
        }
    } // draw
}

struct CurrencySum {
    let currency: Int64
    let sum: Double
}
