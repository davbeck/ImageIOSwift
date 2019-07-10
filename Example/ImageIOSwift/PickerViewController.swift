import UIKit

class PickerViewController<DetailViewController: ImageSourceViewController>: UITableViewController {
    let example: ExampleList
    
    init(example: ExampleList) {
        self.example = example
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = example.name
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.example.sources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let url = self.example.sources[indexPath.row]
        if url?.isFileURL ?? false {
            cell.textLabel?.text = url?.lastPathComponent
        } else {
            cell.textLabel?.text = url?.absoluteString
        }
        cell.textLabel?.lineBreakMode = .byTruncatingMiddle
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let option = example.sources[indexPath.row] else { return }
        
        let viewController = self.example.detailViewControllerType.init(url: option)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        self.showDetailViewController(navigationController, sender: nil)
    }
}
