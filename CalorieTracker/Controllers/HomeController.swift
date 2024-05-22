//
//  HomeController.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 14.5.24..
//

import UIKit

class HomeController: UIViewController {
    
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var caloriesEatenLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var txtLbl: UITextView!
    @IBOutlet weak var youCanStillEatLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(handleCustomNotification(_:)), name: .myCustomNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFoodNotification(_:)), name: .foodAdded, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFoodNotification(_:)), name: .foodAdded, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("HomeController viewWillDisappear")
        NotificationCenter.default.removeObserver(self, name: .foodAdded, object: nil)
    }
    
    
    func setupUI() {
        tipView.layer.cornerRadius = 10
        tipView.backgroundColor = .systemBrown
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.lineDashPattern = [9, 7]
        shapeLayer.cornerRadius = 10
        progressBar.progressTintColor = .systemYellow
        
        let path = UIBezierPath(roundedRect: tipView.bounds, cornerRadius: 10)
        shapeLayer.path = path.cgPath
        
        setupPlusButton()
        tipView.layer.addSublayer(shapeLayer)
        view.bringSubviewToFront(tipView)
        tipView.bringSubviewToFront(tipLabel)
        tipView.bringSubviewToFront(txtLbl)
        tipView.bringSubviewToFront(questionLbl)
        
        foodChange()
    }
    
    func setupPlusButton() {
        let plusButton = UIButton(type: .system)
        
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        plusButton.backgroundColor = .systemGreen
        plusButton.setTitleColor(.white, for: .normal)
        
        plusButton.layer.cornerRadius = 35
        
        view.addSubview(plusButton)
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            plusButton.widthAnchor.constraint(equalToConstant: 70),
            plusButton.heightAnchor.constraint(equalToConstant: 70),
        ])
        
        
        if #available(iOS 11.0, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                plusButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -35),
                plusButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20)
            ])
        } else {
            NSLayoutConstraint.activate([
                plusButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),
                plusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        }
        
        view.bringSubviewToFront(plusButton)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    @objc private func handleCustomNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo, let date = userInfo["date"] as? String {
            FirebaseManager.shared.fetchDiariesData(forUsername: UserInfo.shared.username!, date: date, completion: { _ in
              
                self.foodChange()
            })
        }
    }
    
    
    @objc private func handleFoodNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo, let food = userInfo["food"] as? String {
            foodChange()
        }
        
        // collectionView.reloadData() if necessary
    }
    
    public func foodChange() {
        DispatchQueue.main.async {
            self.caloriesEatenLabel.text = "\(String(format: "%.1f", Double(DiariesManager.shared.caloriesEaten ?? 0))) callories eaten"
            self.goalLabel.text = "Goal: \(String(format: "%.1f", Double(DiariesManager.shared.goalCalories ?? 0)))"
            self.youCanStillEatLabel.text = "You can still eat \(String(format: "%.1f", Double(DiariesManager.shared.caloriesLeft ?? 0))) calories"
            self.progressBar.setProgress(Float(Double(DiariesManager.shared.caloriesEaten ?? 0) / Double(DiariesManager.shared.goalCalories ?? 1)), animated: true)
            self.progressBar.progressTintColor = .systemYellow
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .myCustomNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .foodAdded, object: nil)
    }
    
    @objc private func plusButtonTapped() {
        let foodVC = FoodViewController()
        foodVC.modalPresentationStyle = .popover
        foodVC.parentController = self
        present(foodVC, animated: true, completion: nil)
    }
    
}
