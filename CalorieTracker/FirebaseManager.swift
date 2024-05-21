//
//  Network.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 15.5.24..
//

import Foundation
import Firebase

//cmd=option=let arrow za collapse

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private init() {}
    
    func calculateBMI(weight: Double, height: Double) -> Double {
        let heightInMeters = Double(height) / 100.0
        let bmi2 = weight / (heightInMeters * heightInMeters)
        return bmi2
    }
    
    func registerUser(username: String, password: String, height: String, weight: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let userData: [String: Any] = [
            "username": username,
            "password": password,
            "height": Int(height) ?? 0,
            "weight": Int(weight) ?? 0,
            "currentWeight": Double(weight) ?? 0,
            "goalWeight": 0,
            "bmi": calculateBMI(weight: Double(weight)!, height: Double(height)!),
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
            
            let endpoint = "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/users.json"
            var request = URLRequest(url: URL(string: endpoint)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
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
        
    func signInUser(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let group = DispatchGroup()
        var userFound = false
        
        let usersRef = Database.database().reference().child("users")
        usersRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let users = snapshot.value as? [String: [String: Any]] else {
                
                print("failed to retrieve data")
                print("Snapshot value:", snapshot.value ?? "nil")
                return
            }
            
            for (_, userData) in users {
                if let storedUsername = userData["username"] as? String,
                   let storedPassword = userData["password"] as? String,
                   storedUsername == username && storedPassword == password {
                    userFound = true
                                   
                    group.enter()
                    
                    self.fetchUserData(forUsername: username) { result in
                        switch result {
                        case .success():
                           // return
                            let today = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let dateString = dateFormatter.string(from: Date())
    
                            self.fetchDiariesData(forUsername: username, date: dateString) { result in
                                switch result {
                                case .success(): group.leave()
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                    group.leave()
                                } }
                           // group.leave()
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                            //return
                            group.leave()
                        }
                    }
                   // return
                    break
                }
            }
            
            group.notify(queue: .main) {
                if userFound {
                    print("User authenticated successfully!")
                    completion(.success(()))
                } else {
                    print("Invalid username or password")
                    completion(.failure(NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid username or password"])))
                }
            }
            //print("invalid username or password")
        }
    }
    
    func fetchUserData(forUsername username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let baseUrl = "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/users.json"
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
        let baseUrl = "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/diaries.json"
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
                       //ovde treba da se napravi novi objekat diary sa pocetnim vrednostima
                        print("napravi objekat")
                        completion(.success(()))
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
        let baseUrl = "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/users.json"
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
                    
                    guard let updateUserUrl = URL(string: "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/users/\(uid).json") else {
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

}
