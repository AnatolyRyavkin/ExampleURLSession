//
//  LoaderImages.swift
//  ExampleURLSession
//
//  Created by Anatoly Ryavkin on 20.10.2020.
//

import Foundation
import UIKit



public enum ErrorForRequest: Error, CaseIterable{

    case ERR_OK
    case ERR_UNKNOWN
    case DONT_INTERNET

    var discript: (num: Int, nameError: String){
        switch self {
        case .ERR_OK :  return (200, "ERR_OK")
        case .ERR_UNKNOWN : return (003, "ERR_UNKNOWN")
        case .DONT_INTERNET : return (700, "DONT_INTERNET")
        }
    }

    static func makeSelfAtCode(code: Int) -> ErrorForRequest {
        for meaning in ErrorForRequest.allCases{
            if meaning.discript.num == code{
                return meaning
            }
        }
        return .ERR_UNKNOWN
    }

}

extension Error {
    func myError() -> ErrorForRequest {
        guard let er = self as? ErrorForRequest else {
            return ErrorForRequest.ERR_UNKNOWN
        }
        return er
    }
}

typealias Res = Result<(Data,HTTPURLResponse),Error>

public enum Result<Success, Failure> where Failure : Error {
    case success(Success)
    case failure(Failure)
}

extension URLSession {

    public func dataTaskMy(with url: URL, completionHandlerMy: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> URLSessionDataTask {

        return dataTask(with: url, completionHandler: { (data, urlResponse, error) in
            if let error = error {
                completionHandlerMy(.failure(error))
            } else if let data = data, let urlResponse = urlResponse as? HTTPURLResponse {
                completionHandlerMy(.success((data, urlResponse)))
            }
        })
    }
}

class LoaderImages {

    static let Shared = LoaderImages()

    func getImageFromURL(imageURL: String, endRunQueue: DispatchQueue?, completion:  @escaping (UIImage)->()) {
        let session = URLSession.init(configuration: URLSessionConfiguration.ephemeral);
        let url = URL.init(string: imageURL)!
        session.dataTaskMy(with: url) { (result: Res) in
            switch result {
            case .success((let data, let response)):
                if response.statusCode == 200 {
                    print(Thread.current)
                    if let image = UIImage.init(data: data) {
                        if let queue = endRunQueue {
                            queue.async {
                                completion(image);
                            }
                        }else{
                            completion(image);
                        }
                    }
                }
            case .failure(let error):
                let num = (error as NSError).code;
                let myErr = ErrorForRequest.makeSelfAtCode(code: num)
                print(myErr.discript.nameError)
            }
        }.resume()
    }
}

