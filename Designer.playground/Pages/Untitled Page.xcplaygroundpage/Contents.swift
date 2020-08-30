import UIKit
import PlaygroundSupport

typealias DesignClosure<T> = (T) -> Void

enum Design {
	case mobile
	case connected

	static var platformDesign: Design {
		#if os(iOS)
		return .mobile
		#else
		return .connected
		#endif
	}
}

class Designer<T> {

	var design: Design

	init(design: Design = Design.platformDesign) {
		self.design = design
	}

	func addDesign(_ design: Design, designer: @escaping DesignClosure<T>) {
		designs[design] = designer
	}

	func applyDesign(_ object: T) {
		guard let designer = designs[design] else { return }

		designer(object)
	}

	// MARK: - Private

	private var designs = [Design: DesignClosure<T>]()
}

class View: UIView {

	private let titleLabel = UILabel()
	private let detailLabel = UILabel()
	private let stackView = UIStackView()
	private let designer = Designer<View>()

	override init(frame: CGRect) {
		super.init(frame: frame)

		stackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stackView)
		stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(detailLabel)

		designer.addDesign(.mobile) { (view) in
			view.titleLabel.textColor = .red
		}

		designer.addDesign(.connected) { (view) in
			view.titleLabel.textColor = .green
		}

		renderProperties()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func renderProperties() {
		titleLabel.text = "hello"
		detailLabel.text = "world"

		designer.applyDesign(self)
	}
}

class ViewController: UIViewController {

	override func loadView() {
		self.view = View()
	}
}

PlaygroundPage.current.liveView = ViewController()
