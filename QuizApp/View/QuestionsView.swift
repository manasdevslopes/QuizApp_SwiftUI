//
//  QuestionsView.swift
//  QuizApp
//
//  Created by MANAS VIJAYWARGIYA on 01/02/23.
//

import SwiftUI
import FirebaseFirestore

struct QuestionsView: View {
  var info: Info
  @State var questions: [Question]
  var onFinish: ()->()
  
  @Environment(\.dismiss) private var dismiss
  
  @State private var progress: CGFloat = 0
  @State private var currentIndex: Int = 0
  @State private var score: CGFloat = 0
  @State private var showScoreCard: Bool = false
  
  var body: some View {
    VStack(spacing: 15) {
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .font(.title3).fontWeight(.semibold).foregroundColor(.white)
      }
      .hAlign(.leading)
      
      Text(info.title)
        .font(.title)
        .fontWeight(.semibold)
        .hAlign(.leading)
      
      GeometryReader {
        let size = $0.size
        ZStack(alignment: .leading) {
          Rectangle().fill(.black.opacity(0.2))
          Rectangle().fill(Color("Progress"))
            .frame(width: progress * size.width, alignment: .leading)
        }
        .clipShape(Capsule())
      }
      .frame(height: 20).padding(.top, 5)
      
      /// - Questions
      GeometryReader {_ in
        ForEach(questions.indices, id: \.self) { index in
          if currentIndex == index {
            QuestionView(questions[currentIndex])
              .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
          }
        }
      }
      /// - Removing padding
      .padding(.horizontal, -15)
      .padding(.vertical, 15)
      
      CustomButton(title: currentIndex == (questions.count - 1) ? "Finish" : "Next Question") {
        if (currentIndex == (questions.count - 1)){
          showScoreCard.toggle()
        } else {
          withAnimation(.easeInOut) {
            currentIndex += 1
            progress = CGFloat(currentIndex) / CGFloat(questions.count - 1)
          }
        }
      }
      .disabled(questions[currentIndex].tappedAnswer == "")
    }
    .padding(15)
    .hAlign(.center).vAlign(.top)
    .background {
      Color("BG").ignoresSafeArea()
    }
    .fullScreenCover(isPresented: $showScoreCard) {
      ScoreCardView(score: score / CGFloat(questions.count) * 100, onDismiss: {
        dismiss()
        onFinish()
      })
    }
    .environment(\.colorScheme, .dark)
    .persistentSystemOverlays(.hidden)
  }
}

struct QuestionsView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

extension QuestionsView {
  @ViewBuilder
  func QuestionView(_ question: Question) -> some View {
    VStack(alignment: .leading, spacing: 15) {
      Text("Question \(currentIndex + 1)/\(questions.count)")
        .font(.callout).foregroundColor(.gray).hAlign(.leading)
      
      Text(question.question)
        .font(.title3).fontWeight(.semibold).foregroundColor(.black)
      
      VStack(spacing: 12) {
        ForEach(question.options, id: \.self) { option in
          /// - Displaying Correct and wrong answers after users has tapped any one of the answer
          ZStack {
            OptionView(option, .gray)
              .opacity(question.answer == option && question.tappedAnswer != "" ? 0 : 1)
            OptionView(option, .green)
              .opacity(question.answer == option && question.tappedAnswer != "" ? 1 : 0)
            OptionView(option, .red)
              .opacity(question.tappedAnswer == option && question.tappedAnswer != question.answer ? 1 : 0)
          }
          .contentShape(Rectangle())
          .onTapGesture {
            /// - Disabling Tap if already Answer was Selected
            guard questions[currentIndex].tappedAnswer == "" else { return }
            withAnimation(.easeInOut) {
              questions[currentIndex].tappedAnswer = option
              
              if question.answer == option {
                score += 1
              }
            }
          }
        }
      }
      .padding(.vertical, 15)
    }
    .padding(15).hAlign(.center)
    .background {
      RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white)
    }
    .padding(.horizontal, 15)
  }
  
  @ViewBuilder
  func OptionView(_ option: String, _ tint: Color) -> some View {
    Text(option)
      .foregroundColor(tint).padding(.horizontal, 15).padding(.vertical, 20).hAlign(.leading)
      .background {
        RoundedRectangle(cornerRadius: 12, style: .continuous).fill(tint.opacity(0.15))
          .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .stroke(tint.opacity(tint == .gray ? 0.15 : 1), lineWidth: 2)
          }
      }
  }
}

struct ScoreCardView: View {
  var score: CGFloat
  
  var onDismiss: ()->()
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    VStack {
      VStack(spacing: 15) {
        Text("Result of your Exercise")
          .font(.title3).fontWeight(.semibold).foregroundColor(.white)
        
        VStack(spacing: 15) {
          Text("Congratulations! You\n have scored")
            .font(.title2).fontWeight(.semibold).multilineTextAlignment(.center)
          
          Text(String(format: "%.0f", score) + "%")
            .font(.title.bold()).padding(.bottom, 10)
          
          Text("🎖")
            .font(.system(size: 220, weight: .bold, design: .rounded))
        }
        .foregroundColor(.black).padding(.horizontal, 15).padding(.vertical, 20).hAlign(.center)
        .background {
          RoundedRectangle(cornerRadius: 25, style: .continuous).fill(.white)
        }
      }
      .vAlign(.center)
      
      CustomButton(title: "back To Home") {
        Firestore.firestore().collection("Quiz").document("Info").updateData([
          "peopleAttended" : FieldValue.increment(1.0)
        ])
        onDismiss()
        dismiss()
      }
    }
    .padding(15)
    .background {
      Color("BG")
        .ignoresSafeArea()
    }
  }
}
