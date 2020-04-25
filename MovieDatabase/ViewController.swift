//
//  ViewController.swift
//  MovieDatabase
//
//  Created by Steven Fellows on 4/24/20.
//  Copyright © 2020 Steven Fellows. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchResultsStackView: UIStackView!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    var shows = [Show]()
    lazy var webService = {
        return WebService()
    }()
    var searchTask: DispatchWorkItem?
    var filterSelected: showType = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        setupTableView()
        displayEmptyResults()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ShowTableViewCell", bundle: nil), forCellReuseIdentifier: "ShowTableViewCell")
    }
    
    private func startSearch(for searchText: String, waitTime: Double = 0.5) {
        searchTask?.cancel()
        if searchText.count > 0 {
            let task = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.search(for: searchText, filter: self.filterSelected)
            }
            
            searchTask = task
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + waitTime, execute: task)
        } else {
            displayEmptyResults()
        }
    }
    
    private func search(for searchText: String, filter: showType) {
        guard webService.isConnectedToNetwork() else {
            displayOffline()
            return
        }
        webService.getSearchResultsData(for: searchText, filter: filter) { [weak self] (data) in
            guard let receivedData = data, let self = self else { return }
            do {
                let responseObject = try JSONDecoder().decode(Response.self, from: receivedData)
                self.update(with: responseObject)
            } catch {
                self.update(with: nil)
            }
        }
    }
    
    private func update(with response: Response?) {
        if let foundResponse = response, foundResponse.reponseSucceeded, let foundShows = foundResponse.search, foundShows.count > 0 {
            shows = foundShows
            DispatchQueue.main.async { [weak self] in
                self?.displayResults()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.displayNoResults()
            }
        }
        
    }

    private func displayEmptyResults() {
        searchTask = nil
        shows = [Show]()
        noResultsLabel.isHidden = true
        searchResultsStackView.isHidden = true
        checkConnectivity()
    }

    private func displayResults() {
        noResultsLabel.isHidden = true
        searchResultsStackView.isHidden = false
        tableView.reloadData()
        checkConnectivity()
    }
    
    private func displayNoResults() {
        shows = [Show]()
        noResultsLabel.text =  "No Results"
        noResultsLabel.isHidden = false
        searchResultsStackView.isHidden = true
        checkConnectivity()
    }
    
    private func displayOffline() {
        noResultsLabel.text =  "Device is Offline"
        noResultsLabel.isHidden = false
        searchResultsStackView.isHidden = true
    }
    
    private func checkConnectivity() {
        if !webService.isConnectedToNetwork() {
            displayOffline()
        }
    }
    
    @IBAction func filterChanged(_ sender: Any) {
        switch filterSegmentedControl.selectedSegmentIndex {
        case 0:
            filterSelected = .none
        case 1:
            filterSelected = .movie
        case 2:
            filterSelected = .series
        default:
            filterSelected = .none
        }
        
        startSearch(for: searchBar.text ?? "", waitTime: 0.0)
    }
    
    
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        startSearch(for: searchText)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTableViewCell", for: indexPath) as? ShowTableViewCell {
            let show = shows[indexPath.row]
            cell.configure(with: show)
            return cell
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

