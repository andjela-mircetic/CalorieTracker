//
//  TabBarController.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 14.5.24..
//

import UIKit

class TabBarController: UITabBarController {
    
    private var homeTitleLabel: UILabel?
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        
        self.tabBar.tintColor = .systemGreen
        self.tabBar.unselectedItemTintColor = .systemGray
        self.tabBar.isTranslucent = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCustomNotification(_:)), name: .myCustomNotification, object: nil)
    }
    
    private func setupTabs(){
        let home = createNav(title: "Diary", image: UIImage(systemName: "house"), identifier: "HomeController", buttonTitle: "calendar", action: #selector(calendarButtonTapped))
        let myAcc = createNav(title: "My account", image: UIImage(systemName: "person"), identifier: "MyAccountController", buttonTitle: "person.crop.circle", action: #selector(myAccountButtonTapped))
        
        self.setViewControllers([home, myAcc], animated: true)
    }
    
    private func createNav(title: String, image: UIImage?, identifier: String, buttonTitle: String, action: Selector? = nil) -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.sizeToFit()
        titleLabel.font = UIFont.systemFont(ofSize: 33)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        nav.viewControllers.first?.navigationItem.titleView = titleLabel
        
        if title == "Diary" {
            self.homeTitleLabel = titleLabel
        }
        
        let customButton = UIBarButtonItem(image: UIImage(systemName: buttonTitle), style: .plain, target: nil, action: action)
        nav.viewControllers.first?.navigationItem.rightBarButtonItem = customButton
        nav.viewControllers.first?.navigationItem.rightBarButtonItem?.tintColor = .systemGreen
        
        return nav
    }
    
    @objc private func myAccountButtonTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            self.logOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        
        if let selectedViewController = self.selectedViewController {
            selectedViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func logOut() {
        self.dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let VC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                VC.modalPresentationStyle = .fullScreen
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    if let window = appDelegate.window {
                        window.rootViewController?.present(VC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc private func calendarButtonTapped() {
        let datePickerModalVC = DatePickerViewController()
        datePickerModalVC.modalPresentationStyle = .custom
        datePickerModalVC.transitioningDelegate = self
        datePickerModalVC.selectedDate = self.selectedDate
        self.present(datePickerModalVC, animated: true, completion: nil)
    }
    
    @objc private func handleCustomNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo, let date = userInfo["date"] as? String {
            homeTitleLabel?.text = date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.selectedDate = dateFormatter.date(from: date)
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .myCustomNotification, object: nil)
    }
    
}

extension TabBarController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}
