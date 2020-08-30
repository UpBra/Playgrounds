//: [Previous](@previous)

import UIKit


struct MyViewProperties {
	let title: String
	let detail: String
	let isWinner: Bool
}

typealias UIViewStyle<T: UIView> = (T)-> Void


class MyView: UIView {

	let titleLabel = UILabel()
	let detailLabel = UILabel()
	private let stackView = UIStackView()
	private var design: Design = .mobile

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func render(_ properties: MyViewProperties?) {
		titleLabel.text = properties?.title
		detailLabel.text = properties?.detail
	}
}


// MARK: - Design

extension MyView {

	enum Design {
		case mobile
		case connected
	}

	struct DesignModel {
		let titleStyle: UIViewStyle<UILabel>
		let detailStyle: UIViewStyle<UILabel>
		let stackViewStyle: UIViewStyle<UIStackView>
		let winningStyle: UIViewStyle<MyView>
	}
}

//: [Next](@next)
