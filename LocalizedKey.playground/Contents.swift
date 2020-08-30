//: Playground - noun: a place where people can play

import UIKit

struct LocalizedKey: RawRepresentable {
    typealias RawValue = String

    var rawValue: RawValue
    var comment: String = ""

    init(rawValue: RawValue) { self.rawValue = rawValue }
    init(rawValue: RawValue, comment: String = "") {
        self.init(rawValue: rawValue)
        self.comment = comment
    }
}

extension LocalizedKey {

    var localizedString: String? {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}


/// ExampleViewController.swift
/// Copyright All Things For Eternity

class ExampleViewController: UIViewController {

    @IBOutlet var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        cancelButton.setTitle(LocalizedKey.ExampleViewController.CancelButton.localizedString, for: .normal)
    }
}

extension LocalizedKey {

    enum ExampleViewController {
        static let CancelButton = LocalizedKey(rawValue: "cancel")
    }
}
