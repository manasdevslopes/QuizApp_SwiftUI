//
//  Question.swift
//  QuizApp
//
//  Created by MANAS VIJAYWARGIYA on 01/02/23.
//

import Foundation

struct Question: Identifiable, Codable {
  var id: UUID = .init()
  var question: String
  var options: [String]
  var answer: String
  
  var tappedAnswer: String = ""
  
  enum CodingKeys: CodingKey {
    case question
    case options
    case answer
  }
}
