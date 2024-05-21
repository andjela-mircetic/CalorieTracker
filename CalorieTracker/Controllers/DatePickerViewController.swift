//
//  DatePickerViewController.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 19.5.24..
//
import UIKit

class DatePickerViewController: UIViewController {
    
    var selectedDate: Date?
    
    private let headerLabel: UILabel = {
           let label = UILabel()
           label.text = "Select Date"
           label.textAlignment = .center
           label.font = UIFont.boldSystemFont(ofSize: 18)
           label.translatesAutoresizingMaskIntoConstraints = false
           return label
       }()

       private let datePicker: UIDatePicker = {
           let picker = UIDatePicker()
           picker.datePickerMode = .date
           picker.preferredDatePickerStyle = .inline
           picker.translatesAutoresizingMaskIntoConstraints = false
           return picker
       }()

       private let confirmButton: UIButton = {
           let button = UIButton(type: .system)
           button.setTitle("Confirm", for: .normal)
           button.translatesAutoresizingMaskIntoConstraints = false
           button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
           return button
       }()

       override func viewDidLoad() {
           super.viewDidLoad()

           view.backgroundColor = .white
           view.layer.cornerRadius = 15
           view.layer.masksToBounds = true

           if let selectedDate = selectedDate {
               datePicker.date = selectedDate
           }
           
           setupUI()
       }

       private func setupUI() {
           view.addSubview(headerLabel)
           view.addSubview(datePicker)
           view.addSubview(confirmButton)

           NSLayoutConstraint.activate([
               headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
               headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

               datePicker.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
               datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

               confirmButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
               confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
               confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25)
           ])
       }

    @objc private func confirmButtonTapped() {
        let selectedDate = datePicker.date
        print(selectedDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let stringDate = dateFormatter.string(from: selectedDate)
        
        NotificationCenter.default.post(name: .myCustomNotification, object: nil, userInfo: ["date": stringDate])
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension Notification.Name {
    static let myCustomNotification = Notification.Name("myCustomNotification")
}



