//
//  ViewController.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 29.4.24..
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackgroundImage()
        view.bringSubviewToFront(register)
        view.bringSubviewToFront(signIn)
        view.bringSubviewToFront(liveHealthy)
        view.bringSubviewToFront(feelGreat)
        view.bringSubviewToFront(carrot)
        view.bringSubviewToFront(line)
        signIn.titleLabel?.font = .systemFont(ofSize: 26)
        register.titleLabel?.font = .systemFont(ofSize: 26)
    }
    
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var feelGreat: UILabel!
    @IBOutlet weak var liveHealthy: UILabel!
    @IBOutlet weak var carrot: UIImageView!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var signIn: UIButton!
    
    
    @IBAction func signInButton(_ sender: Any) {
        
        if let parametersVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParametersVC") as? ParametersVC {
            
            parametersVC.isRegister = false
            self.navigationController?.pushViewController(parametersVC, animated: true)
            
        }
        
    }
    
    @IBAction func registerButton(_ sender: Any) {
        
        if let parametersVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParametersVC") as? ParametersVC {
            parametersVC.isRegister = true
            self.navigationController?.pushViewController(parametersVC, animated: true)
        }
    }
    
    private func configureBackgroundImage() {
            // Create an image view with the background image
            let imageView = UIImageView(image: UIImage(named: "signin"))
            imageView.contentMode = .scaleAspectFill
            imageView.frame = view.bounds
            imageView.clipsToBounds = true
            view.addSubview(imageView)
           
            let shadeView = UIView(frame: view.bounds)
            shadeView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            view.addSubview(shadeView)
        
        }
    
    
}
