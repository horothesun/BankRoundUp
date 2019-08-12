import UIKit

final class EmptyWeeklyRoundUpsTableViewDataSource: NSObject {
    static let cellId = "cellId"
    private static let message = "No weekly round-ups available 💳"
}

extension EmptyWeeklyRoundUpsTableViewDataSource: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {

        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: EmptyWeeklyRoundUpsTableViewDataSource.cellId,
            for: indexPath)
        cell.textLabel?.text = EmptyWeeklyRoundUpsTableViewDataSource.message
        cell.selectionStyle = .none
        return cell
    }
}
