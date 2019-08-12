# Round-Up
Round-up feature based on open banking APIs.

## Flow

![Flow](https://github.com/horothesun/BankRoundUp/blob/master/images/flow.png)

## Project setup

### Dependencies
`run pod install` to install the project's dependencies and generate Xcode's workspace.

### Access token
Currently defined in `Common/Config`, shouldn't be stored in the codebase for security reasons, but it'd be shared in other ways.


## Solution notes

### Clean Architecture
Feature first (i.e. `Round Up`), then layers. Layer boundaries have been implemented using protocols.
![Xcode Project](https://github.com/horothesun/BankRoundUp/blob/master/images/xcodeProject.png)

### Full-Rx
- ViewController exposes `var viewEvents: Observable<ViewEvent>` to its
presenter through a protocol
- the presenter exposes `var viewState: Driver<ViewState>` to its associated
ViewController, which it then uses to reactively render itself accordingly.

### UI
- `RoundUp/UI/RoundUpViewController`: main screen with "New Goal" button
- `RoundUp/UI/WeekSelection/WeekSelectionViewController`: displays the list of round-ups per week (amount and starting day of the week) and allows to deposit the selected round-up amount to the newly created savings goal.

### TDD
Code developed with _TDD_ (Quick, Nimble and RxTest)
- `Common/Array+GroupBy`: group `Array` elements by their key, given a `keySelector` function from `Element` to `Key`
- `Common/Date+StartOfWeek`: getting the start of week date
- `RoundUp/Gateway/TransactionsFetchingGateway`.Response: building response `struct` from JSON `Data`
- `RoundUp/BusinessLogic/TransactionsFetchingBusinessLogic`: fetching transactions with injectable gateway.
- `RoundUp/BusinessLogic/WeeklyRoundUpsBusinessLogic`: getting the weekly round-ups with injectable `TransactionsFetchingBusinessLogic`
- `Tests/Utils/Nimble+RxTest`: custom Nimble predicates for cleaner RxSwift testing.

### Storyboard vs code-base UI
Storyboards are very powerful, but I think they don't scale well with the number of developers due to merge conflicts. I prefer to leverage autolayout programmatically, creating a quick prototyping loop through Playgrounds and their Live Views.

### Swift `Decodable` protocol used to decode JSON responses from
- `GET api/v1/transactions/` (`RoundUp/Entity/Transaction`)
- `PUT api/v1/savings-goals/{savingsGoalUid}` (`TransactionsFetchingGateway.Response`)
- `PUT api/v1/savings-goals/{savingsGoalUid}/add-money/{transferUid}` (`SavingsGoalDepositGateway.Response`)

### Improvements
- unit test coverage (especially presenters)
- UI could be easily _unit tested_ injecting stubbed presenters, because the boundary's just a stream of `ViewState`s.