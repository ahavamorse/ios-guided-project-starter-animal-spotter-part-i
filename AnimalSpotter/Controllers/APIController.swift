//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

final class APIController {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum NetworkError: Error {
        case noData
    }
    
    private let baseURL = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    
    private lazy var signUpURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var signInURL = baseURL.appendingPathComponent("/users/login")
    
    // create function for sign up
    func signUp(with user: User, completion: @escaping (Error?) -> ()) {
        // create a URLRequest from endpoint specific URL
        var request = URLRequest(url: signUpURL)
        
        // modify the request for POST, add proper headers
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // encode the user model to JSON, attach as request body
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            NSLog("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        // set up data task and handle response
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            // handle response
        }.resume()
    }
    
    // create function for sign in
    
    // create function for fetching all animal names
    
    // create function for fetching animal details
    
    // create function to fetch image
}
