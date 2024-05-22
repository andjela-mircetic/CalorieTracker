//
//  Food.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 21.5.24..
//

import Foundation

struct Food: Codable {
    let name: String
    let calories: Int
    let unit: String
    let proteins: Double
    let carbs: Double
    let fat: Double
}

struct FoodData: Codable {
    
        let food: [String: Food]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
            var foodDict = [String: Food]()
            
            for key in container.allKeys {
                let food = try container.decode(Food.self, forKey: key)
                foodDict[key.stringValue] = food
            }
            
            self.food = foodDict
        }
        
    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        
        init?(intValue: Int) {
            return nil
        }
    }
}
