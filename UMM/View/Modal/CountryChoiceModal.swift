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
            
            VStack(spacing: 0) {
                titleView
                countryArrayView
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
    
    private var titleView: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 32)
            HStack {
                Spacer()
                    .frame(width: 20)
                Text("지출 위치")
                    .foregroundStyle(.black)
                    .font(.display1)
                Spacer()
            }
            Spacer()
                .frame(height: 12)
        }
    }
    
    private var countryArrayView: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: 20)
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 12)
                    ForEach(countryArray, id: \.self) { country in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.gray100)
                                .layoutPriority(-1)
                                .opacity(chosenCountry == country ? 1.0 : 0.0000001)
                                .opacity((country == currentCountry && !countryIsModified) ? 0.0000001 : 1)
                            
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
                            .padding(.horizontal, 13)
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
                                .opacity((chosenCountry == currentCountry && countryIsModified) ? 1.0 : 0.0000001)
                            
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
