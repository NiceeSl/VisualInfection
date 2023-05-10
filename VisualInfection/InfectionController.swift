//
//  InfectionController.swift
//  VisualInfection
//
//  Created by Вячеслав Герасимов on 05.05.2023.
//

import UIKit

class InfectionController: UIViewController {
    
    @IBOutlet weak var infectedLAbel: UILabel!
    @IBOutlet weak var infectedNumberLabel: UILabel!

    let queue = DispatchQueue(label: "com.example.myqueue")
    
    var timer: Timer?
    
    var groupSize: Int!
    var infectionFactor: Int!
    var updatingPeriod: Int!
    
    var coloredPoints = Set<UIView>()
    var infectedCount: Int = 0
    var contentView : UIView!

    var longPressTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        print(groupSize!)
        print(infectionFactor!)
        print(updatingPeriod!)
        
        self.infectedNumberLabel.text = String(infectedCount)

        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = .white
        scrollView.isDirectionalLockEnabled = false
        scrollView.delaysContentTouches = false

        view.addSubview(scrollView)
        view.addSubview(infectedLAbel)
        view.addSubview(infectedNumberLabel)
        let screenSize = UIScreen.main.bounds.size
        var pointSize: CGFloat = 0
        var controllerSize: CGSize = .zero

        switch groupSize! {
        case 0..<10:
            pointSize = 200
            controllerSize = CGSize(width: screenSize.width * 0.5, height: screenSize.height * 0.5)
        case 10..<20:
            pointSize = 100
            controllerSize = CGSize(width: screenSize.width * 0.7, height: screenSize.height * 0.7)
        case 20..<30:
            pointSize = 70
            controllerSize = CGSize(width: screenSize.width * 0.9, height: screenSize.height * 0.9)
        default:
            pointSize = 30
            controllerSize = screenSize
        }
        preferredContentSize = controllerSize

        contentView = UIView(frame: CGRect(origin: .zero, size: controllerSize))
        contentView.frame = CGRect(origin: .zero, size: scrollView.contentSize)
        scrollView.contentSize = CGSize(width: screenSize.width * 2, height: screenSize.height * 2)
        scrollView.addSubview(contentView)
        contentView.frame = CGRect(origin: .zero, size: scrollView.contentSize)
        
        for _ in 1...groupSize {
            let x = CGFloat.random(in: 0...scrollView.contentSize.width)
            let y = CGFloat.random(in: 0...scrollView.contentSize.height)
            let point = UIView(frame: CGRect(x: x, y: y, width: pointSize, height: pointSize))
            point.backgroundColor = .green
            point.layer.cornerRadius = pointSize / 2
            contentView.addSubview(point)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            point.addGestureRecognizer(tapGesture)
        }
        
    }
        
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let point = gesture.view else { return }
        point.backgroundColor = .red
        
        let radius: CGFloat = 50.0
        let centerX = point.center.x
        let centerY = point.center.y
        
        var coloredPoints = [point]
        self.infectedCount = 1
        
        let semaphore = DispatchSemaphore(value: 1)
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(updatingPeriod), repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            var nextPoints = [UIView]()
            let subviews = self.contentView.subviews
            let maxInfectedCount = subviews.count
            
            for coloredPoint in coloredPoints {
                let coloredCenterX = coloredPoint.center.x
                let coloredCenterY = coloredPoint.center.y
                
                for subview in subviews {
                    guard nextPoints.count < maxInfectedCount else {
                        timer.invalidate()
                        return
                    }
                        
                        let neighbor = subview
                        
                        if neighbor == coloredPoint || coloredPoints.contains(neighbor) {
                            continue
                        }
                        
                        let neighborCenterX = neighbor.center.x
                        let neighborCenterY = neighbor.center.y
                        
                        let dx = coloredCenterX - neighborCenterX
                        let dy = coloredCenterY - neighborCenterY
                        let distance = sqrt(dx * dx + dy * dy)
                        
                        if distance <= radius {
                            if let neighborColoredCount = neighbor.tag as? Int, neighborColoredCount < self.infectionFactor {
                                semaphore.wait()
                                neighbor.backgroundColor = .red
                                neighbor.tag = neighborColoredCount + 1
                                nextPoints.append(neighbor)
                                semaphore.signal()
                            }
                        }
                    }
                }
                
                infectedCount += nextPoints.count
                DispatchQueue.main.async {
                    self.infectedNumberLabel.text = "\(self.infectedCount)"
                }
                
                coloredPoints = nextPoints
            }
        }

}
