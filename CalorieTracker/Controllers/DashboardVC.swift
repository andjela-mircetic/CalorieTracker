//
//  DashboardVC.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 13.5.24..
//

import Foundation
import UIKit

class DashboardVC: UIViewController {
    
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view1: UIView!
   
    @IBOutlet weak var gainLbl: UILabel!
    @IBOutlet weak var maintainLbl: UILabel!
    @IBOutlet weak var loseLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view1.addGestureRecognizer(tapGesture1)
        view2.addGestureRecognizer(tapGesture2)
        view3.addGestureRecognizer(tapGesture3)
        configUI()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else {
            return
        }
        UserInfo.shared.isFirstTimeLogging = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch tappedView.accessibilityIdentifier {
            case "view1": UserInfo.shared.plan = 1
            if let weightPick = storyboard.instantiateViewController(withIdentifier: "WeightPickVC") as? WeightPickVC {
                weightPick.parentVC = self
                self.present(weightPick, animated: true, completion: nil) }
            
            case "view2": UserInfo.shared.plan = 2
            let tabBarController = TabBarController()
            tabBarController.modalPresentationStyle = .fullScreen
            self.present(tabBarController, animated: true, completion: nil)
            
            case "view3": UserInfo.shared.plan = 3
            if let weightPick = storyboard.instantiateViewController(withIdentifier: "WeightPickVC") as? WeightPickVC {
                weightPick.parentVC = self
                self.present(weightPick, animated: true, completion: nil) }
            
            default: return
        }
        
       
    }
    
    func configUI() {
        view1.layer.cornerRadius = 10
        let imageView = UIImageView(image: UIImage(named: "view1"))
        imageView.frame = CGRect(x: 0, y: 0, width: view1.frame.width, height: view1.frame.height)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        view1.addSubview(imageView)
        let shadeView1 = UIView(frame: view1.bounds)
        shadeView1.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view1.addSubview(shadeView1)
        
        view2.layer.cornerRadius = 10
        let imageView2 = UIImageView(image: UIImage(named: "normal"))
        imageView2.frame = CGRect(x: 0, y: 0, width: view2.frame.width, height: view2.frame.height)
        imageView2.clipsToBounds = true
        imageView2.contentMode = .scaleAspectFill
        imageView2.layer.cornerRadius = 10
        view2.addSubview(imageView2)
        let shadeView2 = UIView(frame: view2.bounds)
        shadeView2.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view2.addSubview(shadeView2)

        
        view3.layer.cornerRadius = 10
        let imageView3 = UIImageView(image: UIImage(named: "fit"))
        imageView3.frame = CGRect(x: 0, y: 0, width: view3.frame.width, height: view3.frame.height)
        imageView3.clipsToBounds = true
        imageView3.contentMode = .scaleAspectFill
        imageView3.layer.cornerRadius = 10
        view3.addSubview(imageView3)
        let shadeView3 = UIView(frame: view3.bounds)
        shadeView3.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view3.addSubview(shadeView3)
        
        view3.bringSubviewToFront(gainLbl)
        view2.bringSubviewToFront(maintainLbl)
        view1.bringSubviewToFront(loseLabel)

    }
    
}
