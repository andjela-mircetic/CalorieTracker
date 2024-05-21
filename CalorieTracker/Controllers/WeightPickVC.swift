//
//  WeightPickVC.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 18.5.24..
//

import UIKit

class WeightPickVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private let pickerView = UIPickerView()
    private let confirmButton = UIButton(type: .system)
    private let instructionLabel = UILabel()
    weak var parentVC: UIViewController?
    private var weights: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWeights()
        setupUI()
    }
    
    private func setupWeights() {
        for weight in stride(from: 45.0, to: 120.5, by: 0.5) {
            weights.append(String(format: "%.1f kg", weight))
        }
    }
    
    private func setupUI() {
        instructionLabel.text = "Choose your goal weight"
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        view.addSubview(instructionLabel)
        
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .lightGray
        view.addSubview(pickerView)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 90),
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.backgroundColor = .systemGreen
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        confirmButton.layer.cornerRadius = 10
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 90),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 200),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func confirmButtonTapped() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let selectedWeightStr = weights[selectedRow]
        
        let numericPart = selectedWeightStr.dropLast(3)
        if let selectedWeight = Double(numericPart) {
           
            if(parentVC is DashboardVC) {
                UserInfo.shared.goalWeight = selectedWeight
                let tabBarController = TabBarController()
                tabBarController.modalPresentationStyle = .fullScreen
                self.present(tabBarController, animated: true, completion: nil) }
            else {
                UserInfo.shared.currentWeight = selectedWeight
                self.dismiss(animated: true)
            }
        } else {
            print("Failed to convert weight to Double")
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weights.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return weights[row]
    }
}

