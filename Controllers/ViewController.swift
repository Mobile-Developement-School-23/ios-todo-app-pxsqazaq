import UIKit

@MainActor
class ViewController: UIViewController, AddItemDelegate {
    @MainActor
    func newTask(item: ToDoItem) {
        if checkNewItem {
            file.add(todoItem: item)
            file.saveToJSONFile()
            addToDoNetwork(item: item)
            checkStatus()
        } else {
            file.update(id: updateItemID, text: item.text, importance: item.importance, deadline: item.deadline)
            file.saveToJSONFile()
            changeToDoNetwork(item: item)
            checkStatus()
        }
    }
    @MainActor
    func didDelete(_: AddTodoController, item: ToDoItem) {
        file.remove(id: item.id)
        file.saveToJSONFile()
        deleteToDoNetwork(id: item.id)
        checkStatus()
    }
    
    var updateItemID: String = ""
    var checkNewItem = false
    let network: NetworkingService = DefaultNetworkingService(deviceID: "Mac")
    private lazy var tableView = makeTableView()
    private lazy var completed = makeCompleted()
    private lazy var show = makeShow()
    var data: [ToDoItem] = []
    var displayedData: [ToDoItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var isDirty = true
    var completedTasks: Int = 0
    var file = FileCache(filepath: "/Users/new/Desktop/ToDo/ToDo/sss.json")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTodoList()
        setupUI()
    }
    
    private func loadTodoList() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                let todoList = try await self.network.getItemList()
                self.data = todoList
                checkStatus()
            } catch {
                self.isDirty = true
            }
        }
    }
    
    func deleteToDoNetwork(id: String) {
        
        guard let itemIndex = data.firstIndex(where: { $0.id == id })
        else { return }
        data.remove(at: itemIndex)

            if self.isDirty {
                loadTodoList()
            }

            Task {
                do {
                    _ = try await network.deleteElement(by: id)
                    self.isDirty = false
                } catch {
                    self.isDirty = true
                }
            }
        }
    
    func addToDoNetwork(item: ToDoItem) {

            if self.isDirty {
                loadTodoList()
            }

            Task {
                do {
                    _ = try await network.postElement(with: item)
                    loadTodoList()
                    self.isDirty = false
                } catch {
                    self.isDirty = true
                }
            }
        }

        func changeToDoNetwork(item: ToDoItem) {

            if self.isDirty {
                loadTodoList()
            }

            Task {
                do {
                    _ = try await network.putElement(by: item)
                    loadTodoList()
                    self.isDirty = false
                } catch {
                    self.isDirty = true
                }
            }
        }
    
    private func updateCompletedCount() {
        let completedCount = data.filter { $0.isDone == true }.count
        completedTasks = completedCount
        completed.text = "Выполнено — \(completedTasks)"
    }
    
    private func showNotCompletedTasks() {
        displayedData = data.filter { $0.isDone == false }
    }
    
    private func showAllTasks() {
        displayedData = data
    }
    
    private func makeTableView() -> UITableView {
        let table = UITableView()
        table.register(ToDoCell.self, forCellReuseIdentifier: "ToDoCell")
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = Colors.backElevated.color
        table.layer.cornerRadius = 12
//        table.estimatedRowHeight = 100
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = false
        return table
    }
    
    private func makeFooterView() -> UIView {
        let view = UIView()
        let label = UILabel()
        let button = UIButton()
        
        button.setImage(UIImage(named: "Plus 1"), for: .normal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(addItem), for: .touchUpInside)
        
        label.text = "Новое"
        label.textColor = Colors.colorBlue.color
        label.font = GlobalConstants.body
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addItem))
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(button)
        view.addSubview(label)
    
        button.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        label.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalTo(button.snp.right).offset(12)
            $0.centerY.equalToSuperview()
        }
        
        return view
    }
    
    private func makeCompleted() -> UILabel {
        let label = UILabel()
        label.text = "Выполнено — \(completedTasks)"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = Colors.colorGray.color
        return label
    }
    
    private func makeShow() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Показать", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }
    
    private func checkStatus() {
        if self.show.titleLabel?.text == "Показать" {
            self.displayedData = self.data.filter { $0.isDone == false }
        } else {
            self.displayedData = self.data
        }
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.backView.color
        
        self.title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 34, bottom: 0, right: 0)
        
        let addTask = UIButton()
        addTask.setImage(UIImage(named: "plus"), for: .normal)
        addTask.addTarget(self, action: #selector(addItem), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [completed, show])
        stackView.axis = .horizontal
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = Colors.backView.color
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
            $0.bottom.equalTo(addTask.snp.bottom).offset(16)
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
            $0.bottom.equalTo(addTask.snp.bottom).offset(16)
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
        let navigationController = AddTodoController(item: ToDoItem(text: "Что надо сделать?"))
        navigationController.delegate = self
        self.checkNewItem = true

        present(UINavigationController(rootViewController: navigationController), animated: true)
        
    }
    
}

extension ViewController: ToDoCellDelegate {
    func radioButtonTapped(cell: ToDoCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let id = displayedData[indexPath.row].id

        if  displayedData[indexPath.row].isDone {
            file.notCompleteTask(id: id)
        } else {
            file.completedTask(id: id)
        }
        file.saveToJSONFile()
        checkStatus()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = displayedData.count
        updateCompletedCount()
        return num
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return makeFooterView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoCell.identifier, for: indexPath) as? ToDoCell else {
            fatalError("Error: Unable to dequeue ToDoCell")
        }
        cell.selectionStyle = .none
        cell.delegate = self
        cell.configure(with: displayedData[indexPath.row])
        cell.backgroundColor = Colors.backElevated.color
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let displayedData  = self.displayedData[indexPath.row]
        let page = AddTodoController(item: displayedData)
        self.updateItemID = displayedData.id
        self.checkNewItem = false
        page.updateItem(text: displayedData.text, importance: displayedData.importance, deadline: displayedData.deadline)
        page.delegate = self
        self.present(UINavigationController(rootViewController: page), animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionInfo = UIContextualAction(style: .normal, title: "") { (_, _, completionHandler) in
            let displayedData  = self.displayedData[indexPath.row]
            let page = AddTodoController(item: displayedData)
            self.updateItemID = displayedData.id
            self.checkNewItem = false
            page.updateItem(text: displayedData.text, importance: displayedData.importance, deadline: displayedData.deadline)
            page.delegate = self
            self.present(UINavigationController(rootViewController: page), animated: true)

            completionHandler(true)
        }
        actionInfo.image = UIImage(systemName: "info.circle.fill")
        actionInfo.backgroundColor = Colors.colorGray2.color
        
        let actionRemove = UIContextualAction(style: .destructive, title: "") { (_, _, completionHandler) in
            let id = self.displayedData[indexPath.row].id
            self.file.remove(id: id)
            self.deleteToDoNetwork(id: id)
            self.file.saveToJSONFile()
            self.checkStatus()
            
            completionHandler(true)
        }
        actionRemove.image = UIImage(systemName: "trash")
        actionRemove.backgroundColor = Colors.colorRed.color
        return UISwipeActionsConfiguration(actions: [actionRemove, actionInfo])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionDone = UIContextualAction(style: .normal, title: "") { (_, _, completionHandler) in
            let id = self.displayedData[indexPath.row].id
            let item = self.file.completedTask(id: id)
            print(item)
            self.changeToDoNetwork(item: item)
            self.checkStatus()
            completionHandler(true)
        }
        actionDone.image = UIImage(systemName: "checkmark.circle")
        actionDone.backgroundColor = Colors.colorGreen.color
        return UISwipeActionsConfiguration(actions: [actionDone])
    }
}
