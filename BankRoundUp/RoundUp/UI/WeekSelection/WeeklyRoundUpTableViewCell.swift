import UIKit

final class WeeklyRoundUpTableViewCell: UITableViewCell {

    static let cellId = "weekCellId"

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "£1.58"
        return label
    }()

    private lazy var spacingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    lazy var weekStartDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "from 17th Jun 2018"
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupMainStackView(in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupMainStackView(in superView: UIView) {
        superView.addSubview(mainStackView)

        mainStackView.addArrangedSubview(weekStartDateLabel)
        mainStackView.addArrangedSubview(spacingView)
        mainStackView.addArrangedSubview(amountLabel)

        let safeArea = superView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mainStackView.centerYAnchor
                .constraint(equalTo: superView.centerYAnchor),
            mainStackView.leadingAnchor
                .constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor
                .constraint(equalTo: safeArea.trailingAnchor, constant: -16)
        ])
    }
}
