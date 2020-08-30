//: Playground - noun: a place where people can play

import UIKit

let formatter = DateComponentsFormatter()
formatter.zeroFormattingBehavior = .pad
formatter.allowedUnits = [.hour, .minute, .second]
formatter.unitsStyle = .positional

let string = formatter.string(from: 10800)
