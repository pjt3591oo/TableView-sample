//
//  ViewController.swift
//  table_sample
//
//  Created by 박정태 on 2022/03/06.
//

import UIKit

class ViewController: UIViewController {
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBAction func onClickEditHandler(_ sender: Any) {
        if self.tableView.isEditing {
            self.editBtn.setTitle("Edit", for: .normal)
            self.tableView.setEditing(false, animated: true)
        } else {
            self.editBtn.setTitle("Done", for: .normal)
            self.tableView.setEditing(true, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initTableView()
        self.initBounce()
    }
    
    func tableRefresh(isMainThreadCall: Bool) {
        if isMainThreadCall {
            DispatchQueue.main.async { // main thread에서 동작하도록 함
                self.tableView.reloadData()
            }
        } else {
            self.tableView.reloadData()
        }
    }
}

// 리프레시
extension ViewController {
    func initBounce() {
        self.refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        self.refreshStyle()
        self.tableView.refreshControl = self.refreshControl
    }
    
    func refreshStyle() {
        self.refreshControl.backgroundColor = UIColor.clear

        self.refreshControl.attributedTitle = NSAttributedString(string: "Loading Images",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        if self.refreshControl.isRefreshing == true {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1 ) { [weak self] in
                refresh.endRefreshing()
            }
        }
    }
 
    //MARK: - UIRefreshControl of ScrollView
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(velocity.y < -0.1) {
            self.refreshTable(refresh: self.refreshControl)
        }
    }
}

// 테이블 뷰
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: MyCustomCell = self.tableView.dequeueReusableCell(withIdentifier: "MyCustomCell", for:indexPath) as! MyCustomCell
        cell.title.text = "mung-\(indexPath.row)"
        cell.desc.text = "\(indexPath.row)번째 내용입니다."
        print("\(indexPath.row) 번째 cell 렌더링")
        return cell
    }
    
    func initTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // select 이벤트
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row) cell did select")
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // swipe 이벤트
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Archive action
        let archive = UIContextualAction(style: .normal,
                                         title: "Archive") { [weak self] (action, view, completionHandler) in
                                            self?.handleMoveToArchive()
                                            completionHandler(true)
        }
        archive.backgroundColor = .systemGreen

        // Trash action
        let trash = UIContextualAction(style: .normal,
                                       title: "Trash") { [weak self] (action, view, completionHandler) in
                                        self?.handleMoveToTrash()
                                        completionHandler(true)
        }
        trash.backgroundColor = .systemRed

        // Unread action
        let unread = UIContextualAction(style: .normal,
                                       title: "Mark as Unread") { [weak self] (action, view, completionHandler) in
                                        self?.handleMarkAsUnread()
                                        completionHandler(true)
        }
        unread.backgroundColor = .systemOrange
        let configuration = UISwipeActionsConfiguration(actions: [trash, archive, unread])

        return configuration
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row % 2 == 0 {
            return .insert
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            print("delete")
            // self.tableView.deleteRows(at: [indexPath], with: .automatic)
        } else {
            print("insert")
            // self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func handleMarkAsUnread() {
        print("Marked as unread")
    }

    private func handleMoveToTrash() {
        print("Moved to trash")
    }

    private func handleMoveToArchive() {
        print("Moved to archive")
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("from: \(sourceIndexPath.row) -> to: \(destinationIndexPath.row)")
    }
}
