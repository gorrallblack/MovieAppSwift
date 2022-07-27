//
//  ViewController.swift
//  MovieApp
//
//  Created by
//

import UIKit
import PromiseKit

class MovieListViewController: UIViewController {
    @IBOutlet weak var movieListTableView: UITableView!
    @IBOutlet weak var movieListSearchBar: UISearchBar!
    
    var allMoviesData : [MovieDataItem]?
    var filteredMoviesData : [MovieDataItem]?
    
    var currentPage : Int = 0
    var lastPage = 0
    var isLoadingList : Bool = false
    var titleString : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.navigationItem.title = "Movie's List"
        
        //adding refresh control to the tableView
        self.loadCachedData()
        self.addKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentPage += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadMoviesFromServer()
        }
    }
    
    func addKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let begginingFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var deltaY = endFrame.origin.y - begginingFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.movieListSearchBar.frame.origin.y += deltaY
        }, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


//MARK:- Table view datasource
extension MovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMoviesData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MovieTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MovieTableViewCell
            cell.accessoryType = .disclosureIndicator
        
        guard let movieDataItem = filteredMoviesData?[indexPath.row] else { return cell }
            cell.customizedMovieTableCell(movieDataItem : movieDataItem)
        return cell;
    }
}


//MARK:- table view delegate
extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        
        if let movieDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
            movieDetailVC.selectedMovieID = "\(self.filteredMoviesData?[indexPath.row].id ?? 0)"
            self.navigationController?.pushViewController(movieDetailVC, animated: true)
        }
    }
    
    //call webservice to updata transactions
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList) {
            self.currentPage += 1

            if self.currentPage <= self.lastPage {
                self.isLoadingList = true
                self.loadMoviesFromServer()
            }
        }
    }
}

//MARK:- Search bar delegate
extension MovieListViewController: UISearchBarDelegate {
    //Filtering movies locally
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMoviesData? = (allMoviesData?.filter{$0.originalTitle?.lowercased().contains(searchText.lowercased()) ?? false})!
        
        if searchText == "" {
            filteredMoviesData = allMoviesData
        }
        
        movieListTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

//MARK:- Web Service
extension MovieListViewController {
    func loadMoviesFromServer() {
        if currentReachabilityStatus == .notReachable {
            self.showToastFromTop("No Internet")
            self.loadCachedData()
        }
        else {
            firstly {
                NetRequest.fetchMainMovieList(["page" : ("\(self.currentPage)")])
            }
            .done({ [weak self](movieData) in
                if self?.allMoviesData != nil {
                    print("allCatVideosData is \(movieData)")
                    self?.allMoviesData?.append(contentsOf: (movieData.results)!)
                    self?.filteredMoviesData?.append(contentsOf: (movieData.results)!)
                }
                else {
                    print("movieData is \(movieData)")
                    self?.allMoviesData = (movieData.results)
                    self?.filteredMoviesData = (movieData.results)
                }
                
                self?.currentPage = movieData.page ?? 0
                self?.lastPage = movieData.totalPages ?? 0
                
                if self?.currentPage == self?.lastPage {
                    
                }

                self?.isLoadingList = false
                self?.movieListTableView.reloadData()
                self?.saveCachedData()
            })
            .catch { error in
                print("error : \(error)")
            }
            .finally {
                print("finally")
            }
        }
    }
}


//MARK:- Caching data in plist file
extension MovieListViewController {
    func getPlistUrl() -> URL{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let path = documentsDirectory.appendingPathComponent("CachedData.plist")
        return URL(fileURLWithPath: path)
    }
    
    //loading cached data from plist
    func loadCachedData() {
        let pilstURL = getPlistUrl()
        
        do{
            let plistDecoder = PropertyListDecoder()
            let data = try Data.init(contentsOf: pilstURL)
            let value = try plistDecoder.decode([MovieDataItem].self, from: data)
            
            self.allMoviesData = value as [MovieDataItem]
            self.filteredMoviesData = allMoviesData
            self.movieListTableView.reloadData()
        }
        catch {
            print(error)
        }
    }
    
    //caching data to plist
    func saveCachedData() {
       let pilstURL = getPlistUrl()
        do {
            let plistEncoder = PropertyListEncoder()
                plistEncoder.outputFormat = .xml
            let plistData = try plistEncoder.encode(self.allMoviesData)
            try plistData.write(to: pilstURL)
            
        } catch {
            print(error)
        }
    }
}
