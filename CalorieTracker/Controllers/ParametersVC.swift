//
//  ParametersVC.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 9.5.24..
//

import Foundation
import UIKit
import Firebase

class ParametersVC: UIViewController {
    
    @IBOutlet weak var signIn: UIButton!
    
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var weigth: UITextField!
    @IBOutlet weak var height: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    public var isRegister: Bool = false
    
    @IBOutlet weak var weigthLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bodyText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
    }
    
    init(isRegister: Bool) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func updateUI() {
        bodyText.isHidden = !isRegister
        height.isHidden = !isRegister
        heightLabel.isHidden = !isRegister
        weigth.isHidden = !isRegister
        weigthLabel.isHidden = !isRegister
        register.isHidden = !isRegister
        signIn.isHidden = isRegister
        password.isSecureTextEntry = true
        
        weigth.backgroundColor = UIColor.black//.withAlphaComponent(0.5)
        weigth.borderStyle = .none
        weigth.layer.cornerRadius = 0
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: weigth.frame.height - 1, width: weigth.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        weigth.layer.addSublayer(bottomLine)
        weigth.textColor = .white
        
        height.backgroundColor = UIColor.black//.withAlphaComponent(0.5)
        height.borderStyle = .none
        height.layer.cornerRadius = 0
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: height.frame.height - 1, width: height.frame.width, height: 1.0)
        bottomLine2.backgroundColor = UIColor.white.cgColor
        height.layer.addSublayer(bottomLine2)
        height.textColor = .white
        
        username.backgroundColor = UIColor.black//.withAlphaComponent(0.5)
        username.borderStyle = .none
        username.layer.cornerRadius = 0
        let bottomLine3 = CALayer()
        bottomLine3.frame = CGRect(x: 0.0, y: username.frame.height - 1, width: username.frame.width, height: 1.0)
        bottomLine3.backgroundColor = UIColor.white.cgColor
        username.layer.addSublayer(bottomLine3)
        username.textColor = .white
        
        password.backgroundColor = UIColor.black//.withAlphaComponent(0.5)
        password.borderStyle = .none
        password.layer.cornerRadius = 0
        let bottomLine4 = CALayer()
        bottomLine4.frame = CGRect(x: 0.0, y: password.frame.height - 1, width: password.frame.width, height: 1.0)
        bottomLine4.backgroundColor = UIColor.white.cgColor
        password.layer.addSublayer(bottomLine4)
        password.textColor = .white
        
    }
    
    
    @IBAction func pressedRegister(_ sender: Any) {
        guard let username = username.text, !username.isEmpty,
              let password = password.text, !password.isEmpty,
              let height = height.text, !height.isEmpty,
              let weight = weigth.text, !weight.isEmpty else {
            DispatchQueue.main.async {
                self.showAlert(title: "Empty", message: "Please enter all parameters.")
            }
            return
        }
        
        FirebaseManager.shared.registerUser(username: username, password: password, height: height, weight: weight) {
            result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.showAlert(title: "Success", message: "You successfully registered!")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func pressedSignIn(_ sender: Any) {
        guard let username = username.text, !username.isEmpty,
              let password = password.text, !password.isEmpty else {
            showAlert(title: "Empty", message: "Please enter both username and password.")
            return }
        
        FirebaseManager.shared.signInUser(username: username, password: password) { result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    if UserInfo.shared.isFirstTimeLogging ?? true {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let dashboardVC = storyboard.instantiateViewController(withIdentifier: "DashboardVC") as? DashboardVC {
                            self.present(dashboardVC, animated: true, completion: nil) }
                    } else {
                        let tabBarController = TabBarController()
                        tabBarController.modalPresentationStyle = .fullScreen
                        self.present(tabBarController, animated: true, completion: nil) }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
        
    }
    
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if title == "Success" {
                self.dismiss(animated: true)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
}
