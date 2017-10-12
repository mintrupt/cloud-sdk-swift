//
//  DeliveryClient.swift
//  KenticoCloud
//
//  Created by Martin Makarsky on 15/08/2017.
//  Copyright © 2017 Martin Makarsky. All rights reserved.
//

import AlamofireObjectMapper
import Alamofire
import ObjectMapper

/// DeliveryClient is the main class repsonsible for getting items from Delivery API.
public class DeliveryClient {
    
    private var projectId: String
    private var apiKey: String?
    private var headers: HTTPHeaders?
    private var isDebugLoggingEnabled: Bool
    
    /**
     Inits delivery client instance.
     Requests Preview API if apiKey is specified, otherwise requests Live API.
     
     - Parameter projectId: Identifier of the project.
     - Parameter apiKey: Preview API key for the project
     - Parameter enableDebugLogging: Flag for logging debug messages.
     - Returns: Instance of the DeliveryClient.
     */
    public init(projectId: String, apiKey: String? = nil, enableDebugLogging: Bool = false) {
        self.projectId = projectId
        self.apiKey = apiKey
        self.isDebugLoggingEnabled = enableDebugLogging
        self.headers = getHeaders()
    }
    
    /**
     Gets multiple items from Delivery service.
     Suitable for strongly typed query.
     
     - Parameter modelType: Type of the requested items. Type must conform to Mappable protocol.
     - Parameter queryParameters: Array of the QueryParameters which specifies requested items.
     - Parameter completionHandler: A handler which is called after completetion.
     - Parameter isSuccess: Result of the action.
     - Parameter items: Received items.
     - Parameter error: Potential error.
     */
    public func getItems<T>(modelType: T.Type, queryParameters: [QueryParameter?], completionHandler: @escaping (_ isSuccess: Bool, _ items: ItemsResponse<T>?,_ error: Error?) -> ()) where T: Mappable {
        
        let requestUrl = getItemsRequestUrl(queryParameters: queryParameters)
        sendGetItemsRequest(url: requestUrl, completionHandler: completionHandler)
    }
    
    /**
     Gets multiple items from Delivery service.
     Suitable for custom string query.
     
     - Parameter modelType: Type of the requested items. Type must conform to Mappable protocol.
     - Parameter customQuery: String query which specifies requested items.
     - Parameter completionHandler: A handler which is called after completetion.
     - Parameter isSuccess: Result of the action.
     - Parameter items: Received items.
     - Parameter error: Potential error.
     */
    public func getItems<T>(modelType: T.Type, customQuery: String, completionHandler: @escaping (_ isSuccess: Bool, _ items: ItemsResponse<T>?, _ error: Error?) -> ()) where T: Mappable {
        
        let requestUrl = getItemsRequestUrl(customQuery: customQuery)
        sendGetItemsRequest(url: requestUrl, completionHandler: completionHandler)
    }
    
    /**
     Gets single item from Delivery service.
     
     - Parameter modelType: Type of the requested items. Type must conform to Mappable protocol.
     - Parameter language: Language of the requested variant.
     - Parameter completionHandler: A handler which is called after completetion.
     - Parameter isSuccess: Result of the action.
     - Parameter item: Received item.
     - Parameter error: Potential error.
     */
    public func getItem<T>(modelType: T.Type, itemName: String, language: String? = nil, completionHandler: @escaping (_ isSuccess: Bool, _ item: ItemResponse<T>?, _ error: Error?) -> ()) where T: Mappable {
        
        let requestUrl = getItemRequestUrl(itemName: itemName, language: language)
        sendGetItemRequest(url: requestUrl, completionHandler: completionHandler)
    }
    
    /**
     Gets single item from Delivery service.
     Suitable for custom string query.
     
     - Parameter modelType: Type of the requested items. Type must conform to Mappable protocol.
     - Parameter customQuery: String query which specifies requested item.
     - Parameter completionHandler: A handler which is called after completetion.
     - Parameter isSuccess: Result of the action.
     - Parameter item: Received item.
     - Parameter error: Potential error.
     */
    public func getItem<T>(modelType: T.Type, customQuery: String, completionHandler: @escaping (_ isSuccess: Bool, _ item: ItemResponse<T>?,_ error: Error?) -> ()) where T: Mappable {
        
        let requestUrl = getItemRequestUrl(customQuery: customQuery)
        sendGetItemRequest(url: requestUrl, completionHandler: completionHandler)
    }
    
    /**
     Gets taxonomies from Delivery service.

     - Parameter customQuery: String query which specifies requested taxonomies. If ommited, all taxonomies for the given project are returned. Custom query example: "taxonomies?skip=1&limit=1"
     - Parameter completionHandler: A handler which is called after completetion.
     - Parameter isSuccess: Result of the action.
     - Parameter taxonomyGroups: Received taxonomy groups.
     - Parameter error: Potential error.
     */
    public func getTaxonomies(customQuery: String? = nil, completionHandler: @escaping (_ isSuccess: Bool, _ taxonomyGroups: [TaxonomyGroup]?, _ error: Error?) -> ()) {
        
        let requestUrl = getTaxonomiesRequestUrl(customQuery: customQuery)
        sendGetTaxonomiesRequest(url: requestUrl, completionHandler: completionHandler)
    }
    
    /**
     Gets TaxonomyGroup from Delivery service.
     
     - Parameter taxonomyGroupName: Name which specifies requested TaxonomyGroup
     - Parameter completionHandler: A handler which is called after completetion.
     - Parameter isSuccess: Result of the action.
     - Parameter taxonomyGroup: Received taxonomy group.
     - Parameter error: Potential error.
     */
    public func getTaxonomyGroup(taxonomyGroupName: String, completionHandler: @escaping (_ isSuccess: Bool, _ taxonomyGroup: TaxonomyGroup?, _ error: Error?) -> ()) {
        
        let requestUrl = getTaxonomyRequestUrl(taxonomyName: taxonomyGroupName)
        sendGetTaxonomyRequest(url: requestUrl, completionHandler: completionHandler)
    }
    
    private func sendGetItemsRequest<T>(url: String, completionHandler: @escaping (Bool, ItemsResponse<T>?, Error?) -> ()) where T: Mappable {
        Alamofire.request(url, headers: self.headers).responseObject { (response: DataResponse<ItemsResponse<T>>) in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let deliveryItems = value
                    if self.isDebugLoggingEnabled {
                        print("[Kentico Cloud] Getting items action has succeeded. Received \(String(describing: deliveryItems.items?.count)) items.")
                    }
                    completionHandler(true, deliveryItems, nil)
                }
            case .failure(let error):
                if self.isDebugLoggingEnabled {
                    print("[Kentico Cloud] Getting items action has failed. Check requested URL: \(url)")
                }
                completionHandler(false, nil, error)
            }
        }
    }
    
    private func sendGetItemRequest<T>(url: String, completionHandler: @escaping (Bool, ItemResponse<T>?, Error?) -> ()) where T: Mappable {
        Alamofire.request(url, headers: self.headers).responseObject() { (response: DataResponse<ItemResponse<T>>) in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    if self.isDebugLoggingEnabled {
                        print("[Kentico Cloud] Getting item action has succeeded.")
                    }
                    completionHandler(true, value, nil)
                }
            case .failure(let error):
                if self.isDebugLoggingEnabled {
                    print("[Kentico Cloud] Getting items action has failed. Check requested URL: \(url)")
                }
                completionHandler(false, nil, error)
            }
        }
    }
    
    private func sendGetTaxonomiesRequest(url: String, completionHandler: @escaping (Bool, [TaxonomyGroup]?, Error?) -> ()) {
        Alamofire.request(url, headers: self.headers).responseArray(keyPath: "taxonomies") { (response: DataResponse<[TaxonomyGroup]>) in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    if self.isDebugLoggingEnabled {
                        print("[Kentico Cloud] Getting taxonomies action has succeeded.")
                    }
                    completionHandler(true, value, nil)
                }
            case .failure(let error):
                if self.isDebugLoggingEnabled {
                    print("[Kentico Cloud] Getting taxonomies action has failed. Check requested URL: \(url)")
                }
                
                completionHandler(false, [], error)
            }
        }
    }
    
    private func sendGetTaxonomyRequest(url: String, completionHandler: @escaping (Bool, TaxonomyGroup?, Error?) -> ()) {
        Alamofire.request(url, headers: self.headers).responseObject { (response: DataResponse<TaxonomyGroup>) in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    if self.isDebugLoggingEnabled {
                        print("[Kentico Cloud] Getting taxonomies action has succeeded.")
                    }
                    completionHandler(true, value, nil)
                }
            case .failure(let error):
                if self.isDebugLoggingEnabled {
                    print("[Kentico Cloud] Getting taxonomies action has failed. Check requested URL: \(url)")
                }
                
                completionHandler(false, nil, error)
            }
        }
    }
    
    private func getItemsRequestUrl(queryParameters: [QueryParameter?]) -> String {
        
        let endpoint = getEndpoint()
        
        let requestBuilder = ItemsRequestBuilder.init(endpointUrl: endpoint, projectId: projectId, queryParameters: queryParameters)
        
        return requestBuilder.getRequestUrl()
        
        
    }
    
    private func getItemsRequestUrl(customQuery: String) -> String {
        
        let endpoint = getEndpoint()
        
        return "\(endpoint)/\(projectId)/\(customQuery)"
    }
    
    private func getItemRequestUrl(customQuery: String) -> String {
        let endpoint = getEndpoint()
        
        return "\(endpoint)/\(projectId)/\(customQuery)"
    }
    
    private func getItemRequestUrl(itemName: String, language: String? = nil) -> String {
        let endpoint = getEndpoint()
        
        
        var languageQueryParameter = ""
        if let language = language {
            languageQueryParameter = "?language=\(language)"
        }
        
        return "\(endpoint)/\(projectId)/items/\(itemName)\(languageQueryParameter)"
    }
    
    private func getTaxonomiesRequestUrl(customQuery: String?) -> String {
        let endpoint = getEndpoint()

        return "\(endpoint)/\(projectId)/\(customQuery ?? "taxonomies")"
    }
    
    private func getTaxonomyRequestUrl(taxonomyName: String) -> String {
        let endpoint = getEndpoint()
        
        return "\(endpoint)/\(projectId)/taxonomies/\(taxonomyName)"
    }
    
    private func getEndpoint() -> String {
        
        var endpoint: String?
        
        // Check override from property list first
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let propertyList = NSDictionary(contentsOfFile: path) {
                if let customEndpoint = propertyList["KenticoCloudDeliveryEndpoint"] {
                    endpoint = customEndpoint as? String
                    return endpoint!
                }
            }
        }
        
        // Request preview api in case there is an apiKey
        if apiKey == nil {
            return CloudConstants.liveDeliverEndpoint
        } else {
            return CloudConstants.previewDeliverEndpoint
        }
        
    }
    
    private func getHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        if let apiKey = apiKey {
            headers["authorization"] = "Bearer " + apiKey
        }
        
        return headers
    }
}
