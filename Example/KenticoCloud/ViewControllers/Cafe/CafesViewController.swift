//
//  CafesViewController.swift
//  KenticoCloud
//
//  Created by martinmakarsky@gmail.com on 08/16/2017.
//  Copyright (c) 2017 martinmakarsky@gmail.com. All rights reserved.
//

import UIKit
import KenticoCloud
import AlamofireImage

class CafesViewController: UIViewController, UITableViewDataSource {
    
    private let contentType = "cafe"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var refreshControl: UIRefreshControl!
    
    private var cafes: [Cafe] = []
    private var loader: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.insertSubview(refreshControl!, at: 0)
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
        
        getCafes()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cafes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cafeCell") as! CafeTableViewCell
        
        let cafe = cafes[indexPath.row]
        cell.city.text = cafe.city
        cell.firstRowAddress.text = cafe.street
        cell.secondRowAddress.text = cafe.state
        cell.phone.text = cafe.phone
        
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
    }
    
    @IBAction func showMenu(_ sender: Any) {
        panel?.openLeft(animated: true)
    }
    
    @IBAction func refreshTable(_ sender: Any) {
        getCafes()
    }
    
    private func getCafes() {
        showLoader()
        
        let cloudClient = DeliveryClient.init(projectId: AppConstants.projectId)
        
        let typeQueryParameter = QueryParameter.init(parameterKey: QueryParameterKey.type, parameterValue: contentType)
        let languageQueryParameter = QueryParameter.init(parameterKey: QueryParameterKey.language, parameterValue: "es-ES")
        let cafesQueryParameters = [typeQueryParameter, languageQueryParameter]
        
        do {
            try cloudClient.getItems(modelType: Cafe.self, queryParameters: cafesQueryParameters) { (isSuccess, items, error) in
                if isSuccess {
                    if let cafes = items {
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
                
                self.loader.dismiss(animated: false, completion: nil)
            }
        } catch {
            self.loader.dismiss(animated: false, completion: nil)
            print("Error info: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func showLoader() {
        loader = UIAlertController(title: nil, message: "Loading cafes...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        loader.view.addSubview(loadingIndicator)
        self.view.window?.rootViewController?.present(loader, animated: true, completion: nil)
    }
    
    
}

