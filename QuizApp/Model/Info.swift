//
//  Info.swift
//  QuizApp
//
//  Created by MANAS VIJAYWARGIYA on 01/02/23.
//

import Foundation

struct Info: Codable {
  var title: String
  var peopleAttended: Int
  var rules: [String]
  
  enum CodingKeys: CodingKey {
    case title
    case peopleAttended
    case rules
  }
}
