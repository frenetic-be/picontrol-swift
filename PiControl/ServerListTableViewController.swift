//
//  ServerListTableViewController.swift
//  PiControl
//
//  Created by Julien Spronck on 13/02/2017.
//  Copyright © 2017 Julien Spronck. All rights reserved.
//

import UIKit
import os.log

class ServerListTableViewController: UITableViewController {

    // MARK: Properties
    var settings = PiSettings()
    var selectedRow: IndexPath? = nil

    @IBOutlet weak var addPiButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // settings.deleteAll()
        settings.load()
        tableView.dataSource = self
        navigationItem.leftBarButtonItem = editButtonItem
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return settings.servers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ServerListTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Fetches the appropriate meal for the data source layout.
        let server = settings.servers[indexPath.row]
        if let label = cell.textLabel {
            let selectedServer = settings.selectedServer ?? settings.servers[0]
            // Add a checkmark next to selected server
            if server == selectedServer {
                label.text = "\u{2713}  \(server.name)"
            } else {
                label.text = "\u{2001}  \(server.name)"
            }
        }

        return cell
    }

    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // if the selected server is deleted, select another server
            if settings.selectedServer == settings.servers[indexPath.row] && settings.servers.count > 1 {
                settings.selectedServer = settings.servers[0]
            }
            
            // Delete the row from the data source
            settings.servers.remove(at: indexPath.row)
            // tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            settings.save()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = settings.servers[fromIndexPath.row]
        settings.servers.remove(at: fromIndexPath.row)
        settings.servers.insert(itemToMove, at: to.row)
        settings.save()
    }
 

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settings.selectedServer = settings.servers[indexPath.row]
        tableView.reloadData()
        settings.save()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
            case "AddServer":
                os_log("Adding a server", log:OSLog.default, type: .debug)
                selectedRow = nil
            case "ShowServer":
                guard let serverDetailViewController = segue.destination as? ServerConfigTableViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                guard let selectedCell = sender as? UITableViewCell else {
                    fatalError("Unexpected sender: \(sender)")
                }
                guard let indexPath = tableView.indexPath(for: selectedCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                selectedRow = indexPath
                serverDetailViewController.currentServer = settings.servers[indexPath.row]
            
            default:
                fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
        tabBarController?.tabBar.isHidden = true
    }
 

    // MARK: Actions
    
    @IBAction func unwindToServerList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ServerConfigTableViewController {
            let currentServer = sourceViewController.currentServer
            if let selectedIndexPath = selectedRow {
                // Updating an existing server
                settings.servers[selectedIndexPath.row] = currentServer
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Adding a new server to the list
                let newIndexPath = IndexPath(row: settings.servers.count, section: 0)
                settings.servers.append(currentServer)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            settings.save()
        }
    }

}
