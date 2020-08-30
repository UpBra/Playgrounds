//: [Previous](@previous)

import Foundation
import UIKit
import PlaygroundSupport

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

struct Designer<T> {
	typealias Closure = (T) -> Void

	let design: Closure
}

class DesignController<T> {

	var design: Design

	init(design: Design = Design.platformDesign) {
		self.design = design
	}

	func addDesign(_ design: Design = Design.platformDesign, block: @escaping Designer<T>.Closure) {
		let wrapper = Designer(design: block)
		designs[design] = wrapper
	}

	func applyDesign(_ object: T) {
		guard let designer = designs[design] else { return }

		designer.design(object)
	}

	// MARK: - Private

	private var designs = [Design: Designer<T>]()
}

class View: UIView {

	private let titleLabel = UILabel()
	private let detailLabel = UILabel()
	private let stackView = UIStackView()
	private let designController = DesignController<View>()

	override init(frame: CGRect) {
		super.init(frame: frame)

		stackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stackView)
		stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(detailLabel)

		designController.addDesign { (view) in

		}

		designController.addDesign(.mobile) { (view) in
			view.titleLabel.textColor = .blue
		}

		designController.addDesign(.connected) { (view) in
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

		designController.applyDesign(self)
	}
}

class ViewController: UIViewController {

	override func loadView() {
		self.view = View()
	}
}

PlaygroundPage.current.liveView = ViewController()


//: [Next](@next)
