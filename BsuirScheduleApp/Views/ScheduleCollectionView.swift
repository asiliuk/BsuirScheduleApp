//
//  ScheduleCollectionView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 3/8/20.
//  Copyright © 2020 Saute. All rights reserved.
//

import Foundation
import SwiftUI

final class ScheduleCollectionView: UIViewRepresentable {

    let weeks: [[Day]]
    init(weeks: [[Day]]) { self.weeks = weeks }

    typealias DataSource = UICollectionViewDiffableDataSource<Int, Day>

    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = UICollectionView(
            frame: UIScreen.main.bounds,
            collectionViewLayout: collectionLayout()
        )
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.alwaysBounceVertical = true

        context.coordinator.dataSource = dataSource(for: collectionView)

        return collectionView
    }

    func updateUIView(_ collectionView: UICollectionView, context: Context) {
        context.coordinator.dataSource!.apply(weeksSnapshot(), animatingDifferences: true)
    }

    final class Coordinator {
        var dataSource: DataSource?
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
}

private extension ScheduleCollectionView {

    func collectionLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (index, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(250))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: environment.columns)
            group.interItemSpacing = .fixed(8)

            return NSCollectionLayoutSection(group: group)
        }
    }

    func dataSource(for collectionView: UICollectionView) -> DataSource {
        collectionView.register(DayScheduleCollectionCell.self, forCellWithReuseIdentifier: DayScheduleCollectionCell.identifier)
        return DataSource(collectionView: collectionView) { (collectionView, indexPath, day)  -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DayScheduleCollectionCell.identifier,
                for: indexPath
            ) as! DayScheduleCollectionCell
            cell.day = day
            return cell
        }
    }

    func weeksSnapshot() -> NSDiffableDataSourceSnapshot<Int, Day> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Day>()
        let enumerated = weeks.enumerated()
        snapshot.appendSections(enumerated.map { $0.offset })
        enumerated.forEach { snapshot.appendItems($0.element, toSection: $0.offset) }
        return snapshot
    }
}

private extension NSCollectionLayoutEnvironment {

    var columns: Int {
        switch container.contentSize.width {
        case ..<500: return 1
        case 500..<1000: return 2
        case 1000..<1500: return 3
        default: return 4
        }
    }
}

private final class DayScheduleCollectionCell: UICollectionViewCell {

    static let identifier = String(describing: self)

    var day: Day? = nil {
        didSet {
            guard oldValue != day else { return }
            stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            guard let value = day else { return }
            title.text = value.title.capitalized
            value.pairs
                .map {
                    PairCell(pair: $0)
                        .padding(EdgeInsets(
                            top: 4,
                            leading: 8,
                            bottom: 4,
                            trailing: 8
                        ))
                }
                .map { UIHostingController(rootView: $0).view }
                .forEach(stack.addArrangedSubview)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mutating(title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)) { $0.priority = .defaultHigh },
        ])

        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let title = mutating(UILabel()) {
        $0.font = .preferredFont(forTextStyle: .title2)
    }

    private let stack = mutating(UIStackView()) {
        $0.axis = .vertical
        $0.spacing = 2
    }
}

func mutating<Object>(_ object: Object, _ transform: (inout Object) -> Void) -> Object {
    var copy = object
    transform(&copy)
    return copy
}
