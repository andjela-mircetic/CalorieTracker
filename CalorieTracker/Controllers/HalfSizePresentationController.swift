//
//  HalfSizePresentationController.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 19.5.24..
//

import UIKit

class HalfSizePresentationController: UIPresentationController {

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let height = containerView.bounds.height / 2
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.alpha = 0
        containerView.addSubview(dimmingView)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            dimmingView.alpha = 1
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        containerView?.subviews.last?.removeFromSuperview()
    }
}

