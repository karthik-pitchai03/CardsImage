//
//  NetworkMangaer.swift
//  PhantomSol
//
//  Created by Apple on 19/10/22.
//

import Foundation


class NetworkManager {
    static let shared: NetworkManager = NetworkManager()
    public func get (urlString: String, completionBlock: @escaping ((Data?) -> Void)) {
        let url = URL(string: urlString)
        if let usableUrl = url {
            let request = URLRequest(url: usableUrl)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                completionBlock(data)
            })
            task.resume()
        }
    }
}
