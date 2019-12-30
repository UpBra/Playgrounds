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


extension FixedWidthInteger {

	var binaryRepresentation: String {
		let result = String.binaryRepresentation(of: self)

		return result
	}
}

let sasha = RGBA32(red: 130, green: 130, blue: 130, alpha: 1)
let character = Character("f")
let decimal = character.utf8.map { $0 }
let firstCharacter = decimal.first!

print("sasha.red:\t\t\t", sasha.redComponent.binaryRepresentation)
print("character.a:\t\t", firstCharacter.binaryRepresentation)

// clear out the 2 least significant digits from our byte
let maeby = (sasha.redComponent >> 2) << 2

// clear out the 6 most significant digits from our character byte
let firstBits = (firstCharacter << 6) >> 6

// now an OR operation will take the 6 most signficant bits from our color byte and the 2 least significant bits from our character byte
let newRed = maeby | firstBits
print("newRed:\t\t\t\t", newRed.binaryRepresentation)


let secondBits = (firstCharacter << 4) >> 6
var newGreen = (sasha.greenComponent >> 2) << 2
newGreen |= secondBits
print("newGreen:\t\t\t", newGreen.binaryRepresentation)


let thirdBits = (firstCharacter << 2) >> 6
var newBlue = (sasha.blueComponent >> 2) << 2
newBlue |= thirdBits
print("newBlue:\t\t\t", newBlue.binaryRepresentation)


let fourthBits = firstCharacter >> 6
var newAlpha = (sasha.alphaComponent >> 2) << 2
newAlpha |= fourthBits
print("newAlpha:\t\t\t", newAlpha.binaryRepresentation)


// MARK: - Given an RGBA lets get a character out of it.

extension RGBA32 {

	var characterByte: UInt8 {
		var byte = UInt8(0)

		let red = (redComponent << 6) >> 6
		let green = (greenComponent << 6) >> 6
		let blue = (blueComponent << 6) >> 6
		let alpha = (alphaComponent << 6) >> 6

		byte |= alpha
		byte <<= 2

		byte |= blue
		byte <<= 2

		byte |= green
		byte <<= 2

		byte |= red

		return byte
	}

	func encoded(withByte byte: UInt8) -> RGBA32 {
		let firstBits = (byte << 6) >> 6
		var newRed = (redComponent >> 2) << 2
		newRed |= firstBits

		let secondBits = (byte << 4) >> 6
		var newGreen = (greenComponent >> 2) << 2
		newGreen |= secondBits

		let thirdBits = (byte << 2) >> 6
		var newBlue = (blueComponent >> 2) << 2
		newBlue |= thirdBits

		let fourthBits = byte >> 6
		var newAlpha = (alphaComponent >> 2) << 2
		newAlpha |= fourthBits

		let result = RGBA32(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)

		return result
	}
}

let encodedColor = RGBA32(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
let theEncodedByte = encodedColor.characterByte
print("character in sasha: ", theEncodedByte.binaryRepresentation)

let data = Data(bytes: [theEncodedByte], count: 1)
let string = String(data: data, encoding: .utf8)
print(string)


let anotherTest = sasha.encoded(withByte: firstCharacter)
print("anotherTest:\t\t", anotherTest.characterByte.binaryRepresentation)
let anotherData = Data(bytes: [anotherTest.characterByte], count: 1)
let anotherString = String(data: anotherData, encoding: .utf8)
print(anotherString)


// MARK: - Given a string of characters - inject them into RGBA

let testString = "Hello, World 🤷‍♂️"
let testBytes = testString.utf8.map { $0 }
var colors = [RGBA32]()

for byte in testBytes {
	let red = RGBA32.red
	let encodedRed = red.encoded(withByte: byte)
	colors.append(encodedRed)
}

let decodedBytes = colors.map { $0.characterByte }
let decodedData = Data(bytes: decodedBytes, count: decodedBytes.count)
let decodedString = String(data: decodedData, encoding: .utf8)
print(decodedString)

// MARK: -
