//
//  ViewController.swift
//  NetworkRequest
//
//  Created by Timothy D Batty on 2/8/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private(set) var button: UIButton!
    
    private var dataTask: URLSessionDataTask?
    private(set) var results: [SearchResult] = [] {
        didSet { handleResults(results) }
    }
    var handleResults: ([SearchResult]) -> Void = { searchResults in print(">>>>> from handleResults -> \(searchResults[0])")}
    
    var session: URLSessionProtocol = URLSession.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction private func buttonTapped() {
        searchForBook(terms: "out from boneville")
    }
    
    private func searchForBook(terms: String) {
        guard let encodedTerms = terms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?" + "mediaType=book&term=\(encodedTerms)")
        else { return }
        let request = URLRequest(url: url)//                    The dataTask method takes 2 arguments, the request and a closure that takes 3 args
        
        dataTask = session.dataTask(with: request) {
            [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in //    [weak self] is a weak capture group to prevent memory leak.
            guard let self = self else { return } //                        Capture group turns self into an optional, this guard clause unwraps it
            
            var decoded : Search?
            var errorMessage : String?
            
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                errorMessage = "Response: \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))"
            } else if let data = data {
                do {
                    decoded = try JSONDecoder().decode(Search.self, from: data)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
            
            DispatchQueue.main.async {
                [weak self] in guard let self = self else { return } // weak capture group with guard to unwrap it, closure takes no args
                
                if let decoded = decoded { self.results = decoded.results }
                if let errorMessage = errorMessage {
                    self.showError(errorMessage)
                }
                
                self.dataTask = nil
                self.button.isEnabled = true
            }
        }
        button.isEnabled = false
        dataTask?.resume()
    }
    
    private func showError(_ message: String) {
        let title = "Network Problem"
        
        print("\(title): \(message)")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.preferredAction = okAction
        present(alert, animated: true)
    }
}

extension URLSession: URLSessionProtocol {}
protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

struct Search: Decodable {
    let results: [SearchResult]
}

struct SearchResult: Decodable, Equatable {
    let artistName: String
    let trackName: String
    let collectionPrice: Float
    let primaryGenreName: String
}
