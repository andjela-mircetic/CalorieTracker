//
//  DiariesManager.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 20.5.24..
//

import Foundation

class DiariesManager {
    static let shared = DiariesManager()
    
    private var diaries: [String: Any]?
    var did: String = ""
    
    private init() {
        
    }
    
    func setDiaries(ud: [String: Any]?){
        self.diaries = ud
       
    }
    
    var user: String? {
        return diaries?["user"] as? String
    }
    
    var date: String? {
        return diaries?["date"] as? String
    }
    
    var caloriesEaten: Int? {
        return diaries?["caloriesEaten"] as? Int
    }
    
    var caloriesLeft: Int? {
        return diaries?["caloriesLeft"] as? Int
    }
    
    var goalCalories: Int? {
        return diaries?["goalCalories"] as? Int
    }
    
    var foods: [String: Any]? {
        return diaries?["foods"] as? [String: Any]
    }
    
}
