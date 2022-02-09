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
    
    var session = URLSession.shared
    
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
            
            let decoded = String(data: data ?? Data(), encoding: .utf8)
            print("response: \(String(describing: response))")
            print("data: \(String(describing: decoded))")
            print("error: \(String(describing: error))")
            
            DispatchQueue.main.async {
                [weak self] in guard let self = self else { return } // weak capture group with guard to unwrap it, closure takes no args
                self.dataTask = nil
                self.button.isEnabled = true
            }
        }
        button.isEnabled = false
        dataTask?.resume()
    }
}

