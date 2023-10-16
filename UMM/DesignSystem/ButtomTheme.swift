//
//  ButtomTheme.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/16.
//

import SwiftUI

struct LargeButtonActive: View {
    
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.vertical, 17)
                .frame(maxWidth: .infinity)
            
        }
        .background(Color.black)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 45)
        .background(Color.white)
    }
}

struct LargeButtonUnactive: View {
    
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.vertical, 17)
                .frame(maxWidth: .infinity)
            
        }
        .background(Color.gray)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 45)
        .background(Color.white)
    }
}

struct MediumButtonWhite: View {
    
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.black)
                .padding(.vertical, 17)
                .frame(maxWidth: .infinity)

        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.leading, 16)
    }
}

struct MediumButtonMain: View {
    
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.vertical, 17)
                .frame(maxWidth: .infinity)
        }
        .background(Color.red)
        .cornerRadius(12)
        .padding(.trailing, 16)
    }
}

struct MediumButtonActive: View {
    
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.vertical, 17)
                .frame(maxWidth: .infinity)
        }
        .background(Color.black)
        .cornerRadius(12)
        .padding(.trailing, 16)
    }
}

struct MediumButtonUnactive: View {
    
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.vertical, 17)
                .frame(maxWidth: .infinity)
        }
        .background(Color.gray)
        .cornerRadius(12)
        .padding(.leading, 16)
    }
}

struct NextButtonActive: View {
    
    var title: String = "다음"
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Image(systemName: "chevron.right")
            }
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.vertical, 13)
                .padding(.leading, 28)
                .padding(.trailing, 20)
                .frame(width: 116, height: 50, alignment: .center)
        }
        .background(Color.black)
        .cornerRadius(12)
        .padding(.trailing, 16)
        .padding(.bottom, 45)
    }
}

struct NextButtonUnactive: View {
    
    var title: String = "다음"
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Image(systemName: "chevron.right")
            }
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.vertical, 13)
                .padding(.leading, 28)
                .padding(.trailing, 20)
                .frame(width: 116, height: 50, alignment: .center)
        }
        .background(Color.gray)
        .cornerRadius(12)
        .padding(.trailing, 16)
        .padding(.bottom, 45)
    }
}

struct DoneButtonActive: View {
    
    var title: String = "완료"
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.vertical, 13)
                .frame(width: 116, height: 50, alignment: .center)
        }
        .background(Color.black)
        .cornerRadius(12)
        .padding(.trailing, 16)
        .padding(.bottom, 45)
    }
}

struct DoneButtonUnactive: View {
    
    var title: String = "완료"
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
                Text(title)
            
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.vertical, 13)
                .frame(width: 116, height: 50, alignment: .center)
        }
        .background(Color.gray)
        .cornerRadius(12)
        .padding(.trailing, 16)
        .padding(.bottom, 45)
    }
}

struct ButtomThemeTemplate: View {
    var body: some View {
        VStack(spacing: 20) {
            LargeButtonActive(title: "저장하기") {}
            LargeButtonUnactive(title: "저장하기") {}
            
            HStack {
                MediumButtonWhite(title: "저장하기") {}
                MediumButtonMain(title: "저장하기") {}
            }
            
            HStack {
                MediumButtonUnactive(title: "저장하기") {}
                MediumButtonActive(title: "저장하기") {}
            }

            HStack {
                NextButtonActive {}
                NextButtonUnactive {}
            }
            
            HStack {
                DoneButtonActive {}
                DoneButtonUnactive {}
            }
        }
    }
}

#Preview {
    ButtomThemeTemplate()
}
