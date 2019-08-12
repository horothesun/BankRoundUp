import UIKit
import RxSwift
import RxCocoa

enum RoundUpViewEvent {
    case newGoal
    case viewWillAppear
}

protocol RoundUpViewProtocol: class {
    var viewEvents: Observable<RoundUpViewEvent> { get }
}

final class RoundUpViewController: UIViewController {

    private lazy var newGoalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()

    private lazy var newGoalButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("New Goal", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        return button
    }()

    private lazy var newGoalActivityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var selectGoalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private lazy var selectGoalButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Select Goal", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.isEnabled = false
        return button
    }()

    private lazy var comingSoonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Coming soon!"
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = .lightGray
        return label
    }()

    private let disposeBag = DisposeBag()

    lazy var presenter: RoundUpPresenterProtocol = {
        return RoundUpPresenter(view: self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Round-up"
        view.backgroundColor = .white

        setupNewGoalStackView(in: view)
        setupSelectGoalStackView(in: view)
        setupRx()
    }

    private func setupNewGoalStackView(in superView: UIView) {
        superView.addSubview(newGoalStackView)

        newGoalStackView.addArrangedSubview(newGoalButton)
        newGoalStackView.addArrangedSubview(newGoalActivityIndicatorView)

        setupNewGoalButton()
    }

    private func setupNewGoalButton() {
        NSLayoutConstraint.activate([
            newGoalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGoalButton.centerYAnchor
                .constraint(equalTo: view.centerYAnchor, constant: -30)
            ])
    }

    private func setupSelectGoalStackView(in superView: UIView) {
        superView.addSubview(selectGoalStackView)

        selectGoalStackView.addArrangedSubview(selectGoalButton)
        selectGoalStackView.addArrangedSubview(comingSoonLabel)

        NSLayoutConstraint.activate([
            selectGoalStackView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor),
            selectGoalStackView.topAnchor
                .constraint(equalTo: newGoalStackView.bottomAnchor, constant: 36)
            ])
    }
}

extension RoundUpViewController {

    private func setupRx() {
        presenter.viewState
            .drive(
                onNext: render(viewState:),
                onCompleted: { },
                onDisposed: { }
            )
            .disposed(by: disposeBag)
    }

    private func render(viewState: RoundUpViewState) {
        switch viewState {
        case .normal:
            showNormal()
        case .loading:
            showLoading()
        case .toWeekSelection(let goalUid):
            goToWeekSelection(goalUid)
        case .error:
            showError()
        }
    }

    private func showNormal() {
        newGoalActivityIndicatorView.stopAnimating()
        newGoalButton.isEnabled = true
    }

    private func showLoading() {
        newGoalButton.isEnabled = false
        newGoalActivityIndicatorView.startAnimating()
    }

    private func goToWeekSelection(_ goalUid: UUID) {
        let weekSelectionVC = WeekSelectionViewController(goalUid: goalUid)
        navigationController?.pushViewController(weekSelectionVC, animated: true)
    }

    private func showError() {
        showAlert(
            title: "Ops...",
            message: "We're unable to create a new savings goal now. Please try later 🙏",
            cancelText: "OK")
        newGoalActivityIndicatorView.stopAnimating()
        newGoalButton.isEnabled = true
    }
}

extension RoundUpViewController: RoundUpViewProtocol {

    var viewEvents: Observable<RoundUpViewEvent> {

        let newGoalEvents = newGoalButton.rx.tap
            .map { RoundUpViewEvent.newGoal }
        let viewWillAppearEvents = rx
            .methodInvoked(#selector(viewWillAppear(_:)))
            .map { _ in RoundUpViewEvent.viewWillAppear }
        return Observable.merge(
            newGoalEvents,
            viewWillAppearEvents)
    }
}
