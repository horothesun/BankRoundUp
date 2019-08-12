import UIKit

final class NonEmptyWeeklyRoundUpsTableViewDataSource: NSObject {

    private let displayModels: [WeeklyRoundUpDisplayModel]

    init(displayModels: [WeeklyRoundUpDisplayModel]) {
        self.displayModels = displayModels
    }
}

extension NonEmptyWeeklyRoundUpsTableViewDataSource: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {

        return displayModels.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: WeeklyRoundUpTableViewCell.cellId,
            for: indexPath) as! WeeklyRoundUpTableViewCell
        let displayModel = displayModels[indexPath.row]
        configure(cell: cell, displayModel: displayModel)
        return cell
    }

    private func configure(
        cell: WeeklyRoundUpTableViewCell,
        displayModel: WeeklyRoundUpDisplayModel) {

        cell.amountLabel.text = displayModel.amount
        cell.weekStartDateLabel.text = displayModel.fromWeekStart
    }
}

