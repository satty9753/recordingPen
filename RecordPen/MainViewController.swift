//
//  MainViewController.swift
//  RecordPen
//
//  Created by Michelle Chen on 2017/8/13.
//  Copyright © 2017年 Michelle Chen. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var recordArray = [["name":String(),"path":String()]]
    var filenames:String!
    var recordingFiles: URL!
    var filterData = [String]()
    var isSearching = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        self.searchBar.returnKeyType = .done
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
          return filterData.count
        }
        return recordArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if isSearching{
            cell.textLabel?.text = filterData[indexPath.row]
        
        }
        else{
             cell.textLabel?.text = recordArray[indexPath.row]["name"]
        }
        // Configure the cell...
        
        return cell

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text=="" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }else{
            isSearching = true
            var nameArray = [String]()
            for i in recordArray{
             nameArray.append(i["name"]!)
            }
            filterData = nameArray.filter({$0.description.contains(searchBar.text!)})
            tableView.reloadData()
        }
        

}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "PlayViewController") as? PlayViewController
        controller?.recordingArray = recordArray[indexPath.row]
        self.present(controller!, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.recordArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
