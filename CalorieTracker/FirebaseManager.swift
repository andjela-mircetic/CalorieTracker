//
//  Network.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 15.5.24..
//

import Foundation
import Firebase
import FirebaseAuth

class FirebaseManager {
    
    static let shared = FirebaseManager()
    public var allFood: [Food] = []
    public var eatenFood: [Food] = []
    private var myToken = ""
    
    private init() {}
    
    func calculateBMI(weight: Double, height: Double) -> Double {
        let heightInMeters = Double(height) / 100.0
        let bmi2 = weight / (heightInMeters * heightInMeters)
        return bmi2
    }
    
    func registerUser(username: String, password: String, height: String, weight: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Auth.auth().createUser(withEmail: username, password: password) { authResult, error in
            if let error = error {
                completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error creating auth user"])))
            } else {
                
            let userData: [String: Any] = [
                    "username": username,
                    "password": password,
                    "height": Int(height) ?? 0,
                    "weight": Int(weight) ?? 0,
                    "currentWeight": Double(weight) ?? 0,
                    "goalWeight": 0,
                    "bmi": self.calculateBMI(weight: Double(weight)!, height: Double(height)!),
                    "isFirstTimeLogging": true,
                    "plan": 1
                ]
                
                let usersRef = Database.database().reference().child("users")
                usersRef.observeSingleEvent(of: .value) { snapshot, _ in
                    guard let users = snapshot.value as? [String: [String: Any]] else {
                        completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user data"])))
                        return
                    }
                    
                    for (_, userData) in users {
                        if let storedUsername = userData["username"] as? String, storedUsername == username {
                            
                            completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "User with the same username already exists"])))
                            return
                        }
                    }
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: userData) else {
                        print("Error serializing user data to JSON")
                        completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error serializing user data to JSON"])))
                        return
                    }
                    
                    authResult?.user.getIDToken { token, error in
                        if let error = error {
                            completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error getting ID token: \(error.localizedDescription)"])))
                            return
                        }
                        
                        guard let token = token else {
                            completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])))
                            return
                        }
                        
                        self.myToken = token
                        //if let token = authResult?.user.getIDToken() {
                        let endpoint = "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/users.json?auth=\(token)"
                        var request = URLRequest(url: URL(string: endpoint)!)
                        request.httpMethod = "POST"
                        request.httpBody = jsonData
                       // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                        
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            guard let httpResponse = response as? HTTPURLResponse else {
                                
                                print("Invalid server response")
                                completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
                                return
                            }
                            
                            if (200...299).contains(httpResponse.statusCode) {
                                print("User registered successfully!")
                                DispatchQueue.main.async {
                                    completion(.success(()))
                                }
                            } else {
                                print("Error registering user: \(httpResponse.statusCode)")
                                if let responseData = data,
                                   let errorResponse = String(data: responseData, encoding: .utf8) {
                                    print("Error response: \(errorResponse)")
                                }
                                completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error registering user"])))
                                return
                            }
                        }
                    task.resume()
                    }
                }
            }
        }
    }
    
    func addDiary(diaries1: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        
        let diariesRef = Database.database().reference().child("diaries")
        diariesRef.observeSingleEvent(of: .value) { snapshot, _ in

            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: diaries1) else {
                print("Error serializing diaries data to JSON")
                completion(.failure(NSError(domain: "DiariesManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error serializing diaries data to JSON"])))
                return
            }
            
            let endpoint = "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/diaries.json?auth=\(self.myToken)"
            var request = URLRequest(url: URL(string: endpoint)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid server response")
                    completion(.failure(NSError(domain: "DiariesManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    print("Diary registered successfully!")
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } else {
                    print("Error registering diary: \(httpResponse.statusCode)")
                    if let responseData = data,
                       let errorResponse = String(data: responseData, encoding: .utf8) {
                        print("Error response: \(errorResponse)")
                    }
                    completion(.failure(NSError(domain: "DiariesManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error registering diary"])))
                    return
                }
            }
            task.resume()
        }
    }
        
    func signInUser(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Auth.auth().signIn(withEmail: username, password: password) { authResult, error in
            if let error = error {
                print("Authentication error: \(error.localizedDescription)")
                completion(.failure(NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid username or password"])))
                return
            }
            
            var userFound = false
           // let group = DispatchGroup()
            
            let usersRef = Database.database().reference().child("users")
            usersRef.observeSingleEvent(of: .value) { (snapshot) in
                guard let users = snapshot.value as? [String: [String: Any]] else {
                    
                    print("failed to retrieve data")
                    print("Snapshot value:", snapshot.value ?? "nil")
                    completion(.failure(NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user data"])))
                    
                    return
                }
               
                for (_, userData) in users {
                    if let storedUsername = userData["username"] as? String,
                       let storedPassword = userData["password"] as? String,
                       storedUsername == username && storedPassword == password {
                       userFound = true
                        
                        authResult?.user.getIDToken { token, error in
                            if let error = error {
                                completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error getting ID token: \(error.localizedDescription)"])))
                                //group.leave()
                                completion(.failure(NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user data"])))
                                   
                                return
                            }
                            
                            guard let token = token else {
                                completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])))
                                //group.leave()
                                
                                return
                            }
                            
                            self.myToken = token
                           // group.enter()
                            
                            self.fetchUserData(forUsername: username, token: token) { result in
                                switch result {
                                case .success():
                                    
                                    let today = Date()
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    let dateString = dateFormatter.string(from: Date())
                                    
                                  //  group.enter()///
                                    self.fetchDiariesData(forUsername: username, date: dateString) { result in
                                        switch result {
                                        case .success():
                                            self.loadFoodData2 {
                                                //userFound = true
                                                DispatchQueue.main.async {
                                                    completion(.success(()))
                                                    return }
                                                //group.leave()
                                            }
                                        case .failure(let error):
                                            print("Error: \(error.localizedDescription)")
                                            completion(.failure(NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user data"])))
                                               
                                            return
                                           // group.leave()
                                        }
                                    }
        
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                    //group.leave()
                                    completion(.failure(NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user data"])))
                                       
                                    return
                                }
                            }
                        }
                        
                        break
                    }
                }
//                
//                group.notify(queue: .main) {
//                    if userFound {
//                        print("User authenticated successfully!")
//                        
//                        completion(.success(()))
//                    } else {
//                        print("Invalid username or password")
//                        completion(.failure(NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid username or password"])))
//                    }
//                }
            }
        }
    }
    
    func fetchUserData(forUsername username: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        
        let baseUrl = "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/users.json?auth=\(token)"
        guard let url = URL(string: baseUrl) else {
            completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
          
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: [String: Any]] {
                    
                    if let userData = json.values.first(where: { ($0["username"] as? String) == username }) {
                        let uid = json.first(where: { $0.value["username"] as? String == username })?.key as! String
                        //self.userData = userData
                        
                        UserInfo.shared.setUserData(ud: userData)
                        UserInfo.shared.uid = uid
                        
                        completion(.success(()))
                    } else {
                       
                        completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                    }
                } else {
                    completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
        
    func fetchDiariesData(forUsername username: String, date: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let baseUrl = "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/diaries.json?auth=\(self.myToken)"
        guard let url = URL(string: baseUrl) else {
            completion(.failure(NSError(domain: "Diaries", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Diaries", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(NSError(domain: "Diaries", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
          
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: [String: Any]] {
                    
                    if let diariesData = json.values.first(where: { ($0["user"] as? String) == username && ($0["date"] as? String) == date}) {
                        let did = json.first(where: { $0.value["user"] as? String == username && ($0.value["date"] as? String) == date})?.key as! String
                        
                        DiariesManager.shared.setDiaries(ud: diariesData)
                        DiariesManager.shared.did = did
                        
                        completion(.success(()))
                    } else {
                        
                        let diariesData: [String: Any] = [
                            "user": username,
                            "date": date,
                            "caloriesEaten": 0,
                            "goalCalories": Int(UserInfo.shared.caloriesNeeded),
                            "caloriesLeft": Int(UserInfo.shared.caloriesNeeded),
                            "foods": [:]
                        ]
                        
                        self.addDiary(diaries1: diariesData) { result in
                            switch result {
                            case .success():
                                DiariesManager.shared.setDiaries(ud: diariesData)
                                completion(.success(()))
                            case .failure(_):
                                completion(.failure(NSError(domain: "Diaries", code: 0, userInfo: [NSLocalizedDescriptionKey: "error creating diary"])))
                            }
                        }
                       
                    }
                } else {
                    completion(.failure(NSError(domain: "Diaries", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func changeValue(of key: String, with value: Any, completion: @escaping (Result<Void, Error>) -> Void) {
        let username = UserInfo.shared.username
        let baseUrl = "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/users.json?auth=\(self.myToken)"
        guard let url = URL(string: baseUrl) else {
            completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
           
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: [String: Any]],
                    let user = json.values.first(where: { ($0["username"] as? String) == username }) {
                    let uid = json.first(where: { $0.value["username"] as? String == username })?.key as! String
                   
                    var updatedUser = user
                    updatedUser[key] = value
                    
                    guard let updatedData = try? JSONSerialization.data(withJSONObject: updatedUser) else {
                        completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error serializing user data to JSON"])))
                        return
                    }
                    
                    guard let updateUserUrl = URL(string: "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/users/\(uid).json?auth=\(self.myToken)") else {
                        completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                        return
                    }
                    
                    var updateRequest = URLRequest(url: updateUserUrl)
                    updateRequest.httpMethod = "PUT"
                    updateRequest.httpBody = updatedData
                    
                    URLSession.shared.dataTask(with: updateRequest) { _, _, updateError in
                        if let updateError = updateError {
                            completion(.failure(updateError))
                        } else {
                            completion(.success(()))
                        }
                    }.resume()
                } else {
                    completion(.failure(NSError(domain: "UserInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    func changeValueDiary(of key: String, with value: Any, isPost: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let username = UserInfo.shared.username
        let date = DiariesManager.shared.date
        let baseUrl = "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/diaries.json?auth=\(self.myToken)"
        guard let url = URL(string: baseUrl) else {
            completion(.failure(NSError(domain: "DiariesManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "DiariesManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(NSError(domain: "DiariesManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
           
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: [String: Any]],
                    let diary = json.values.first(where: { ($0["user"] as? String) == username && ($0["date"] as? String) == date}) {
                   
                    let did = json.first(where: { $0.value["user"] as? String == username && ($0.value["date"] as? String) == date})?.key as! String
                   
                    var updatedDiary = diary
                    updatedDiary[key] = value
                    
                    guard let updatedData = try? JSONSerialization.data(withJSONObject: updatedDiary) else {
                        completion(.failure(NSError(domain: "DiariesManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error serializing user data to JSON"])))
                        return
                    }
                    
                    guard let updateUserUrl = URL(string: "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/diaries/\(did).json?auth=\(self.myToken)") else {
                        completion(.failure(NSError(domain: "DiariesManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                        return
                    }
                    
                    var updateRequest = URLRequest(url: updateUserUrl)
                    
                    updateRequest.httpMethod = isPost ? "POST" : "PUT"
                    updateRequest.httpBody = updatedData
                    
                    URLSession.shared.dataTask(with: updateRequest) { _, _, updateError in
                        if let updateError = updateError {
                            completion(.failure(updateError))
                        } else {
                            completion(.success(()))
                        }
                    }.resume()
                } else {
                    completion(.failure(NSError(domain: "DiariesManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Diary not found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func loadFoodData2(completion: @escaping () -> Void) {
        guard let url = URL(string: "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/food.json?auth=\(self.myToken)") else {
                   print("Invalid URL")
                   return
               }
               
               var request = URLRequest(url: url)
               request.httpMethod = "GET"
               
               let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                   guard let self = self else { return }
                   
                   if let error = error {
                       print("Error: \(error)")
                       completion()
                       return
                   }
                   
                   guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                       print("Invalid response")
                       completion()
                       return
                   }
                   
                   if let data = data {
                       do {
                           let foodData = try JSONDecoder().decode(FoodData.self, from: data)
                           self.allFood = Array(foodData.food.values)

                         print("LOADED")
                           completion()
                       } catch {
                           print("Error decoding JSON: \(error)")
                           completion()
                       }
                   }
               }
               
               task.resume()
    }


}
