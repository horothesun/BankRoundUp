import RxSwift
import RxCocoa

enum RoundUpViewState {
    case normal
    case loading
    case toWeekSelection(goalUid: UUID)
    case error
}

protocol RoundUpPresenterProtocol {
    var viewState: Driver<RoundUpViewState> { get }
}

final class RoundUpPresenter {

    private let businessLogic: SavingsGoalCreationBusinessLogicProtocol
    private weak var view: RoundUpViewProtocol?

    init(
        businessLogic: SavingsGoalCreationBusinessLogicProtocol
            = SavingsGoalCreationBusinessLogic(),
        view: RoundUpViewProtocol) {

        self.businessLogic = businessLogic
        self.view = view
    }
}

extension RoundUpPresenter: RoundUpPresenterProtocol {

    var viewState: Driver<RoundUpViewState> {

        guard let view = view else { return .never() }

        return view.viewEvents
            .flatMap { [weak self] viewEvent -> Observable<RoundUpViewState> in
                guard let nonNilSelf = self else { return .never() }
                let backgroundScheduler =
                    ConcurrentDispatchQueueScheduler(qos: .background)

                switch viewEvent {
                case .newGoal:
                    return nonNilSelf.viewStateOnNewGoal
                        .subscribeOn(backgroundScheduler)
                case .viewWillAppear:
                    return .just(.normal)
                }
            }
            .asDriver(onErrorJustReturn: .error)
    }

    private var viewStateOnNewGoal: Observable<RoundUpViewState> {

        let viewStateWithoutLoading = businessLogic.createSavingsGoal()
            .map { goalUid -> RoundUpViewState in
                .toWeekSelection(goalUid: goalUid)
            }
        return Observable<RoundUpViewState>
            .just(.loading)
            .concat(viewStateWithoutLoading)
            .catchErrorJustReturn(.error)
    }
}
