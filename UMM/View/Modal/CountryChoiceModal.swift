//
//  CountryChoiceModal.swift
//  UMM
//
//  Created by Wonil Lee on 10/31/23.
//

import SwiftUI

struct CountryChoiceModal: View {
    @Binding var chosenCountry: Country
    @Binding var countryIsModified: Bool
    let countryArray: [Country]
    let currentCountry: Country
    
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 32)
                titleView
                Spacer()
                    .frame(height: 24)
                countryArrayView
                Spacer()
            }
        }
    }
    
    private var titleView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            Text("지출 위치")
                .foregroundStyle(.black)
                .font(.display1)
            Spacer()
        }
    }
    
    private var countryArrayView: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: 20)
            ScrollView {
                VStack {
                    ForEach(countryArray, id: \.self) { country in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.gray100)
                                .layoutPriority(-1)
                                .opacity(chosenCountry == country ? 1.0 : 0.0000001)
                            
                            HStack {
                                Image(country.flagImageString)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding(.vertical, 13)
                                
                                Text(country.title)
                                    .foregroundStyle(.black)
                                    .font(.subhead3_2)
                                    .padding(.vertical, 16)
                                
                                Spacer()
                            }
                        }
                        .onTapGesture {
                            chosenCountry = country
                            countryIsModified = true
                        }
                    }
                    
                    if !countryArray.contains(currentCountry) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.gray100)
                                .layoutPriority(-1)
                                .opacity(chosenCountry == currentCountry ? 1.0 : 0.0000001)
                            
                            HStack {
                                Image(currentCountry.flagImageString)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding(.vertical, 13)
                                
                                Text(currentCountry.title)
                                    .foregroundStyle(.black)
                                    .font(.subhead3_2)
                                    .padding(.vertical, 16)
                                
                                Spacer()
                            }
                        }
                        .onTapGesture {
                            chosenCountry = currentCountry
                            countryIsModified = true
                        }
                    }
                }
            }
            Spacer()
                .frame(width: 20)
        }
    }
}

#Preview {
    CountryChoiceModal(chosenCountry: .constant(.usa), countryIsModified: .constant(true), countryArray: [.china, .usa, .japan, .france], currentCountry: .korea)
}
