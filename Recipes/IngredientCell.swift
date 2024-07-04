import UIKit

class IngredientCell: UICollectionViewCell {
    static let reuseIdentifier = "IngredientCell"

    private let ingredientLabel = UILabel()
    private let measureLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = UIStackView(arrangedSubviews: [ingredientLabel, measureLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with ingredient: String, measure: String) {
        ingredientLabel.text = ingredient
        measureLabel.text = measure
    }
}
