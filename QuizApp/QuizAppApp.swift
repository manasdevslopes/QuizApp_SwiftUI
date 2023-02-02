//
//  QuizAppApp.swift
//  QuizApp
//
//  Created by MANAS VIJAYWARGIYA on 01/02/23.
//

import SwiftUI
import Firebase

@main
struct QuizAppApp: App {
  init() {
    FirebaseApp.configure()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView().persistentSystemOverlays(.hidden)
    }
  }
}
