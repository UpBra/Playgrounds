import UIKit

struct RGBA32: Equatable {
    private var color: UInt32

    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }

    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }

    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }

    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let red   = UInt32(red)
        let green = UInt32(green)
        let blue  = UInt32(blue)
        let alpha = UInt32(alpha)
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }

    static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
    static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
    static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
    static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
    static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
    static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
    static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
    static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)

    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
}


extension String {

    static func binaryRepresentation<F: FixedWidthInteger>(of val: F) -> String {
        let binaryString = String(val, radix: 2)

        if val.leadingZeroBitCount > 0 {
            return String(repeating: "0", count: val.leadingZeroBitCount) + binaryString
        }

        return binaryString
    }
}


enum Bit: UInt8, CustomStringConvertible {
    case zero, one

    var description: String {
        switch self {
        case .one:
            return "1"
        case .zero:
            return "0"
        }
    }
}


func bits(fromByte byte: UInt8) -> [Bit] {
    var byte = byte
    var bits = [Bit](repeating: .zero, count: 8)
	for i in 0..<8 {
        let currentBit = byte & 0x01
        if currentBit != 0 {
            bits[i] = .one
        }

        byte >>= 1
    }

	let reversed = Array(bits.reversed())

    return reversed
}


let sasha = RGBA32(red: 130, green: 130, blue: 130, alpha: 1)
let character = Character("a")
let decimal = character.utf8.map { $0 }
let firstCharacter = decimal.first!

print("130 bits:\t\t", String.binaryRepresentation(of: sasha.redComponent))
print("the a bits:\t\t", String.binaryRepresentation(of: firstCharacter))

// clear out the 2 least significat digits from our byte
let maeby = (sasha.redComponent >> 2) << 2

// clear out the 6 most significant digits from our character byte
let firstBits = (firstCharacter << 6) >> 6

// now an OR operation will take the 6 most signficant bits from our color byte and the 2 least significant bits from our character byte
let result = maeby | firstBits
print("result:\t\t\t", String.binaryRepresentation(of: result))


/*
	So. I can take take bits from a character and inject them into the LSB of my color byte
*/


// MARK: - Given an RGBA lets get a character out of it.

// MARK: - Given a string of characters - inject them into RGBA

// MARK: -
