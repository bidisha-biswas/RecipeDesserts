import UIKit

class MealViewController: UIViewController {

    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    var meal: Meal?
    var expandedSections: Set<Section> = []


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupCollectionView()
        setupDataSource()
        fetchMeal()
    }

    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(IngredientCell.self, forCellWithReuseIdentifier: IngredientCell.reuseIdentifier)
        collectionView.register(SectionTitleView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionTitleView.reuseIdentifier)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }

    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let sectionLayoutKind = Section(rawValue: sectionIndex)!
            return self.createSectionLayout(section: sectionLayoutKind)
        }
        return layout
    }

    func createSectionLayout(section: Section) -> NSCollectionLayoutSection {
        switch section {
        case .image:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.75))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            return section
        case .ingredients, .instructions:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]

            return section
        }
    }

    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch Section(rawValue: indexPath.section)! {
            case .image:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else {
                    fatalError("Cannot create new cell")
                }
                if let imageUrl = item.imageUrl {
                    cell.configure(with: imageUrl)
                }
                return cell
            case .ingredients, .instructions:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IngredientCell.reuseIdentifier, for: indexPath) as? IngredientCell else {
                    fatalError("Cannot create new cell")
                }
                cell.configure(with: item.text, measure: item.isInstruction ? "" : "")
                return cell
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }

            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionTitleView.reuseIdentifier, for: indexPath) as? SectionTitleView else {
                fatalError("Cannot create new header view")
            }

            let section = Section(rawValue: indexPath.section)!
            headerView.configure(with: section.title, isExpanded: self.expandedSections.contains(section))
            headerView.tapHandler = { [weak self] in
                self?.toggleSection(section)
            }

            return headerView
        }
    }

    func applySnapshot() {
        guard let meal = meal else { return }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)

        if let imageUrl = URL(string: meal.strMealThumb) {
            snapshot.appendItems([Item(text: "", isInstruction: false, imageUrl: imageUrl)], toSection: .image)
        }

        if expandedSections.contains(.ingredients) {
            var items: [Item] = []
            for (ingredient, measure) in zip(meal.ingredients, meal.measures) {
                if !ingredient.isEmpty || !measure.isEmpty {
                    items.append(Item(text: ingredient, isInstruction: false, imageUrl: nil))
                    items.append(Item(text: measure, isInstruction: false, imageUrl: nil))
                }
            }
            snapshot.appendItems(items, toSection: .ingredients)
        }

        if expandedSections.contains(.instructions) {
            let instructionItems = meal.strInstructions.split(separator: "\r\n").map { Item(text: String($0), isInstruction: true) }
            snapshot.appendItems(instructionItems, toSection: .instructions)
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func toggleSection(_ section: Section) {
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
        applySnapshot()
    }

    private func fetchMeal() {
        Task {
            do {
                let meal = try await NetworkManager.shared.fetchMealDetails()
                self.meal = meal
                applySnapshot()
            } catch {
                print("Error decoding meal: \(error)")
            }
        }
    }

}

extension MealViewController {
    enum Section: Int, CaseIterable {
        case image
        case ingredients
        case instructions

        var title: String {
            switch self {
            case .image: return "Image"
            case .ingredients: return "Ingredients"
            case .instructions: return "Instructions"
            }
        }
    }

    struct Item: Hashable {
        let id = UUID()
        let text: String
        let isInstruction: Bool
        let imageUrl: URL?

        init(text: String, isInstruction: Bool, imageUrl: URL? = nil) {
            self.text = text
            self.isInstruction = isInstruction
            self.imageUrl = imageUrl
        }
    }

}
