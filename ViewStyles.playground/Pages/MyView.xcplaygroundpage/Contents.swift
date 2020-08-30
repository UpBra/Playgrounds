import UIKit

struct MyViewProperties {
	let title: String
	let detail: String
	let isWinner: Bool
}

class MyView: UIView {

	let titleLabel = UILabel()
	let detailLabel = UILabel()
	private let stackView = UIStackView()
	private var style: Style = .mobile

	override init(frame: CGRect) {
		super.init(frame: frame)

		apply(style)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func render(_ properties: MyViewProperties?) {
		titleLabel.text = properties?.title
		detailLabel.text = properties?.detail

		apply(style, properties: properties)
	}
}

extension MyView {

	enum Style {
		case mobile
		case connected
	}

	convenience init(style: Style) {
		self.init()

		self.style = style
	}

	func buildUserInterface() {
		addSubview(stackView)

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(detailLabel)
	}

	func apply(_ style: Style, properties: MyViewProperties? = nil) {
		applyCommonStyle()

		switch style {
		case .connected:
			applyConnectedStyle(properties: properties)
		case .mobile:
			applyMobileStyle(properties: properties)
		}
	}

	private func applyCommonStyle() {
		stackView.frame = bounds
		stackView.axis = .horizontal
	}

	private func applyMobileStyle(properties: MyViewProperties? = nil) {
		let isWinner = properties?.isWinner ?? false

		let titleFont = isWinner ? UIFont.boldSystemFont(ofSize: 13) : UIFont.systemFont(ofSize: 12)
		titleLabel.font = titleFont

		let detailFont = isWinner ? UIFont.boldSystemFont(ofSize: 10) : UIFont.systemFont(ofSize: 10)
		detailLabel.font = detailFont

		stackView.spacing = 3
	}

	private func applyConnectedStyle(properties: MyViewProperties? = nil) {
		let isWinner = properties?.isWinner ?? false

		// TODO: https://jiraprod.turner.com/browse/MI-6258
		#if os(tvOS)
		let titleFont = isWinner ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
		titleLabel.font = titleFont
		#endif

		let detailFont = isWinner ? UIFont.boldSystemFont(ofSize: 12) : UIFont.systemFont(ofSize: 12)
		detailLabel.font = detailFont

		stackView.spacing = 33
	}
}
