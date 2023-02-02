//
//  Home.swift
//  QuizApp
//
//  Created by MANAS VIJAYWARGIYA on 01/02/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct Home: View {
  @State private var quizInfo: Info?
  @State private var questions: [Question] = []
  @State private var startQuiz: Bool = false
  
  /// - User Anonymous Log Status
  @AppStorage("log_status") private var logStatus: Bool = false
  
    var body: some View {
      if let info = quizInfo {
        VStack {
          Text(info.title)
            .font(.title)
            .fontWeight(.semibold)
            .hAlign(.leading)
          
          CustomLabel("list.bullet.rectangle.portrait", "\(questions.count)", "Multiple Choice Questions")
            .padding(.top, 20)
          
          CustomLabel("person", "\(info.peopleAttended)", "Attended the exercise")
            .padding(.top, 5)
          
          Divider()
            .padding(.horizontal, -15)
            .padding(.top, 15)
          
          if !info.rules.isEmpty {
            RulesView(info.rules)
          }
          
          CustomButton(title: "Start Test", onClick: { startQuiz.toggle() })
          .vAlign(.bottom)
        }
        .padding(15)
        .vAlign(.top)
        .fullScreenCover(isPresented: $startQuiz) {
          QuestionsView(info: info, questions: questions.shuffled(), onFinish: {
            quizInfo?.peopleAttended += 1
          })
        }
      } else {
        /// - Presenting Progress View
        VStack(spacing: 4) {
          ProgressView()
          Text("Please wait...")
            .font(.caption2)
            .foregroundColor(.gray)
        }
        .task {
          do {
            try await fetchData()
          } catch {
            print("fetchData----->", error.localizedDescription)
          }
        }
      }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

extension Home {
  func fetchData() async throws {
    try await loginUserAnonymous()
    let info = try await Firestore.firestore().collection("Quiz").document("Info").getDocument().data(as: Info.self)
    let questions = try await Firestore.firestore().collection("Quiz").document("Info").collection("Questions").getDocuments().documents.compactMap {
      try $0.data(as: Question.self)
    }
    
    await MainActor.run(body: {
      self.quizInfo = info
      self.questions = questions.shuffled()
    })
  }
  
  func loginUserAnonymous() async throws {
    if !logStatus {
      try await Auth.auth().signInAnonymously()
    }
  }
  
  @ViewBuilder
  func CustomLabel(_ image: String, _ title: String, _ subTitle: String) -> some View {
    HStack(spacing: 12) {
      Image(systemName: image)
        .font(.title3)
        .frame(width: 45, height: 45)
        .background {
          Circle().fill(.gray.opacity(0.1))
            .padding(-1)
            .background {
              Circle().stroke(Color("BG"), lineWidth: 1)
            }
        }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .fontWeight(.bold)
          .foregroundColor(Color("BG"))
        Text(subTitle)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.gray)
      }
      .hAlign(.leading)
    }
  }
  
  @ViewBuilder
  func RulesView(_ rules: [String]) -> some View {
    VStack(alignment: .leading, spacing: 15) {
      Text("Before you start")
        .font(.title3)
        .fontWeight(.bold)
        .padding(.bottom, 12)
      
      ForEach(rules, id: \.self) { rule in
        HStack(alignment: .top, spacing: 10) {
          Circle().fill(.black).frame(width: 8, height: 8).offset(y: 6)
          Text(rule)
            .font(.callout).lineLimit(3)
        }
      }
    }
  }
}

extension View {
  func hAlign(_ alignment: Alignment) -> some View {
    self
      .frame(maxWidth: .infinity, alignment: alignment)
  }
  func vAlign(_ alignment: Alignment) -> some View {
    self
      .frame(maxHeight: .infinity, alignment: alignment)
  }
}
