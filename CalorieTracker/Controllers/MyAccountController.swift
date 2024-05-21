//
//  MyAccountController.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 14.5.24..
//

import UIKit
import Combine

class MyAccountController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        updateWeightView.addGestureRecognizer(tapGestureRecognizer)
        updateWeightView.isUserInteractionEnabled = true
        setupObservers()
    }
    
    private var cancellables = Set<AnyCancellable>()
    @IBOutlet weak var loseXkg: UILabel!
    @IBOutlet weak var proFullView: UIView!
    @IBOutlet weak var updateWeightView: UIView!
    @IBOutlet weak var arrowprogress: ArrowProgressView!
    @IBOutlet weak var startWeightLbl: UILabel!
    @IBOutlet weak var proView: UIView!
    @IBOutlet weak var loseKgView: UIView!
    @IBOutlet weak var goalWeightView: UIView!
    @IBOutlet weak var currentWeightView: UIView!
    @IBOutlet weak var currentWeightLbl: UILabel!
    @IBOutlet weak var goalWeightLbl: UILabel!
    @IBOutlet weak var startWeightView: UIView!
    @IBOutlet weak var bmiNumber: UILabel!
    @IBOutlet weak var bmiView: UIView!
    
    func setupUI() {
        proFullView.layer.cornerRadius = 10
        proView.layer.cornerRadius = 10
        loseKgView.layer.cornerRadius = 10
        bmiView.layer.cornerRadius = 10
        updateWeightView.layer.cornerRadius = 10
        goalWeightView.layer.cornerRadius = 15
        currentWeightView.layer.cornerRadius = 15
        startWeightView.layer.cornerRadius = 15
        
        let imageView = UIImageView(image: UIImage(named: "food1"))
        imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 10
            loseKgView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: loseKgView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: loseKgView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: loseKgView.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: loseKgView.bottomAnchor)
            ])
            
            loseKgView.sendSubviewToBack(imageView)
        
        if(UserInfo.shared.goalWeight == 0){
            loseXkg.text = "Maintain weight"
            goalWeightView.isHidden = true
            goalWeightLbl.isHidden = true
        }
        else if((Double(UserInfo.shared.weight!) - UserInfo.shared.goalWeight!) > 0) {
            loseXkg.text = "Lose \(Double(UserInfo.shared.weight!) - UserInfo.shared.goalWeight!) kg" }
        else if ((Double(UserInfo.shared.weight!) - UserInfo.shared.goalWeight!) < 0) {
            loseXkg.text = "Gain \(UserInfo.shared.goalWeight! - Double(UserInfo.shared.weight!)) kg"
        } else {
            loseXkg.text = "Maintain weight"
            goalWeightView.isHidden = true
            goalWeightLbl.isHidden = true
        }
        
        let weightString = "\(UserInfo.shared.weight!)"
        startWeightLbl.text = weightString
        currentWeightLbl.text = String(format: "%.1f", UserInfo.shared.currentWeight!)
        goalWeightLbl.text = String(format: "%.1f", UserInfo.shared.goalWeight!)
        bmiNumber.text = String(format: "%.1f", UserInfo.shared.bmi!)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let weightPick = storyboard.instantiateViewController(withIdentifier: "WeightPickVC") as? WeightPickVC {
            weightPick.parentVC = self
            self.present(weightPick, animated: true, completion: nil) }
    }
    
    private func setupObservers() {
        UserInfo.shared.$currentWeight
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newWeight in
                    self?.currentWeightLbl.text = String(format: "%.1f", newWeight ?? 0)
                    let heightInMeters = Double(UserInfo.shared.height!) / 100.0
                    let newBMI = newWeight! / (heightInMeters * heightInMeters)
                    UserInfo.shared.bmi = newBMI
                    let scaledBMI = (newBMI - 14) / (40 - 14)
                    self?.arrowprogress.setProgress(scaledBMI)
                    self?.bmiNumber.text = String(format: "%.1f", newBMI)
                }
                .store(in: &cancellables)
            
        }
}
