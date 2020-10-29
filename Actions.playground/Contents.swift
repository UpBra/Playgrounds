import Foundation
import UIKit

public typealias Action = () -> Void

private struct AssociatedKey {
    static var key = "EasyClosure_on"
}

public class Container<Host: AnyObject>: NSObject {
    public unowned let host: Host

    public init(host: Host) {
        self.host = host
    }

    // Keep all targets alive
    public var targets = [String: NSObject]()
}

public protocol EasyClosureAware: class {
    associatedtype EasyClosureAwareHostType: AnyObject
    var on: Container<EasyClosureAwareHostType> { get }
}

extension EasyClosureAware {
    public var on: Container<Self> {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKey.key) as? Container<Self> {
                return value
            }
            let value = Container(host: self)
            objc_setAssociatedObject(self, &AssociatedKey.key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            print("help")
            return value
        }
    }
}

extension NSObject: EasyClosureAware { }


public extension Container where Host: UIButton {

    func didTouchUpInside(_ action: @escaping Action) {
        let target = ButtonTarget(host: host, action: action)
        targets["\(host.hashValue)_didTouchUpInside"] = target
    }

    private class ButtonTarget: NSObject {
        var action: Action?

        init(host: UIButton, action: @escaping Action) {
            super.init()

            self.action = action
            host.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        }

        // MARK: - Action
        @objc func handleTap() {
            action?()
        }
    }
}


let button = UIButton()
button.on.didTouchUpInside {
    print("hi")
}

button.sendActions(for: .touchUpInside)
