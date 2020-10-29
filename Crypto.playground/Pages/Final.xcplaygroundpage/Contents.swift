import Foundation
import CommonCrypto


let message = "hello, world"
let key = "starship"
let keyHex = "b9a365c4d2675d5fd8ec77672a2bc29474184c3805b550b987b630c83c200c9c"
let key64 = "Ym9vYmllcw=="
let anotherHex = "b9a36"

extension String {
	var testHexToBytes: [UInt8] {
		let result = stride(from: 0, to: count, by: 2).reduce(into: [UInt8]()) { (result, position) in
			guard let start = index(startIndex, offsetBy: position, limitedBy: endIndex) else { return }

			let end = index(start, offsetBy: 2, limitedBy: endIndex) ?? endIndex

			if let byte = UInt8(self[start..<end], radix: 16) {
				result.append(byte)
			}
		}

		return result
	}
}

extension StringProtocol {
	var hexToBytes: [UInt8] {
		var startIndex = self.startIndex
		return stride(from: 0, to: count, by: 2).compactMap { (stride) in
			let endIndex = index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
			defer { startIndex = endIndex }
			return UInt8(self[startIndex..<endIndex], radix: 16)
		}
	}
}


let myVersion = anotherHex.testHexToBytes
print(myVersion)
let theirVersion = anotherHex.hexToBytes
print(theirVersion)
print(myVersion == theirVersion)

enum HMAC {

	enum Kind {
		case text(String)
		case hex(String)
		case base64(String)

		var bytes: [UInt8] {
			switch self {
			case .text(let value):
				let result = value.utf8.map { UInt8($0) }

				return result

			case .hex(let value):
				let result = value.hexToBytes

				return result

			case .base64(let value):
				let data = Data(base64Encoded: value) ?? Data()
				let result = [UInt8](data)

				return result
			}
		}
	}

	enum Variant {
		case md5, sha1, sha224, sha256, sha384, sha512

		var algorithm: CCHmacAlgorithm {
			var result: Int = 0
			switch self {
			case .md5: result = kCCHmacAlgMD5
			case .sha1: result = kCCHmacAlgSHA1
			case .sha224: result = kCCHmacAlgSHA224
			case .sha256: result = kCCHmacAlgSHA256
			case .sha384: result = kCCHmacAlgSHA384
			case .sha512: result = kCCHmacAlgSHA512
			}
			return CCHmacAlgorithm(result)
		}

		var digestLength: Int {
			var result: Int32 = 0
			switch self {
			case .md5: result = CC_MD5_DIGEST_LENGTH
			case .sha1: result = CC_SHA1_DIGEST_LENGTH
			case .sha224: result = CC_SHA224_DIGEST_LENGTH
			case .sha256: result = CC_SHA256_DIGEST_LENGTH
			case .sha384: result = CC_SHA384_DIGEST_LENGTH
			case .sha512: result = CC_SHA512_DIGEST_LENGTH
			}
			return Int(result)
		}

		func hash(input: HMAC.Kind, key: HMAC.Kind) -> String {
			let inputBytes = input.bytes
			let inputLength = inputBytes.count
			let keyBytes = key.bytes
			let keyLength = keyBytes.count
			let resultBytes = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)

			CCHmac(algorithm, keyBytes, keyLength, inputBytes, inputLength, resultBytes)

			let result = stringFromResult(result: resultBytes, length: digestLength)

			resultBytes.deallocate()

			return result
		}

		private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
			var hash = ""

			for i in 0..<length {
				hash = hash.appendingFormat("%02x", result[i])
			}

			return hash
		}
	}
}

let textTest = HMAC.Variant.sha256.hash(input: .text(message), key: .text(key))
let isValid = textTest == "20580af62f7df4a52c7d88c066db95ad506c3149d5869d33695b751aa895bc37"
print("textTest: \(isValid)")

let hexTest = HMAC.Variant.sha256.hash(input: .text(message), key: .hex(keyHex))
let hexIsValid = hexTest == "9952886b838d7f1b1ca6501d6ae5e1a72d5c37d45cea6c3003ff4c627c1b55ca"
print("hexTest: \(hexIsValid)")

let test64 = HMAC.Variant.sha256.hash(input: .text(message), key: .base64(key64))
let test64Valid = test64 == "5896dc561e7f22ab52c22744143e848ebe41d662cecf178beb8ff64c86f6b8b8"
print("64Test: \(test64Valid)")
