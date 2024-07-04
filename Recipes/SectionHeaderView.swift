import UIKit

class SectionTitleView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderView"

    private let label = UILabel()
    private let button = UIButton(type: .system)
    var tapHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(button)

        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),

            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String, isExpanded: Bool) {
        label.text = title
        button.setTitle(isExpanded ? "Collapse" : "Expand", for: .normal)
    }

    @objc private func buttonTapped() {
        tapHandler?()
    }
}
