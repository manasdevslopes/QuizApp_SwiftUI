//
//  CustomButton.swift
//  QuizApp
//
//  Created by MANAS VIJAYWARGIYA on 02/02/23.
//

import SwiftUI

struct CustomButton: View {
  var title: String
  var onClick: ()->()
  
  var body: some View {
    Button {
      onClick()
    } label: {
      Text(title)
        .font(.title3)
        .fontWeight(.semibold).hAlign(.center).padding(.top,15).padding(.bottom,10).foregroundColor(.white)
        .background {
          Rectangle().fill(Color("Pink")).ignoresSafeArea()
        }
    }
    /// - Removing Padding
    .padding([.vertical, .horizontal], -15)
  }
}

struct CustomButton_Previews: PreviewProvider {
  static var previews: some View {
    CustomButton(title: "Start Test", onClick: {})
  }
}
