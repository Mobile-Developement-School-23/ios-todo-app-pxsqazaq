//
//  AddTaskViewController.swift
//  ToDo
//
//  Created by Arystan on 19.06.2023.
//
import UIKit

protocol AddItemDelegate {
    func newTask(item: ToDoItem)
    func didDelete(_: AddTodoController, item: ToDoItem)
}

class AddTodoController: UIViewController {
    
    // MARK: - Properties
    var delegate: AddItemDelegate?
        
    private enum Constants {
        static let cancelTitle = "Отменить"
        static let titleText = "Дело"
        static let saveTitle = "Сохранить"
        static let deleteTitle = "Удалить"
        static let alertTitle = "Успех"
        static let alertMessage = "Новое дело успешно сохранено"
        static let alertActionTitle = "Ок"
        static let contentSpacing: CGFloat = 16
        static let scrollViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: -16)
        static let topBarHeight: CGFloat = 50
        static let textViewHeight: CGFloat = 120
        static let containerViewHeight: CGFloat = 60
        static let topBarInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        static let stackViewWidth: CGFloat = -32
    }
    
    private let item: ToDoItem
    private var presentationModel = AddTodoPresentationModel()
    
    // MARK: - Init
    
    init(item: ToDoItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews
    
    private lazy var textView = makeTextView()
    private lazy var addTodoView = makeAddTodoView()
    private lazy var stackView = makeStackView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.deleteTitle, for: .normal)
        button.layer.cornerRadius = GlobalConstants.cornerRadius
        button.layer.masksToBounds = true
        button.setTitleColor(.systemGray2, for: .disabled)
        button.setTitleColor(.red, for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = Constants.titleText
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Constants.cancelTitle, style: .plain, target: self, action: #selector(topBarButtonTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Constants.saveTitle, style: .done, target: self, action: #selector(topBarButtonTapped))
        
        setupView()
        setupKeyboard()
        setupObservers()
    }
    
    // MARK: - Private Methods
    
    func updateItem(text: String, importance: Importance, deadline: Date?) {
        deleteButton.isEnabled = true
        textView.update(todoText: text)
        addTodoView.update(importance: importance, deadline: deadline)
        presentationModel.importance = importance
        presentationModel.dueDate = deadline
    }
    
    private func updateRightBarButtonItem() {
        guard let rightBarButtonItem = navigationItem.rightBarButtonItem else {
            return
        }
        
        if(textView.text == "Что надо сделать?") {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        let barButtonColor: UIColor = rightBarButtonItem.isEnabled ? Colors.colorBlue.color : Colors.colorGray.color
        deleteButton.tintColor = deleteButton.isEnabled ? Colors.colorBlue.color : Colors.colorGray.color
        
        rightBarButtonItem.tintColor = barButtonColor
    }
    
    private func setupColors() {
        view.backgroundColor = Colors.backPrimary.color
        textView.backgroundColor = Colors.backSecondary.color
        deleteButton.backgroundColor = Colors.backSecondary.color
        updateRightBarButtonItem()
    }
    
    private func setupView() {
        
        setupColors()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.scrollViewInsets.left),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: Constants.scrollViewInsets.right),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: Constants.stackViewWidth),
            
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textViewHeight),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.containerViewHeight)
        ])
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func makeTextView() -> CustomTextView {
        let textView = CustomTextView()
        textView.customDelegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
    
    private func makeAddTodoView() -> AddTodoView {
        let view = AddTodoView(item: item)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            textView,
            addTodoView,
            deleteButton
        ])
        stackView.axis = .vertical
        stackView.spacing = Constants.contentSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        prepareOrientation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        prepareOrientation()
    }
    
    private func prepareOrientation() {
        if traitCollection.verticalSizeClass == .compact {
            addTodoView.isHidden = true
            deleteButton.isHidden = true
        } else {
            addTodoView.isHidden = false
            deleteButton.isHidden = false
        }
    }
    
    // MARK: - Selectors
    
    @objc private func topBarButtonTapped(selector: UIButton) {
        switch selector {
        case navigationItem.leftBarButtonItem:
            presentingViewController?.dismiss(animated: true, completion: nil)
            print("Cancel button tapped")
        case navigationItem.rightBarButtonItem:
            delegate?.newTask(item: ToDoItem(text: textView.text, importance: presentationModel.importance, deadline: presentationModel.dueDate))
            presentingViewController?.dismiss(animated: true, completion: nil)
        default:
            break
            
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    @objc private func deleteButtonTapped() {
        delegate?.didDelete(self, item: item)
        dismiss(animated: true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let nsValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        
        let keyboardSize = nsValue.cgRectValue
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
    }
    
    @objc private func keyboardWillHide() {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
    }
}

// MARK: - CustomTextViewDelegate

extension AddTodoController: CustomTextViewDelegate {
    
    func didChangeText(_ text: String) {
        presentationModel.text = text
        if(!text.isEmpty){
            navigationItem.rightBarButtonItem?.isEnabled = true
        }else{
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        updateRightBarButtonItem()
    }
}
// MARK: - AddTodoViewDelegate

extension AddTodoController: AddTodoViewDelegate {
    
    func didChangePriority(_ priority: Importance) {
        presentationModel.importance = priority
    }
    
    func didChangeDeadline(_ deadline: Date?) {
        presentationModel.dueDate = deadline
    }
}

