//
//  FillAnimationView.swift
//  FillanimationTest
//
//  Created by Alex K. on 20/04/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit

class FillAnimationView: UIView {

    fileprivate struct Constant {
        static let path = "path"
        static let circle = "circle"
    }
}

// MARK: public

extension FillAnimationView {

    class func animationViewOnView(_ view: UIView, color: UIColor) -> FillAnimationView {
        let animationView = Init(FillAnimationView(frame: CGRect.zero)) {
            $0.backgroundColor = color
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(animationView)

        // add constraints
        [NSLayoutConstraint.Attribute.left, .right, .top, .bottom].forEach { attribute in
            (view, animationView) >>>- { $0.attribute = attribute; return }
        }

        return animationView
    }

    func fillAnimation(_ color: UIColor, centerPosition: CGPoint, duration: Double) {

        let radius = max(bounds.size.width, bounds.size.height) * 1.5
        let circle = createCircleLayer(centerPosition, radius: 1, startAngle: 0, endAngle: CGFloat(2.0 * Double.pi), color: color, clockwise: true)//(centerPosition, radius: 1, color: color, clockwise: true)

        let animation = animationToRadius(radius, center: centerPosition, duration: duration)
        animation.setValue(circle, forKey: Constant.circle)
        circle.add(animation, forKey: nil)
    }
    
    func fillAnimation2(_ color: UIColor, centerPosition: CGPoint, duration: Double) {

        let radius = 1
        let circle = createCircleLayer(centerPosition, radius: max(bounds.size.width, bounds.size.height) / 1.5, startAngle: CGFloat(2.0 * Double.pi), endAngle: 0, color: color, clockwise: false)

        let animation = animationToRadius2(CGFloat(radius), center: centerPosition, duration: duration)
        animation.setValue(circle, forKey: Constant.circle)
        circle.add(animation, forKey: nil)
    }
}

// MARK: create

extension FillAnimationView {

    fileprivate func createCircleLayer(_ position: CGPoint, radius:CGFloat, startAngle:CGFloat, endAngle:CGFloat, color: UIColor, clockwise:Bool) -> CAShapeLayer {
        let path = UIBezierPath(arcCenter: position, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        let layer = Init(CAShapeLayer()) {
            $0.path = path.cgPath
            $0.fillColor = color.cgColor
            $0.shouldRasterize = true
        }

        self.layer.addSublayer(layer)
        return layer
    }
}

// MARK: animation

extension FillAnimationView: CAAnimationDelegate {

    fileprivate func animationToRadius(_ radius: CGFloat, center: CGPoint, duration: Double) -> CABasicAnimation {
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2.0 * Double.pi), clockwise: true)
        let animation = Init(CABasicAnimation(keyPath: Constant.path)) {
            $0.duration = duration
            $0.toValue = path.cgPath
            $0.isRemovedOnCompletion = false
            $0.fillMode = .forwards
            $0.delegate = self
            $0.timingFunction = CAMediaTimingFunction(name: .easeIn)
        }
        return animation
    }
    
    fileprivate func animationToRadius2(_ radius: CGFloat, center: CGPoint, duration: Double) -> CABasicAnimation {
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(2.0 * Double.pi), endAngle: 0, clockwise: false)
        let animation = Init(CABasicAnimation(keyPath: Constant.path)) {
            $0.duration = duration
            $0.toValue = path.cgPath
            $0.isRemovedOnCompletion = false
            $0.fillMode = .forwards
            $0.delegate = self
            $0.timingFunction = CAMediaTimingFunction(name: .easeIn)
        }
        return animation
    }

    // animation delegate

    func animationDidStop(_ anim: CAAnimation, finished _: Bool) {

        guard let circleLayer = anim.value(forKey: Constant.circle) as? CAShapeLayer else {
            return
        }
        layer.backgroundColor = circleLayer.fillColor
        circleLayer.removeFromSuperlayer()
    }
}
