//
//  DashboardTableViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 15/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit

class DashboardTableViewController: UITableViewController, UIAlertViewDelegate, ServerResponseProtocol, GPIODictionaryProtocol {
    
    @IBOutlet var dashboardTableView: UITableView!
    
    var settings = PiSettings()
    
    var socket = SocketIOManager(host: "", port: 0)
    var gpioState: [Int: Int]?
    
    var serverResponse = ""
    var theCode = ""
    var canceledConnection = false
    
    // Variable set to True when trying to connect and to False when either connected or failed to connect
    // This should prevent multiple simultaneous socket connections.
    var tryingToConnect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        settings.load()
        // establishConnection()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.socket = socket
        
        self.refreshControl?.addTarget(self, action: #selector(DashboardTableViewController.handleRefresh), for: UIControlEvents.valueChanged)
        if let bounds = refreshControl?.bounds {
            refreshControl?.bounds = CGRect(x: bounds.origin.x, y: -10, width: bounds.width, height: bounds.height)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Reconnecting socket connection when coming from settings view
        settings.load()
        dashboardTableView.reloadData()
        let hasShownTutorial = UserDefaults().bool(forKey: "hasShownTutorial")
        if hasShownTutorial {
            establishConnection()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Closing socket connection when going to settings view
        socket.closeConnection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Show tutorial
        let hasShownTutorial = UserDefaults().bool(forKey: "hasShownTutorial")
        if !hasShownTutorial {
            performSegue(withIdentifier: "ShowTutorialSegue", sender: self)
        }
        UserDefaults().set(true, forKey: "hasShownTutorial")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //func sectionHeaderHight(forSection section:Int) -> CGFloat {

        let offHeight = CGFloat(0.1)
        let onHeight = CGFloat(18)
        let firstHeight = CGFloat(40)
        var theHeight = offHeight
        switch section {
        case 0:
            if let server = settings.selectedServer {
                if !server.userCommands.isOn {
                    theHeight = offHeight
                } else {
                    theHeight = onHeight+firstHeight
                }
            } else {
                theHeight = offHeight
            }
        case 1:
            if let server = settings.selectedServer {
                if !server.anyCommand {
                    theHeight = offHeight
                } else if !server.userCommands.isOn {
                    theHeight = firstHeight
                } else {
                    theHeight = offHeight
                }
            } else {
                theHeight = offHeight
            }
        case 2:
            if let server = settings.selectedServer {
                if !server.gpio.isOn {
                    theHeight = offHeight
                } else if !server.userCommands.isOn && !server.anyCommand {
                    theHeight = firstHeight + onHeight
                } else {
                    theHeight = onHeight
                }
            } else {
                theHeight = offHeight
            }
        case 3:
            if let server = settings.selectedServer {
                if !server.responseOn {
                    theHeight = offHeight
                } else if !server.userCommands.isOn && !server.anyCommand && !server.gpio.isOn {
                    theHeight = firstHeight + onHeight
                } else {
                    theHeight = onHeight
                }
            } else {
                theHeight = offHeight
            }
        default:
            theHeight = offHeight
        }
        return theHeight
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let offHeight = CGFloat(0.1)
        let onHeight = CGFloat(18)
        var theHeight = offHeight
        switch section {
        case 0:
            if let server = settings.selectedServer {
                if !server.userCommands.isOn {
                    theHeight = offHeight
                } else {
                    if server.anyCommand {
                        theHeight = offHeight
                    } else {
                        theHeight = onHeight
                    }
                }
            } else {
                theHeight = offHeight
            }
        case 1:
            if let server = settings.selectedServer {
                if !server.anyCommand {
                    theHeight = offHeight
                } else {
                    theHeight = onHeight
                }
            } else {
                theHeight = offHeight
            }
        case 2:
            if let server = settings.selectedServer {
                if !server.gpio.isOn {
                    theHeight = offHeight
                } else {
                    theHeight = onHeight
                }
            } else {
                theHeight = offHeight
            }
        case 3:
            if let server = settings.selectedServer {
                if !server.responseOn {
                    theHeight = offHeight
                } else {
                    theHeight = onHeight
                }
            } else {
                theHeight = offHeight
            }
        default:
            theHeight = offHeight
        }
        return theHeight
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //func sectionTitle(forSection section:Int) -> String {
        switch section {
        case 0:
            if let server = settings.selectedServer {
                if !server.userCommands.isOn {
                    return ""
                }
                tableView.headerView(forSection: 0)?.textLabel?.textAlignment = .center
                return "Pre-defined commands"
            }
            return ""
        case 1:
            if let server = settings.selectedServer {
                if !server.anyCommand {
                    return ""
                }
                return ""
            }
            return ""
        case 2:
            if let server = settings.selectedServer {
                if !server.gpio.isOn {
                    return ""
                }
                return "GPIO Pins"
            }
            return ""
        case 3:
            if let server = settings.selectedServer {
                if !server.responseOn {
                    return ""
                }
                return "Status"
            }
            return ""
        default:
            return ""
        }
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        print(section)
//        let height = sectionHeaderHight(forSection: section)
//        let title: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: height))
//        title.text = sectionTitle(forSection: section)
//        title.textAlignment = .center
//        print(title.text, title.frame.height, height)
//        return title
//    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView, let label = headerView.textLabel {
            label.textAlignment = .center
            label.textColor = UIColor.init(red: 42.0/255.0, green: 78.0/255.0, blue: 108.0/255.0, alpha: 1)
            label.font = UIFont(name: label.font.fontName, size: 14)
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let server = settings.selectedServer {
                if !server.userCommands.isOn {
                    return 0
                }
                return Int(ceil(Double(server.userCommands.commands.count)/3))
            }
            return 0
        case 1:
            if let server = settings.selectedServer {
                if !server.anyCommand {
                    return 0
                }
                return 1
            }
            return 0
        case 2:
            if let server = settings.selectedServer {
                if !server.gpio.isOn {
                    return 0
                }
                return server.gpio.pins.count
            }
            return 0
        case 3:
            if let server = settings.selectedServer {
                if !server.responseOn {
                    return 0
                }
                return 1
            }
            return 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 20.0
        } else {
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCommandTableViewCell", for: indexPath) as? DashboardCommandTableViewCell  else {
                fatalError("The dequeued cell is not an instance of DashboardCommandTableViewCell.")
            }
            if let server = settings.selectedServer {
                let commands = server.userCommands.commands
                let nbuttons = commands.count
                let row = indexPath.row
                var subarray = [PiCommand]()
                for j in row*3...min(row*3+2, nbuttons-1){
                    subarray.append(commands[j])
                }
                cell.socket = socket
                cell.parentView = self
                cell.setButtons(commands: subarray)
                cell.layer.backgroundColor = UIColor.clear.cgColor
                cell.separatorInset = UIEdgeInsetsMake(0, cell.frame.width/2, 0, cell.frame.width/2);
            
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardAnyCommandTableViewCell", for: indexPath) as? DashboardAnyCommandTableViewCell  else {
                fatalError("The dequeued cell is not an instance of DashboardAnyCommandTableViewCell.")
            }
            cell.socket = socket
            cell.layer.backgroundColor = UIColor.clear.cgColor
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardGPIOTableViewCell", for: indexPath) as? DashboardGPIOTableViewCell  else {
                fatalError("The dequeued cell is not an instance of DashboardGPIOTableViewCell.")
            }
            if let server = settings.selectedServer {
                let pins = server.gpio.pins
                let row = indexPath.row
                let pin = pins[row]
                cell.socket = socket
                cell.GPIOLabel.text = pin.name
                if pin.type == .input {
                    cell.GPIOSwitch.isEnabled = false
                } else {
                    cell.GPIOSwitch.isEnabled = true
                }
                cell.pinNumber = pin.number
                if let state = gpioState {
                    if let gpioSwitch = state[Int(pin.number)] {
                        cell.GPIOSwitch.isOn = Bool(gpioSwitch as NSNumber)
                    } else {
                        cell.GPIOSwitch.isOn = false
                    }
                } else {
                    cell.GPIOSwitch.isOn = false
                }
                cell.delegate = self
                cell.layer.backgroundColor = UIColor.clear.cgColor
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardServerResponseTableViewCell", for: indexPath)
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.textLabel?.text = serverResponse
            cell.textLabel?.backgroundColor = UIColor.clear
            return cell
        default:
            fatalError("Wrong section: \(indexPath.section)")
        }
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Socket connection
    
    func establishConnection(){
        if tryingToConnect {
            return
        }
        tryingToConnect = true
        if let server = settings.selectedServer {
            let host = server.hostName
            let port = server.port
            useServerResponse(response: "Not connected")
            socket = SocketIOManager(host: host, port: port)
            socket.delegate = self
            socket.establishConnection()
        }
    }
    
    func alertConnectionCode() {
        // Ask for connection code
        canceledConnection = false
        
        let alertController = UIAlertController(title: "Connection code", message: "What is the code to connect to this server?", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Connection Code"
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.socket.checkConnection(code: "")
            self.canceledConnection = true
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            let textField = alertController.textFields![0] as UITextField
            self.theCode = textField.text ?? ""
            self.socket.checkConnection(code: self.theCode)
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
        }
    }
    
    func checkConnectionCode() {
        if !canceledConnection {
            if let loadedCodes = UserDefaults().dictionary(forKey: "ConnectionCodes") {
                if let server = settings.selectedServer {
                    if let code = loadedCodes[server.hostName] as? String {
                        theCode = code
//                        print("Checking connection code: ", server.hostName, theCode)
                        socket.checkConnection(code: code)
                        return
                    }
                }
            }
            alertConnectionCode()
        }
    }
    
    func removeConnectionCode() {
        if !canceledConnection {
            if var loadedCodes = UserDefaults().dictionary(forKey: "ConnectionCodes") {
                if let server = settings.selectedServer {
                    if (loadedCodes[server.hostName] as? String) != nil {
                        loadedCodes.removeValue(forKey: server.hostName)
//                        print("Removing connection code: ", server.hostName)
                        UserDefaults().set(loadedCodes, forKey: "ConnectionCodes")
                    }
                }
            }
        }
    }

    func addConnectionCode() {
        if !canceledConnection {
            if let server = settings.selectedServer {
                if var loadedCodes = UserDefaults().dictionary(forKey: "ConnectionCodes") {
                    if (loadedCodes[server.hostName] as? String) == nil {
                        loadedCodes[server.hostName] = theCode
//                        print("Adding connection code: ", server.hostName, theCode)
                        UserDefaults().set(loadedCodes, forKey: "ConnectionCodes")
                    }
                } else {
                    let loadedCodes = [server.hostName: theCode]
//                    print("Adding connection code: ", server.hostName, theCode)
                    UserDefaults().set(loadedCodes, forKey: "ConnectionCodes")
                }

            }
        }
    }
    
    func useServerResponse(response: Any) {
        serverResponse = "\(response)"
        if let resp = response as? [Any] {
            if resp.count == 1 {
                serverResponse = "\(resp[0])"
            }
        }
        if let server = settings.selectedServer {
            if server.responseOn {
                dashboardTableView.reloadData()
            }
        }
    }
    
    func hasConnected() {
        
        tryingToConnect = false

        // Update status label to "Connected"
        useServerResponse(response: "Connected")

        // Add connection code to UserDefaults
        addConnectionCode()
        
        if let server = settings.selectedServer {
            if server.gpio.isOn {
                // Start probing GPIO input pins
                socket.startProbingInputPins()

                // Get state of GPIO pins
                socket.getAllGPIO()
            }
        }
        
        // Stops refreshing
        refreshControl?.endRefreshing()
    }
    
    func failedToConnect() {
        
        tryingToConnect = false
        
        // Update status label to "Not connected"
        useServerResponse(response: "Not connected")
        
        // Stops refreshing
        refreshControl?.endRefreshing()
    }
    
    func hasDisconnected() {

        // Update status label to "Disconnected"
        useServerResponse(response: "Disconnected")

    }
    
    func failedToConfigureGPIO(){

        // Update status label
        useServerResponse(response: "Not configured: Go to the Settings tab")
        
        // Re-initialize gpioState dictionary
        gpioState = [Int: Int]()
        
        // Refresh tablew view
        dashboardTableView.reloadData()
    }

    func updateGPIOSwitch(data: Any) {
        if let resp = data as? [Any] {
            if let dic = resp[0] as? [String: Int] {
                for (pin, value) in dic {
                    if let pinNumber = Int(pin) {
                        let pinValue = Int(value)
                        gpioState?[pinNumber] = pinValue
                    }
                }
                dashboardTableView.reloadData()
            }
        }
    }
    
    func updateGPIOSwitches(data: Any) {
        if let resp = data as? [Any] {
            if let dic = resp[0] as? [String: String] {
                var state = [Int: Int]()
                for (pin, value) in dic {
                    if let pinNumber = Int(pin), let pinValue = Int(value) {
                        state[pinNumber] = pinValue
                    }
                }
                gpioState = state
                dashboardTableView.reloadData()
            }
        }
    }
    
    func updateGPIODictionary(pinNumber: Int, value: Int) {
        gpioState?[pinNumber] = value
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        if !socket.isConnected {
            socket.establishConnection()
        } else {
            refreshControl.endRefreshing()
        }
    }
}
