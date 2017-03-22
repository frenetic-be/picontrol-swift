//
//  TutorialViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 16/03/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

protocol pageViewControllerProtocol {
    func showPage(number: Int)
    func showNextPage()
}

enum DestinationType {
    case dashboard
    case settings
}

class TutorialViewController: UIViewController, UITextFieldDelegate {

    
    // Delegate in order to move to another page
    var delegate: pageViewControllerProtocol?
    
    // Segue Destination
    var segueDestination: DestinationType = .dashboard
    
    @IBOutlet weak var serverNameTextField: UITextField!
    @IBOutlet weak var hostAddressTextField: UITextField!
    @IBOutlet weak var portNumberTextField: UITextField!
    @IBOutlet weak var addServerButton: UIButton!
    @IBOutlet weak var buttonNameTextField: UITextField!
    @IBOutlet weak var commandTextField: UITextField!
    @IBOutlet weak var addButtonButton: UIButton!
    @IBOutlet weak var downloadLinkLabel: ActiveLabel!
    @IBOutlet weak var settingsLinkLabel: ActiveLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch restorationIdentifier ?? "" {
        case "TutorialPage2":
            let customType = ActiveType.custom(pattern: "\\sthis Python program\\b") //Looks for "are"
            
            downloadLinkLabel.enabledTypes.append(customType)
            downloadLinkLabel.customize { label in
                label.customColor[customType] = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
                label.customSelectedColor[customType] = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)
                
                label.handleCustomTap(for: customType) { _ in self.seeServerLink() }
            }
            
        case "TutorialPage3":
            
            // Text field delegates
            serverNameTextField.delegate = self
            hostAddressTextField.delegate = self
            portNumberTextField.delegate = self
            
            // Move view up and down
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
            // Tap anywhere to dismiss the keyboard
            self.hideKeyboardWhenTappedAround()
        case "TutorialPage5":
            
            // Text field delegates
            buttonNameTextField.delegate = self
            commandTextField.delegate = self
            
            // Move view up and down
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
            // Tap anywhere to dismiss the keyboard
            self.hideKeyboardWhenTappedAround()
        case "TutorialPage6":
            let customType = ActiveType.custom(pattern: "\\sSettings\\b") //Looks for "are"
            
            settingsLinkLabel.enabledTypes.append(customType)
            settingsLinkLabel.customize { label in
                label.customColor[customType] = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
                label.customSelectedColor[customType] = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)
                
                label.handleCustomTap(for: customType) { _ in self.goToSettings() }
            }
        default:
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier ?? "" == "GetStarted" {
            guard let destination = segue.destination as? UITabBarController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            if segueDestination == .settings {
                destination.selectedIndex = 1
            } else {
                destination.selectedIndex = 0
            }
        }
        UserDefaults().set(true, forKey: "hasShownTutorial")
    }

    
    // MARK: Button actions
    
    @IBAction func showNextPage(_ sender: UIButton) {
        delegate?.showNextPage()
    }
    
    func seeServerLink() {
        if let url = URL(string: "https://github.com/frenetic-be/picontrol_server") {
            UIApplication.shared.open(url, options: [:]) { boolean in }
        }
    }
    
    func goToSettings() {
        segueDestination = .settings
        performSegue(withIdentifier: "GetStarted", sender: nil)
    }
    
    @IBAction func addServer(_ sender: UIButton) {
        view.endEditing(true)
        let serverName = serverNameTextField.text ?? ""
        let hostAddress = hostAddressTextField.text ?? ""
        let portNumber = portNumberTextField.text ?? ""
        
        if portNumber.characters.count != 4 {
            showAlert(message: "The port number must be a 4-digit integer.")
            return
        }
        
        if serverName.isEmpty || hostAddress.isEmpty || portNumber.isEmpty {
            showAlert(message: "Server name, host address and port number cannot be empty.")
            return
        }
        
        guard let port = UInt(portNumber) else {
            showAlert(message: "The port number must be a 4-digit integer.")
            return
        }
        
        // Load settings
        let settings = PiSettings()
        settings.load()
        
        // Check if new server already exists
        for server in settings.servers {
            if hostAddress == server.hostName && port == server.port {
                showAlert(message: "Server not added because it already exists in your settings.")
                // Change page
                delegate?.showPage(number: 3)
                return
            }
        }
        
        // Add server to settings
        let newServer = PiServer(name: serverName, hostName: hostAddress, port: port)
        newServer.responseOn = true
        settings.servers.append(newServer)
        settings.selectedServer = newServer
        
        // Save settings
        settings.save()
        
        // Change page
        delegate?.showPage(number: 3)
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        view.endEditing(true)
        let buttonName = buttonNameTextField.text ?? ""
        let command = commandTextField.text ?? ""
        
        // Check that the command is valid 
        if command.range(of: " ") != nil {
            showAlert(message: "That command is not valid.")
            return
        }
        
        // Check that the command is valid
        if command.isEmpty {
            showAlert(message: "The command cannot be empty.")
            return
        }
        
        // Load settings
        let settings = PiSettings()
        settings.load()
        
        // Check if server exists
        if settings.servers.count == 0 {
            showAlert(message: "Looks like you did not configure a server. You might want to do that first.")
            return
        }

        // Check if server exists
        guard let server = settings.selectedServer else {
            showAlert(message: "Looks like no server is selected. Cannot add any button.")
            return
        }
        
        // Check if command exists
        for cmd in server.userCommands.commands {
            if cmd.command == command {
                showAlert(message: "Button was not added because that command already has a button.")
                return
            }
        }
        
        server.userCommands.isOn = true
        let newCommand = PiCommand(buttonName: buttonName)
        newCommand.command = command
        server.userCommands.commands.append(newCommand)
        
        
        // Save settings
        settings.save()
        
        showAlert(message: "You successfully added the button \"\(buttonName)\". Feel free to add more. Tap \"Next\" when you are done.", title: "Well done!")
        
        buttonNameTextField.text = ""
        commandTextField.text = ""
        
    }
    
    
    func showAlert(message: String, title:String="Error") {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        

        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
        }
    }

    // MARK: TextField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let id = textField.restorationIdentifier {
            switch id {
            case "serverName":
                hostAddressTextField.becomeFirstResponder()
            case "hostAddress":
                portNumberTextField.becomeFirstResponder()
            case "portNumber":
                addServer(addServerButton)
            case "buttonName":
                commandTextField.becomeFirstResponder()
            case "command":
                addButton(addButtonButton)
            default: break
            }
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let id = textField.restorationIdentifier ?? ""
        switch id {
        case "portNumber":
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            if !allowedCharacters.isSuperset(of: characterSet) {
                showAlert(message: "The port number must be a 4-digit integer.")
                return false
            }
            return true
        default:
            return true
        }

    }

    // Move view up
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height-50
            }
        }
        
    }
    
    // Move view down
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height-50
            }
        }
    }
    
}
