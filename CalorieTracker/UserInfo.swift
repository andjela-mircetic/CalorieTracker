//
//  UserInfo.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 15.5.24..
//

import Foundation
import Combine

class UserInfo {
    static let shared = UserInfo()
    
    private var userData: [String: Any]?
    var uid: String = ""
    var caloriesNeeded = 0.0
    
    private init() {
        
    }
    
    func setUserData(ud: [String: Any]?){
        self.userData = ud
        currentWeight = userData?["currentWeight"] as? Double
        bmi = userData?["bmi"] as? Double
        caloriesNeeded = calculateCalories(weight: weight ?? 0, height: height ?? 0, goal: plan ?? 0)
    }
    
    var username: String? {
        return userData?["username"] as? String
    }
    
    var password: String? {
        return userData?["password"] as? String
    }
    
    var height: Int? {
        return userData?["height"] as? Int
    }
    
    var weight: Int? {
        get {
            return userData?["weight"] as? Int
        }
        set {
            userData?["weight"] = newValue
            FirebaseManager.shared.changeValue(of: "weight", with: newValue as Any) { result in
                switch result {
                case .success():
                    print("successfully changed value of weight with \(newValue ?? nil)")
                case .failure(let error):
                    print("!!!error: \(error)")
                }
            }
        }
    }
    
   var goalWeight: Double? {
        get {
            return userData?["goalWeight"] as? Double
        }
        set {
            userData?["goalWeight"] = newValue
            FirebaseManager.shared.changeValue(of: "goalWeight", with: newValue as Any) { result in
                switch result {
                case .success():
                    print("successfully changed value of goalweight with \(newValue ?? nil)")
                case .failure(let error):
                    print("!!!error: \(error)")
                }
            }
        }
    }
    
    @Published var currentWeight: Double? {
        didSet {
            if let currentWeight = currentWeight {
                userData?["currentWeight"] = currentWeight
                FirebaseManager.shared.changeValue(of: "currentWeight", with: currentWeight as Any) { result in
                    switch result {
                    case .success():
                        print("successfully changed value of currentweight with \(currentWeight ?? nil)")
                    case .failure(let error):
                        print("!!!error: \(error)")
                    }
                }
            }
        }
    }
    
    var bmi: Double? {
        get {
            return userData?["bmi"] as? Double
        }
        set {
            userData?["bmi"] = newValue
            FirebaseManager.shared.changeValue(of: "bmi", with: newValue as Any) { result in
                switch result {
                case .success():
                    print("successfully changed value of bmi with \(newValue ?? nil)")
                case .failure(let error):
                    print("!!!error: \(error)")
                }
            }
        }
    }
    
    var isFirstTimeLogging: Bool? {
        get {
            return userData?["isFirstTimeLogging"] as? Bool
        }
        set {
            userData?["isFirstTimeLogging"] = newValue
            FirebaseManager.shared.changeValue(of: "isFirstTimeLogging", with: newValue as Any) { result in
                switch result {
                case .success():
                    print("successfully changed value of isFirstTimeLogging with \(newValue ?? false)")
                case .failure(let error):
                    print("!!!error: \(error)")
                }
            }
        }
    }
    
    var plan: Int? {
        get {
            return userData?["plan"] as? Int
        }
        set {
            userData?["plan"] = newValue
            FirebaseManager.shared.changeValue(of: "plan", with: newValue as Any) { result in
                switch result {
                case .success():
                    print("successfully changed value of plan with \(newValue ?? 0)")
                case .failure(let error):
                    print("!!!error: \(error)")
                }
            }
        }
    }
    
    func calculateCalories(weight: Int, height: Int, goal: Int) -> Double {
       
        let age = 30
       
        let bmr: Double = 10 * Double(weight) + 6.25 * Double(height) - 5 * Double(age) - 161
       
        let tdee = bmr * 1.375
        
        switch plan {
        case 1:
            return tdee - 500
        case 2:
            return tdee
        case 3:
            return tdee + 500
        default:
            return tdee
        }
    }
}
