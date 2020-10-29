//: [Previous](@previous)

import CommonCrypto
import Foundation


var str = "something"
var key = "helloworld123"


extension Data {

	var hexString: String {
		let components = map { String(format:"%02x", UInt8($0)) }
		let result = components.joined()

		return result
	}
}


protocol HashGenerator {
	func sha256(_ value: String) -> String?
}


struct Test1: HashGenerator {

	func sha256(_ value: String) -> String? {
		guard let stringData = value.data(using: String.Encoding.utf8) else { return nil }

		let data = digest(input: stringData as NSData) as Data
		let result = data.hexString

		return result
	}

	private func digest(input : NSData) -> NSData {
		let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
		var hash = [UInt8](repeating: 0, count: digestLength)

		CC_SHA256(input.bytes, UInt32(input.length), &hash)

		return NSData(bytes: hash, length: digestLength)
	}
}


struct Test2: HashGenerator {

	func sha256(_ value: String) -> String? {
		guard let stringData = value.data(using: .utf8) else { return nil }

		let hash = digest(input: stringData)

		return hash.hexString
	}

	private func digest(input: Data) -> Data {
		let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
		var hash = [UInt8](repeating: 0, count: digestLength)

		input.withUnsafeBytes { b in
			CC_SHA256(b.baseAddress, UInt32(input.count), &hash)
		}

		return Data(bytes: hash, count: digestLength)
	}
}


struct Test3: HashGenerator {

	let key: String

	func sha256(_ value: String) -> String? {
		guard let stringData = value.data(using: .utf8) else { return nil }
		guard let keyData = key.data(using: .utf8) else { return nil }

		let hash = digest(message: stringData, key: keyData)

		return hash.hexString
	}

	private func digest(message: Data, key: Data) -> Data {
		let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
		var hash = [UInt8](repeating: 0, count: digestLength)

		message.withUnsafeBytes { m in
			key.withUnsafeBytes { k in
				CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), k.baseAddress, key.count, m.baseAddress, message.count, &hash)
			}
		}

		return Data(bytes: hash, count: digestLength)
	}
}


let test1 = Test1().sha256(str)

if let test = test1 {
	print(test)
}

let test2 = Test2().sha256(str)

if let test2 = test2 {
	print(test2)
}

let test3 = Test3(key: key)

if let test3 = test3.sha256(str) {
	print(test3)
}



//: [Next](@next)
