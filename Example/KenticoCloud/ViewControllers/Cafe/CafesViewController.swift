//
//  CafesViewController.swift
//  KenticoCloud
//
//  Created by martinmakarsky@gmail.com on 08/16/2017.
//  Copyright © 2017 Kentico Software. All rights reserved.
//

import UIKit
import KenticoCloud
import AlamofireImage

class CafesViewController: ListingBaseViewController, UITableViewDataSource {
    
    // MARK: Properties
    
    private let contentType = "cafe"
    
    var cafes: [Cafe] = []
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var refreshControl: UIRefreshControl!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if cafes.count == 0 {
            getCafes()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cafes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cafeCell") as! CafeTableViewCell
        cell.photo.addBorder()
        
        let cafe = cafes[indexPath.row]
        cell.cafeTitle.text = cafe.city
        cell.cafeSubtitle.text = "\(cafe.street ?? "") \(cafe.phone ?? "")"
        
        if let imageUrl = cafe.imageUrl {
            let url = URL(string: imageUrl)
            cell.photo.af_setImage(withURL: url!)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cafeDetailSegue" {
            
            let cafeDetailViewController = segue.destination
                as! CafeDetailViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow!
            cafeDetailViewController.cafe = cafes[indexPath.row]
            
            let cell = self.tableView.cellForRow(at: indexPath) as! CafeTableViewCell
            cafeDetailViewController.image = cell.photo.image
        }
        
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    // MARK: Outlet actions
    
    @IBAction func refreshTable(_ sender: Any) {
        getCafes()
    }
    
    // MARK: Getting items
    
    private func getCafes() {
        self.showLoader(message: "Loading cafes...")
        
        let cloudClient = DeliveryClient.init(projectId: AppConstants.projectId)
        
        let typeQueryParameter = QueryParameter.init(parameterKey: QueryParameterKey.type, parameterValue: contentType)
        
        cloudClient.getItems(modelType: Cafe.self, queryParameters: [typeQueryParameter]) { (isSuccess, itemsResponse, error) in
            if isSuccess {
                if let cafes = itemsResponse?.items {
                    self.cafes = cafes
                    self.tableView.reloadData()
                }
            } else {
                if let error = error {
                    print(error)
                }
            }
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            self.hideLoader()
        }
    }    
}

