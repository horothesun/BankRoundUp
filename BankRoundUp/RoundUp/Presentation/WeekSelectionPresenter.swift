import RxSwift
import RxCocoa

struct WeeklyRoundUpDisplayModel {
    let fromWeekStart: String
    let amount: String
}

enum WeekSelectionViewState {
    case loadingWeeklyRoundUps
    case errorLoadingWeeklyRoundUps
    case noWeeklyRoundUps
    case readyForSelection(weeklyRoundUpDisplayModels: [WeeklyRoundUpDisplayModel])
    case weeklyRoundUpSelected(rowIndex: Int)
    case saving
    case successfullySaved
    case errorSaving
}

protocol WeekSelectionPresenterProtocol {
    var viewState: Driver<WeekSelectionViewState> { get }
}

final class WeekSelectionPresenter {

    private lazy var currencyFormatter: NumberFormatter = {
        let result = NumberFormatter()
        result.numberStyle = .currency
        result.currencySymbol = "£"
        return result
    }()

    private lazy var dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .medium
        result.timeStyle = .none
        return result
    }()

    private let weeklyRoundUpsBusinessLogic: WeeklyRoundUpsBusinessLogicProtocol
    private let savingsGoalDepositBusinessLogic: SavingsGoalDepositBusinessLogicProtocol
    private weak var view: WeekSelectionViewProtocol?

    init(
        weeklyRoundUpsBusinessLogic: WeeklyRoundUpsBusinessLogicProtocol
            = WeeklyRoundUpsBusinessLogic(),
        savingsGoalDepositBusinessLogic: SavingsGoalDepositBusinessLogicProtocol
            = SavingsGoalDepositBusinessLogic(),
        view: WeekSelectionViewProtocol) {

        self.weeklyRoundUpsBusinessLogic = weeklyRoundUpsBusinessLogic
        self.savingsGoalDepositBusinessLogic = savingsGoalDepositBusinessLogic
        self.view = view
    }
}

extension WeekSelectionPresenter: WeekSelectionPresenterProtocol {

    var viewState: Driver<WeekSelectionViewState> {

        guard let view = view else { return .never() }

        return view.viewEvents
            .flatMap { [weak self] viewEvent -> Observable<WeekSelectionViewState> in
                guard let nonNilSelf = self else { return .never() }
                let backgroundScheduler =
                    ConcurrentDispatchQueueScheduler(qos: .background)

                switch viewEvent {
                case .refresh:
                    return nonNilSelf.viewStateOnRefresh
                        .subscribeOn(backgroundScheduler)
                case .select(let weekIndex):
                    return nonNilSelf.viewStateOnSelect(weekIndex)
                case .save(let goalUid, let weekIndex):
                    return nonNilSelf.viewStateOnSave(goalUid, weekIndex)
                        .subscribeOn(backgroundScheduler)
                }
            }
            .asDriver(onErrorJustReturn: .errorLoadingWeeklyRoundUps)
    }

    private var viewStateOnRefresh: Observable<WeekSelectionViewState> {

        let viewStateWithoutLoading = weeklyRoundUpsBusinessLogic
            .weeklyRoundUps()
            .map { [weak self] weeklyRoundUps -> WeekSelectionViewState in
                guard let nonNilSelf = self else {
                    return .errorLoadingWeeklyRoundUps
                }
                let displayModels = weeklyRoundUps
                    .map(nonNilSelf.weeklyRoundUpDisplayModel(from:))
                return .readyForSelection(weeklyRoundUpDisplayModels: displayModels)
            }
        return Observable<WeekSelectionViewState>
            .just(.loadingWeeklyRoundUps)
            .concat(viewStateWithoutLoading)
            .catchErrorJustReturn(.errorLoadingWeeklyRoundUps)
    }

    private func weeklyRoundUpDisplayModel(
        from weeklyRoundUp: WeeklyRoundUp) -> WeeklyRoundUpDisplayModel {

        let formattedStartOfWeek = dateFormatter
            .string(from: weeklyRoundUp.startOfWeek)
        let fromWeekStart = "from \(formattedStartOfWeek)"
        let formattedAmount = currencyFormatter
            .string(from: NSNumber(value: weeklyRoundUp.amount)) ?? "???"
        return .init(fromWeekStart: fromWeekStart, amount: formattedAmount)
    }

    private func viewStateOnSelect(
        _ weekIndex: Int) -> Observable<WeekSelectionViewState> {

        return .just(.weeklyRoundUpSelected(rowIndex: weekIndex))
    }

    private func viewStateOnSave(
        _ goalUid: UUID,
        _ weekIndex: Int) -> Observable<WeekSelectionViewState> {

        guard let weeklyRoundUps =
            weeklyRoundUpsBusinessLogic.lastWeeklyRoundUpsRetrieved,
            weekIndex >= 0,
            weekIndex < weeklyRoundUps.count else {
                return .just(.errorSaving)
        }
        let weeklyRoundUpToSave = weeklyRoundUps[weekIndex]
        let viewStateWithoutSaving = savingsGoalDepositBusinessLogic
            .add(amount: weeklyRoundUpToSave.amount, toGoal: goalUid)
            .map { transferUid -> WeekSelectionViewState in
                .successfullySaved
            }
        return Observable<WeekSelectionViewState>
            .just(.saving)
            .concat(viewStateWithoutSaving)
            .catchErrorJustReturn(.errorSaving)
    }
}
