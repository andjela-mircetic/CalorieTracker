//
//  FoodViewController.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 21.5.24..
//

import UIKit

class FoodViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private var collectionView: UICollectionView!
    private var foods: [Food] = FirebaseManager.shared.allFood
    private var closeButton: UIButton!
    var parentController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "2D2D2D")
        setupCloseButton()
        setupCollectionView()
       // loadFoodData()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width - 50, height: 80)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(hex: "2D2D2D")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let nib = UINib(nibName: "FoodCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "FoodCell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("x", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitleColor(.systemGreen, for: .normal)

        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ])
        self.closeButton = closeButton
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
//    private func loadFoodData() {
//        guard let url = URL(string: "https://calorietracker-4b360-default-rtdb.europe-west1.firebasedatabase.app/food.json") else {
//                   print("Invalid URL")
//                   return
//               }
//               
//               var request = URLRequest(url: url)
//               request.httpMethod = "GET"
//               
//               let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
//                   guard let self = self else { return }
//                   
//                   if let error = error {
//                       print("Error: \(error)")
//                       return
//                   }
//                   
//                   guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//                       print("Invalid response")
//                       return
//                   }
//                   
//                   if let data = data {
//                       do {
//                           let foodData = try JSONDecoder().decode(FoodData.self, from: data)
//                           self.foods = Array(foodData.food.values)
//                           
//                           DispatchQueue.main.async {
//                               self.collectionView.reloadData()
//                           }
//                       } catch {
//                           print("Error decoding JSON: \(error)")
//                       }
//                   }
//               }
//               
//               task.resume()
//    }


    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foods.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCell", for: indexPath) as! FoodCell
        let food = foods[indexPath.item]
        cell.configure(with: food)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFood = foods[indexPath.item]
        DiariesManager.shared.updateCaloriesAndFoods2(with: selectedFood, parent: self.parentController ?? nil)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
