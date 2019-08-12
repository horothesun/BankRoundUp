import UIKit
import RxSwift
import RxCocoa

enum WeekSelectionViewEvent {
    case refresh
    case select(weekIndex: Int)
    case save(goalUid: UUID, weekIndex: Int)
}

protocol WeekSelectionViewProtocol: class {
    var viewEvents: Observable<WeekSelectionViewEvent> { get }
}

final class WeekSelectionViewController: UIViewController {

    private lazy var saveBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            title: "Save 🏦",
            style: .plain,
            target: self,
            action: nil)
        return barButtonItem
    }()

    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var selectAWeekLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select a week"
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    private lazy var spacingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private lazy var saveActivityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var weeklyRoundUpsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.rowHeight = 44
        tableView.register(
            WeeklyRoundUpTableViewCell.self,
            forCellReuseIdentifier: WeeklyRoundUpTableViewCell.cellId)
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: EmptyWeeklyRoundUpsTableViewDataSource.cellId)
        return tableView
    }()

    private lazy var emptyWeeklyRoundUpsDataSource: EmptyWeeklyRoundUpsTableViewDataSource = {
        return EmptyWeeklyRoundUpsTableViewDataSource()
    }()
    private var nonEmptyWeeklyRoundUpsDataSource: NonEmptyWeeklyRoundUpsTableViewDataSource?

    private let disposeBag = DisposeBag()

    lazy var presenter: WeekSelectionPresenterProtocol = {
        return WeekSelectionPresenter(view: self)
    }()

    private let goalUid: UUID

    init(goalUid: UUID) {
        self.goalUid = goalUid

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Weeks"
        view.backgroundColor = .white

        setupSaveBarButtonItem()
        setupTopStackView(in: view)
        setupWeeksTableView(in: view)
        setupRx()
    }

    private func setupSaveBarButtonItem() {
        navigationItem.rightBarButtonItem = saveBarButtonItem
    }

    private func setupTopStackView(in superView: UIView) {
        superView.addSubview(topStackView)

        topStackView.addArrangedSubview(selectAWeekLabel)
        topStackView.addArrangedSubview(spacingView)
        topStackView.addArrangedSubview(saveActivityIndicatorView)

        let safeArea = superView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            topStackView.heightAnchor.constraint(equalToConstant: 64),
            topStackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            topStackView.leadingAnchor
                .constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            topStackView.trailingAnchor
                .constraint(equalTo: safeArea.trailingAnchor, constant: -24)
        ])
    }

    private func setupWeeksTableView(in superView: UIView) {
        superView.addSubview(weeklyRoundUpsTableView)

        let safeArea = superView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            weeklyRoundUpsTableView.topAnchor.constraint(equalTo: topStackView.bottomAnchor),
            weeklyRoundUpsTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            weeklyRoundUpsTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            weeklyRoundUpsTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}

extension WeekSelectionViewController {

    private func setupRx() {
        presenter.viewState
            .drive(
                onNext: render(viewState:),
                onCompleted: { },
                onDisposed: { }
            )
            .disposed(by: disposeBag)
    }

    private func render(viewState: WeekSelectionViewState) {
        switch viewState {
        case .loadingWeeklyRoundUps:
            showLoadingWeeks()
        case .errorLoadingWeeklyRoundUps:
            showErrorLoadingWeeks()
        case .noWeeklyRoundUps:
            showNoWeeklyRoundUps()
        case .readyForSelection(let weeklyRoundUpDisplayModels):
            showReadyForSelection(weeklyRoundUpDisplayModels)
        case .weeklyRoundUpSelected(let rowIndex):
            showWeeklyRoundUpSelected(rowIndex)
        case .saving:
            showSaving()
        case .successfullySaved:
            showSuccessfullySaved()
        case .errorSaving:
            showErrorSaving()
        }
    }

    private func showLoadingWeeks() {
        saveBarButtonItem.isEnabled = false
        selectAWeekLabel.isEnabled = false
        weeklyRoundUpsTableView.isScrollEnabled = false
        weeklyRoundUpsTableView.separatorStyle = .none
        weeklyRoundUpsTableView.dataSource = nil
        weeklyRoundUpsTableView.reloadData()
        weeklyRoundUpsTableView.allowsSelection = false
        saveActivityIndicatorView.startAnimating()
    }

    private func showErrorLoadingWeeks() {
        saveBarButtonItem.isEnabled = false
        selectAWeekLabel.isEnabled = false
        weeklyRoundUpsTableView.isScrollEnabled = false
        weeklyRoundUpsTableView.separatorStyle = .none
        weeklyRoundUpsTableView.dataSource = nil
        weeklyRoundUpsTableView.reloadData()
        weeklyRoundUpsTableView.allowsSelection = false
        saveActivityIndicatorView.stopAnimating()
        showAlert(
            title: "Ops...",
            message: "We're unable to load the weekly round-ups now. Please try later 🙏",
            cancelText: "OK") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
    }

    private func showNoWeeklyRoundUps() {
        saveBarButtonItem.isEnabled = false
        selectAWeekLabel.isEnabled = false
        weeklyRoundUpsTableView.isScrollEnabled = false
        weeklyRoundUpsTableView.allowsSelection = false
        weeklyRoundUpsTableView.separatorStyle = .none
        weeklyRoundUpsTableView.dataSource = emptyWeeklyRoundUpsDataSource
        weeklyRoundUpsTableView.reloadData()
        saveActivityIndicatorView.stopAnimating()
    }

    private func showReadyForSelection(
        _ weeklyRoundUpDisplayModels: [WeeklyRoundUpDisplayModel]) {

        saveBarButtonItem.isEnabled = false
        selectAWeekLabel.isEnabled = true
        weeklyRoundUpsTableView.isScrollEnabled = true
        weeklyRoundUpsTableView.allowsSelection = true
        weeklyRoundUpsTableView.separatorStyle = .singleLine
        nonEmptyWeeklyRoundUpsDataSource =
            NonEmptyWeeklyRoundUpsTableViewDataSource(
                displayModels: weeklyRoundUpDisplayModels)
        weeklyRoundUpsTableView.dataSource = nonEmptyWeeklyRoundUpsDataSource
        weeklyRoundUpsTableView.reloadData()
        saveActivityIndicatorView.stopAnimating()
    }

    private func showWeeklyRoundUpSelected(_ rowIndex: Int) {
        saveBarButtonItem.isEnabled = true
        selectAWeekLabel.isEnabled = true
        weeklyRoundUpsTableView.isScrollEnabled = true
        weeklyRoundUpsTableView.allowsSelection = true
        weeklyRoundUpsTableView.selectRow(
            at: IndexPath(row: rowIndex, section: 0),
            animated: false,
            scrollPosition: .top)
        saveActivityIndicatorView.stopAnimating()
    }

    private func showSaving() {
        saveBarButtonItem.isEnabled = false
        selectAWeekLabel.isEnabled = true
        weeklyRoundUpsTableView.isScrollEnabled = false
        weeklyRoundUpsTableView.allowsSelection = false
        saveActivityIndicatorView.startAnimating()
    }

    private func showSuccessfullySaved() {
        saveBarButtonItem.isEnabled = false
        selectAWeekLabel.isEnabled = true
        weeklyRoundUpsTableView.isScrollEnabled = true
        weeklyRoundUpsTableView.allowsSelection = true
        if let selectedRowIndexPath = weeklyRoundUpsTableView.indexPathForSelectedRow {
            weeklyRoundUpsTableView
                .deselectRow(at: selectedRowIndexPath, animated: true)
        }
        saveActivityIndicatorView.stopAnimating()
        showAlert(
            title: "Success!",
            message: "Money's been added to your goal 👍",
            cancelText: "OK")
    }

    private func showErrorSaving() {
        saveBarButtonItem.isEnabled = true
        selectAWeekLabel.isEnabled = true
        weeklyRoundUpsTableView.isScrollEnabled = true
        weeklyRoundUpsTableView.allowsSelection = true
        saveActivityIndicatorView.stopAnimating()
        showAlert(
            title: "Ops...",
            message: "We're unable to add money to your goal now. Please try later 🙏",
            cancelText: "OK")
    }
}

extension WeekSelectionViewController: WeekSelectionViewProtocol {

    var viewEvents: Observable<WeekSelectionViewEvent> {

        let selectedWeekIndexEvents = weeklyRoundUpsTableView.rx
            .itemSelected
            .map { $0.row }
        let weekSelectionEvents = selectedWeekIndexEvents
            .map { WeekSelectionViewEvent.select(weekIndex: $0) }
        let saveEvents = saveBarButtonItem.rx
            .tap
            .withLatestFrom(selectedWeekIndexEvents)
            { (_, weekIndex) -> WeekSelectionViewEvent in
                .save(goalUid: self.goalUid, weekIndex: weekIndex)
            }
        return Observable
            .merge(
                weekSelectionEvents,
                saveEvents
            )
            .startWith(.refresh)
    }
}
