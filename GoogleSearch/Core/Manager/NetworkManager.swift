//
//  NetworkManager.swift
//  GoogleSearch
//
//  Created by Александр Басов on 12/16/21.
//

import Foundation

class NetworkManager {
    
    init() { }
    
    static let shared = NetworkManager()
    
    var task = URLSessionTask()
    
    let session = URLSession(configuration: .default)
    let urlSession = URLSession.shared
    
    
    //MARK: - GetGoogleSearch
    func getGoogleSearch(text: String?, onSuccess: @escaping ([Item]) -> Void, onError: @escaping (String) -> Void, progress: @escaping ((Progress) -> Void)) {
        guard let text = text else { return }
 
        let Url = "https://www.googleapis.com/customsearch/v1?key=\(APIKey.key)&cx=1288c60a43e93ec10&q=\(text)"
        
        guard let url = URL(string: Url) else {
            onError("Error building URL")
            return
        }

        self.task = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    onError(error.localizedDescription)
                    return
                }

                guard let data = data, let response = response as? HTTPURLResponse else {
                    onError("Invalid data or response")
                    return
                }

                do {
                    if response.statusCode == 200 {
                        let result = try JSONDecoder().decode(Result.self, from: data)
                        print("Items: \(result.items.count)")
                        onSuccess(result.items)
                    } else {
                        onError("Response wasn't 200. It was: " + "\(response.statusCode)")
                    }
                } catch {
                    onError(error.localizedDescription)
                }
            }
        }
        progress(task.progress)
        task.resume()
    }
    
    func stopRequest() {
        task.cancel()
    }
    
}
