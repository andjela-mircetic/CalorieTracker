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
    
//    func updateCaloriesAndFoods(with food: Food, parent: UIViewController?) {
//        var updatedCaloriesEaten = caloriesEaten
//        var updatedCaloriesLeft = caloriesLeft
//        var updatedFoods = foods
//        var isPost = false
//        if updatedFoods == nil {
//            isPost = true
//            updatedFoods = [:]
//        }
//        
//        updatedCaloriesEaten! += food.calories
//        updatedCaloriesLeft = (goalCalories ?? 0) - updatedCaloriesEaten!
//        if var foodCount = updatedFoods![food.name] as? Int {
//            foodCount += 1
//            updatedFoods![food.name] = foodCount
//        } else {
//            updatedFoods![food.name] = 1
//        }
//        
//        diaries?["caloriesEaten"] = updatedCaloriesEaten
//        diaries?["caloriesLeft"] = updatedCaloriesLeft
//        diaries?["foods"] = updatedFoods
//        
//        let dispatchGroup = DispatchGroup()
//        
//        dispatchGroup.enter()
//        FirebaseManager.shared.changeValueDiary(of: "caloriesEaten", with: updatedCaloriesEaten, isPost: false) { result in
//            switch result {
//            case .success():
//                print("foods \(String(describing: self.caloriesEaten))")
//            case .failure(let error):
//                print("Error updating calorieseaten: \(error)")
//            }
//            dispatchGroup.leave()
//        }
//        
//        dispatchGroup.enter()
//        dispatchGroup.notify(queue: .main) {
//            FirebaseManager.shared.changeValueDiary(of: "caloriesLeft", with: updatedCaloriesLeft, isPost: false) { result in
//                switch result {
//                case .success():
//                    print("foods \(String(describing: self.caloriesLeft))")
//                case .failure(let error):
//                    print("Error updating caloriesleft: \(error)")
//                }
//                dispatchGroup.leave()
//            }
//        }
//        
//        dispatchGroup.enter()
//        dispatchGroup.notify(queue: .main) {
//            FirebaseManager.shared.changeValueDiary(of: "foods", with: updatedFoods, isPost: isPost) { result in
//                switch result {
//                case .success():
//                    print("foods \(String(describing: self.foods))")
//                case .failure(let error):
//                    print("Error updating foods: \(error)")
//                }
//                dispatchGroup.leave()
//            }
//        }
//        
//        dispatchGroup.notify(queue: .main) {
//            NotificationCenter.default.post(name: .foodAdded, object: nil, userInfo: ["food": food])
//            if let parent = parent as? HomeController {
//                parent.foodChange()
//            }
//        }
//    }
    
    func updateCaloriesAndFoods2(with food: Food, parent: UIViewController?) {
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
        
        FirebaseManager.shared.changeValueDiary(of: "caloriesEaten", with: updatedCaloriesEaten, isPost: false) { result in
            switch result {
            case .success():
                print("Updated caloriesEaten: \(String(describing: self.caloriesEaten))")
                FirebaseManager.shared.changeValueDiary(of: "caloriesLeft", with: updatedCaloriesLeft, isPost: false) { result in
                    switch result {
                    case .success():
                        print("Updated caloriesLeft: \(String(describing: self.caloriesLeft))")
                        FirebaseManager.shared.changeValueDiary(of: "foods", with: updatedFoods, isPost: isPost) { result in
                            switch result {
                            case .success():
                                print("Updated foods: \(String(describing: self.foods))")
                                NotificationCenter.default.post(name: .foodAdded, object: nil, userInfo: ["food": food])
                                if let parent = parent as? HomeController {
                                    parent.foodChange()
                                }
                            case .failure(let error):
                                print("Error updating foods: \(error)")
                            }
                        }
                    case .failure(let error):
                        print("Error updating caloriesLeft: \(error)")
                    }
                }
            case .failure(let error):
                print("Error updating caloriesEaten: \(error)")
            }
        }
    }
}
