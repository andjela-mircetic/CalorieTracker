//
//  DiariesManager.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 20.5.24..
//

import Foundation
import UIKit

class DiariesManager {
    static let shared = DiariesManager()
    
    private var diaries: [String: Any]?
    var did: String = ""
    var progress: Double = 0
    
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
    
    func updateCaloriesAndFoods(with food: Food, parent: UIViewController?) {
        var updatedCaloriesEaten = caloriesEaten
        var updatedCaloriesLeft = caloriesLeft
        var updatedFoods = foods
        var isPost = false
        if updatedFoods == nil {
            isPost = true
            updatedFoods = [:]
        }
        
        updatedCaloriesEaten! += food.calories
        updatedCaloriesLeft = (goalCalories ?? 0) - updatedCaloriesEaten!
        if var foodCount = updatedFoods![food.name] as? Int {
            foodCount += 1
            updatedFoods![food.name] = foodCount
        } else {
            updatedFoods![food.name] = 1
        }
        
        diaries?["caloriesEaten"] = updatedCaloriesEaten
        diaries?["caloriesLeft"] = updatedCaloriesLeft
        diaries?["foods"] = updatedFoods
       
        
        //firebase do smt
        
        FirebaseManager.shared.changeValueDiary(of: "caloriesEaten", with: updatedCaloriesEaten, isPost: false, completion: { _ in
            // print("calorieseaten success")
        })
        FirebaseManager.shared.changeValueDiary(of: "caloriesLeft", with: updatedCaloriesLeft, isPost: false, completion: { _ in
            print("caloriesleft \(self.caloriesLeft)")
        })
        FirebaseManager.shared.changeValueDiary(of: "foods", with: updatedFoods, isPost: isPost, completion: { _ in
            print("foods \(self.foods)")
        })
        
        //post notif
        NotificationCenter.default.post(name: .foodAdded, object: nil, userInfo: ["food": food])
        if let parent1 = parent as? HomeController {
            parent1.foodChange()
        }
    }
}
