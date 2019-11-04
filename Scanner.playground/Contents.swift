import UIKit


let variable = "http://WWW.google.com/percent~encode.me^"


extension NSCharacterSet {

	var characters: [String] {
		/// An array to hold all the found characters
		var characters: [String] = []

		/// Iterate over the 17 Unicode planes (0..16)
		for plane:UInt8 in 0..<17 {
			/// Iterating over all potential code points of each plane could be expensive as
			/// there can be as many as 2^16 code points per plane. Therefore, only search
			/// through a plane that has a character within the set.
			if self.hasMemberInPlane(plane) {

				/// Define the lower end of the plane (i.e. U+FFFF for beginning of Plane 0)
				let planeStart = UInt32(plane) << 16
				/// Define the lower end of the next plane (i.e. U+1FFFF for beginning of
				/// Plane 1)
				let nextPlaneStart = (UInt32(plane) + 1) << 16

				/// Iterate over all possible UTF32 characters from the beginning of the
				/// current plane until the next plane.
				for char: UTF32Char in planeStart..<nextPlaneStart {

					/// Test if the character being iterated over is part of this
					/// `NSCharacterSet`
					if self.longCharacterIsMember(char) {

						/// Convert `UTF32Char` (a typealiased `UInt32`) into a
						/// `UnicodeScalar`. Otherwise, converting `UTF32Char` directly
						/// to `String` would turn it into a decimal representation of
						/// the code point, not the character.
						if let unicodeCharacter = UnicodeScalar(char) {
							characters.append(String(unicodeCharacter))
						}
					}
				}
			}
		}
		return characters
	}
}


extension CharacterSet {
	func containsUnicodeScalars(of character: Character) -> Bool {
		return character.unicodeScalars.allSatisfy(contains(_:))
	}
}


extension String {

	func test(withAllowedCharacters set: CharacterSet) -> String {
		guard var encoded = addingPercentEncoding(withAllowedCharacters: set) else { return self }
		guard let expression = try? NSRegularExpression(pattern: "%..", options: .caseInsensitive) else { return encoded }

		let ns = encoded as NSString

		let something = expression.matches(in: encoded, options: [], range: NSRange(location: 0, length: encoded.count)).map { ns.substring(with: $0.range) }

		something.forEach {
			encoded = encoded.replacingOccurrences(of: $0, with: $0.lowercased())
		}

		print(encoded)

		return encoded
	}
}


extension String {

	func addingLowercasePercentEncoding(withAllowedCharacters set: CharacterSet) -> String {
//		var result = [String.Element]()
//
//		for character in self {
//			guard !set.containsUnicodeScalars(of: character), let asciiValue = character.asciiValue else { result.append(character); continue }
////			guard let asciiValue = character.asciiValue, !set.contains(Unicode.Scalar(asciiValue)) else { result.append(character); continue }
//
//			let percentEncode = "%" + String(asciiValue, radix: 16, uppercase: false)
//			result.append(contentsOf: percentEncode)
//		}

		let reduced = reduce(into: [String.Element]()) { (result, element) in
			guard !element.unicodeScalars.allSatisfy(set.contains(_:)) else { result.append(element); return }
			guard let asciiValue = element.asciiValue else { result.append(element); return }

			let percentEncoded = "%" + String(asciiValue, radix: 16, uppercase: false)
			result.append(contentsOf: percentEncoded)
		}

		let text = String(reduced)

		return text
	}
}

let set = CharacterSet.urlPathAllowed
let lowercase = variable.addingLowercasePercentEncoding(withAllowedCharacters: set)
let apple = variable.addingPercentEncoding(withAllowedCharacters: set)

let stupid = variable.test(withAllowedCharacters: set)

let space = " "
let ascii = space.compactMap { $0.asciiValue }
let hex = ascii.map { String($0, radix: 16, uppercase: false) }
print(hex)

print((NSCharacterSet.urlPathAllowed as NSCharacterSet).characters)

let colon = Character(":")
if let colonAscii = colon.asciiValue {
	let scalar = Unicode.Scalar(colonAscii)
	print(scalar)
	print(set.containsUnicodeScalars(of: colon))
}


let uh = variable.unicodeScalars.map { "\($0)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)?.lowercased() }
print(uh)

