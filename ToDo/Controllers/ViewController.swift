import UIKit

class ViewController: UIViewController {

    let tableView = UITableView()
    let completed = UILabel()
    var data: [ToDoItem] = []
    var n: Int = 0
    let show = UIButton(type: .system)
    let file = FileCache(filepath: "/Users/new/Desktop/ToDo/ToDo/sss.csv")

    override func viewDidLoad() {
        super.viewDidLoad()

        file.loadFromCSVFile()

        tableView.register(ToDoCell.self, forCellReuseIdentifier: "ToDoCell")

        data = file.todoItems.filter { $0.isDone == false }

        setupUI()
        self.view.layer.backgroundColor = UIColor(red: 0.97, green: 0.966, blue: 0.951, alpha: 1).cgColor
    }

    func updateCompletedCount() {
        let completedCount = file.todoItems.filter { $0.isDone == true }.count
        n = completedCount
        completed.text = "Выполнено — \(n)"
    }

    func showNotCompletedTasks() {
        data = data.filter { $0.isDone == false }
        tableView.reloadData()
        updateCompletedCount()
    }

    func showAllTasks() {
        data = file.todoItems
        tableView.reloadData()
        updateCompletedCount()
    }

    func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 12
        tableView.estimatedRowHeight = 100
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false


        self.title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        completed.text = "Выполнено — \(n)"
        completed.font = UIFont.systemFont(ofSize: 16)
        completed.textColor = .lightGray

        show.setTitle("Показать", for: .normal)
        show.setTitleColor(.blue, for: .normal)
        show.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        let addTask = UIButton()
        addTask.setImage(UIImage(named: "plus"), for: .normal)
        addTask.addTarget(self, action: #selector(addItem), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [completed, show])
        stackView.axis = .horizontal

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        contentView.addSubview(stackView)
        contentView.addSubview(tableView)

        view.addSubview(scrollView)
        view.addSubview(addTask)

        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
            $0.bottom.equalTo(view.snp.bottom).offset(-16)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(18)
            $0.left.equalTo(contentView.safeAreaLayoutGuide.snp.left).offset(32)
            $0.right.equalTo(contentView.safeAreaLayoutGuide.snp.right).inset(32)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(12)
            $0.left.equalTo(contentView.snp.left).offset(16)
            $0.right.equalTo(contentView.snp.right).inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }

        addTask.snp.makeConstraints {
            $0.width.height.equalTo(70)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(41)
        }
    }

    @objc func buttonTapped() {
        if show.titleLabel?.text == "Показать" {
            showAllTasks()
            show.setTitle("Скрыть", for: .normal)
        } else {
            showNotCompletedTasks()
            show.setTitle("Показать", for: .normal)
        }
    }

    @objc func addItem() {
        let navigationController = UINavigationController(rootViewController: TodoItemDetailsViewController())
        present(navigationController, animated: true)
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = data.count
        updateCompletedCount()
        return num
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoCell.identifier, for: indexPath) as? ToDoCell else {
            fatalError("Chert")
        }
        cell.configure(with: data[indexPath.row])
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionInfo = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            completionHandler(true)
        }
        actionInfo.image = UIImage(systemName: "info.circle.fill")
        let actionRemove = UIContextualAction(style: .destructive, title: "") { (action, view, completionHandler) in
            let id = self.data[indexPath.row].id
            self.file.remove(id: "\(id)")
            self.file.saveToCSVFile()
            self.data = self.file.todoItems.filter { $0.isDone == false }
            self.tableView.reloadData()
            completionHandler(true)
        }
        actionRemove.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [actionRemove, actionInfo])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionDone = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            let id = self.data[indexPath.row].id
            self.file.completedTask(id: id)
            self.file.saveToCSVFile()
            self.data = self.file.todoItems.filter { $0.isDone == false }
            self.tableView.reloadData()
            completionHandler(true)
        }
        actionDone.image = UIImage(systemName: "checkmark.circle")
        actionDone.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [actionDone])
    }
}
