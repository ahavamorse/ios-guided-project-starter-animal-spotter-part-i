//
//  AnimalsTableViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalsTableViewController: UITableViewController {
    
    enum NetworkError: Error {
        case noAuth
        case badAuth
        case otherError
        case badData
        case noDecode
    }
    
    // MARK: - Properties
    
    let reuseIdentifier = "AnimalCell"
    private var animalNames: [String] = []
    
    let apiController = APIController()

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // transition to login view if conditions require
        if apiController.bearer == nil {
            performSegue(withIdentifier: "LoginViewModalSegue", sender: self)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animalNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = animalNames[indexPath.row]

        return cell
    }

    // MARK: - Actions
    
    @IBAction func getAnimals(_ sender: UIBarButtonItem) {
        // fetch all animals from API
        apiController.fetchAllAnimalNames { (result) in
//            // This treats the throwable method result like an optional
//            // Success provides an array of Strings, and failure provides a nil value
//            // (error itself is thrown away)
//            if let names = try? result.get() {
//                DispatchQueue.main.async {
//                    self.animalNames = names
//                    self.tableView.reloadData()
//                }
//            }
            // This approach lets you handle success
            // and also enumerate the falilures to present
            // appropriate and actionable messages to the user
            do {
                let names = try result.get()
                DispatchQueue.main.async {
                    self.animalNames = names
                    self.tableView.reloadData()
                }
            } catch {
                if let error = error as? NetworkError {
                    switch error {
                    case .noAuth:
                        NSLog("No bearer token, please log in")
                    case .badAuth:
                        NSLog("Bearer token invalid")
                    case .otherError:
                        NSLog("Generic network error occurred")
                    case .badData:
                        NSLog("Data received was invalid, corrupt, or doesn't exist")
                    case .noDecode:
                        NSLog("JSON data could not be decoded")
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginViewModalSegue" {
            // inject dependencies
            if let loginVC = segue.destination as? LoginViewController {
                loginVC.apiController = apiController
            }
        }
    }
}
