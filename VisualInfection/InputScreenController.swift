//
//  InputScreenController.swift
//  VisualInfection
//
//  Created by Вячеслав Герасимов on 05.05.2023.
//

import UIKit

class InputScreenController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var groupSizeField: UITextField!
    @IBOutlet weak var infectionFactorField: UITextField!
    @IBOutlet weak var periodField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupSizeField.delegate = self
        infectionFactorField.delegate = self
        periodField.delegate = self
        
        self.hideKeyBoard()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    var groupSize: Int?
    var infectionFactor: Int?
    var updatingPeriod: Int?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "segueToInfectionController" {
               let destinationController = segue.destination as! InfectionController
               destinationController.groupSize = groupSize
               destinationController.infectionFactor = infectionFactor
               destinationController.updatingPeriod = updatingPeriod
           }
    }
    
    @IBAction func launchAction(_ sender: UIButton) {
        if let groupSizeText = groupSizeField.text, let groupSizeInt = Int(groupSizeText) {
            groupSize = groupSizeInt
        }
        else {
            groupSize = 50
        }
        if let infectionFactorText = infectionFactorField.text, let infectionFactorInt = Int(infectionFactorText) {
            infectionFactor = infectionFactorInt
        }
        else {
            infectionFactor = 3
        }
        if let updatingPeriodText = periodField.text, let updatingPeriodInt = Int(updatingPeriodText) {
            updatingPeriod = updatingPeriodInt
        }
        else {
            updatingPeriod = 1
        }
//        let destinationController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfectionController") as! InfectionController
//        destinationController.groupSize = groupSize
//        destinationController.infectionFactor = infectionFactor
//        destinationController.updatingPeriod = updatingPeriod
//
//        print("GroupSize = \(String(describing: groupSize))")
//        print("InfectionFactor = \(String(describing: infectionFactor))")
//        print("UpdatingPeriod = \(String(describing: updatingPeriod))")
//        self.navigationController?.pushViewController(InfectionController(), animated: true)

    }
    
    @objc func keyboardWillShowNotification(notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            _ = frame.cgRectValue.height
        }
    }
    
    @objc func keyboardWillHideNotification(notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            _ = frame.cgRectValue.height
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
                return true
            }

            // Ограничиваем количество символов до 10
            let newLength = text.count + string.count - range.length
            return newLength <= 7
    }
}
