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
        case badUrl
        case noAuth
        case badAuth
        case otherError
        case badData
        case noDecode
        case badImage
    }
    
    private let baseURL = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    var bearer: Bearer?
    
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
            // handle errors (like no internet connectivity, or anything that generates an Error object)
            if let error = error {
                completion(error)
                return
            }
            
            // handle client errors and server errors that generate non 200 status codes
            if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            // if we get this far, the response contained no errors, so sign up was successful
            completion(nil)
        }.resume()
    }
    
    // create function for sign in
    func signIn(with user: User, completion: @escaping (Error?) -> ()) {
        // create a URLRequest from endpoint specific URL
        var request = URLRequest(url: signInURL)
        
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
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // handle errors (like no internet connectivity, or anything that generates an Error object)
            if let error = error {
                completion(error)
                return
            }
            
            // handle client errors and server errors that generate non 200 status codes
            if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
            } catch {
                NSLog("Error decoding bearer object: \(error)")
                completion(error)
                return
            }
            
            // if we get this far, the response contained no errors, so log in was successful
            completion(nil)
        }.resume()
    }
    
    // create function for fetching all animal names
    func fetchAllAnimalNames(completion: @escaping (Result<[String], NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noAuth))
            return
        }
        
        let allAnimalsUrl = baseURL.appendingPathComponent("animals/all")
        
        var request = URLRequest(url: allAnimalsUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        // This provides authorization credentials to the server
        // Data here is case sensitive and you must folloow the rules exactly.
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // handle errors (like no internet connectivity,
            // or anything that generates an Error object)
            if let error = error {
                NSLog("Error receiving animal name data: \(error)")
                completion(.failure(.otherError))
                return
            }
            
            // Specifically, the bearer token is invalid or expired
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let animalNames = try decoder.decode([String].self, from: data)
                completion(.success(animalNames))
            } catch {
                NSLog("Error decoding animal objects: \(error)")
                completion(.failure(.noDecode))
                return
            }
            
        }.resume()
    }
    
    // create function for fetching animal details
    func fetchDetails(for animalName: String, completion: @escaping (Result<Animal, NetworkError>) -> Void) {
        // If failure, the bearer token doesn't exist
        guard let bearer = bearer else {
            completion(.failure(.noAuth))
            return
        }
        
        let animalUrl = baseURL.appendingPathComponent("animals/\(animalName)")
        
        var request = URLRequest(url: animalUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        // This provides authorization credentials to the server
        // Data here is case sensitive and you must folloow the rules exactly.
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // handle errors (like no internet connectivity,
            // or anything that generates an Error object)
            if let error = error {
                NSLog("Error receiving animal detail data: \(error)")
                completion(.failure(.otherError))
                return
            }
            
            // Specifically, the bearer token is invalid or expired
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
//            decoder.dataDecodingStrategy = .secondsSince1970
            do {
                let animal = try decoder.decode(Animal.self, from: data)
                completion(.success(animal))
            } catch {
                NSLog("Error decoding animal object: \(error)")
                completion(.failure(.noDecode))
                return
            }
            
        }.resume()
    }
    
    // create function to fetch image
    func fetchImage(at urlString: String, completion: @escaping (Result<UIImage, NetworkError>) -> ()) {
        guard let imageUrl = URL(string: urlString) else {
            completion(.failure(.badUrl))
            return
        }
        
        var request = URLRequest(url: imageUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: imageUrl) { (data, _, error) in
            // chck for errors
            if let error = error {
                completion(.failure(.otherError))
                return
            }
            
            // ensuring data was received
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            // turning binary image data into a UIImage object
            guard let image = UIImage(data: data) else {
                completion(.failure(.badImage))
                return
            }
            
            // passing the successful image
            completion(.success(image))
        }.resume()
    }
}
