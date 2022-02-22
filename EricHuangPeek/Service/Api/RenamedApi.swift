//
//Api
//EricHuangPeek
//
//Created by Huang, Eric on 2/18/22
//Copyright © 2022 Merrill Corporation. All rights reserved.


import Foundation

enum APIResult {
    case success(Decodable)
    case failure(Error)
}

enum APIError: Error {
    case badRequest
    case serverUnreachable
}

// Small boilerplate class to configure apis
class API {
    static var githubApi: API {
        return API.init(
            configuration: Configuration.init(
                baseURL: URL(string: "https://api.github.com/graphql")!,
                commonHeaders: [
                    "content-type": "application/json",
                    "Authorization": "Bearer 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"
                ]
            )
        )
    }
    
    struct Configuration {        
        let baseURL: URL
        let commonHeaders: [String: String]
        
        init(baseURL: URL, commonHeaders: [String: String]) {
            self.baseURL = baseURL
            self.commonHeaders = commonHeaders
        }
    }
    
    var configuration: Configuration
    
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    // A bit messy function here to couples the URL session and network architecture
    // Definately could build out some generic network architecture to handle all the requests for the app
    // Or use some graphQL client to make it easier
    //
    func makeRepoRequest(query: String, first: Int, afterCursor: String?, completionHandler:(@escaping (APIResult) -> Void)) {
        
        // The string interlop was kind of tricky to figure out
        // cursor is a String type that needs quotation
        // null gives us the initial request but does not need string qutotations
        let afterCursorString = afterCursor != nil ? "\"\(afterCursor!)\"" : "null"
        
        let parameters = ["query": "query { search(query: \"\(query)\" type:REPOSITORY, first:20, after: \(afterCursorString)) { pageInfo { endCursor } edges { node { ... on Repository { name stargazerCount url owner{ login avatarUrl }}} } }}"] as [String : Any]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])

        let request = NSMutableURLRequest(url: self.configuration.baseURL)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = self.configuration.commonHeaders
        request.httpBody = postData as Data

        
        // The URLSession is coupled here for simplicity sake
        // We can turn this portion into a generic function to handle a custom Request class
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            completionHandler(APIResult.failure(error!))
          } else {
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 400 ..< 499:
                    completionHandler(APIResult.failure(APIError.badRequest))
                case 500 ..< 599:
                    completionHandler(APIResult.failure(APIError.serverUnreachable))
                default:
                    break
                }
            }
            
            // The JSON parsing is a bit messy as well
            // We can take the JSON parsing logic out of this function and make it generic to handle all of the request
            // The GraphQL does make the parsing messy and forces the model to conform to the GraphQL schema
            // Anyways not the place to solve this problem, maybe a GraphQL client can solve this issue
            guard let jsonObject = try! JSONSerialization.jsonObject(
                with: data!,
                options: .allowFragments) as? [String: Any] else { return }
            
            
            guard let dataJson = jsonObject["data"] as? [String: Any] else { return }
            guard let searchPath = dataJson["search"] as? [String: Any]  else { return }
            
            let searchPathData = try! JSONSerialization.data(withJSONObject: searchPath, options: .fragmentsAllowed)
            
            
            let decoder = JSONDecoder.init()

            let result = try! decoder.decode(SearchResultItemConnection.self, from: searchPathData)
            completionHandler(APIResult.success(result))
          }
        })

        dataTask.resume()
    }
}


