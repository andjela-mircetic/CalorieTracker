//
//  ArrowProgressView.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 19.5.24..
//

import UIKit

class ArrowProgressView: UIView {

        private let arrowImageView = UIImageView()
        private var arrowLeadingConstraint: NSLayoutConstraint!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupViews()
        }
        
        private func setupViews() {
            arrowImageView.image = UIImage(systemName: "arrow.down")
            arrowImageView.tintColor = .systemGreen
            arrowImageView.contentMode = .scaleAspectFit
            addSubview(arrowImageView)
            arrowImageView.translatesAutoresizingMaskIntoConstraints = false
            arrowLeadingConstraint = arrowImageView.leadingAnchor.constraint(equalTo: leadingAnchor)
            NSLayoutConstraint.activate([
                arrowImageView.topAnchor.constraint(equalTo: topAnchor),
                arrowLeadingConstraint,
                arrowImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.05), // Adjust the width as needed
                arrowImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        func setProgress(_ progress: CGFloat) {
            let maxLeadingInset = bounds.width - arrowImageView.bounds.width
            arrowLeadingConstraint.constant = maxLeadingInset * progress
            layoutIfNeeded()
        }

}
