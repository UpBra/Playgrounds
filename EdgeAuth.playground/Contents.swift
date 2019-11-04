import UIKit
import CommonCrypto


enum Crypto {

	struct HMAC {
		let message: String
		let key: String
		let algorithm: Algorithm
	}
}


// MARK: - Crypto+HMAC

extension Crypto.HMAC {

	var hash: String {
		let messageBytes: [UInt8] = message.toBytes()
		let keyBytes: [UInt8] = key.toBytes()
		var data = Data(bytes: messageBytes, count: messageBytes.count)
		var hmac = [UInt8](repeating: 0, count: algorithm.digestLength)

		CCHmac(algorithm.ccAlgorithm, keyBytes, keyBytes.count, &data, data.count, &hmac)

		let result = Data(bytes: hmac, count: hmac.count)

		return result.base64EncodedString()
	}

	enum Algorithm {
		case md5, sha1, sha224, sha256, sha384, sha512

		var ccAlgorithm: CCHmacAlgorithm {
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
			var result: CInt = 0

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
	}
}

extension Data {

	func toBytes<T: ExpressibleByIntegerLiteral>() -> [T] {
		var bytes = Array<T>(repeating: 0, count: count)
		(self as NSData).getBytes(&bytes, length: count * MemoryLayout<T>.size)

		return bytes
	}
}

extension String {

	func toBytes<T: ExpressibleByIntegerLiteral>() -> [T] {
		guard let stringData = data(using: .utf8) else { return [] }

		return stringData.toBytes()
	}
}


struct HMACTokenProvider {

	typealias Token = String

	// MARK: Properties

	let message: String
	let key: String
}


// MARK: - Internal

extension HMACTokenProvider {

	func generateToken() -> Token {
		var newToken: String = ""

		let endTime = Date().addingTimeInterval(Constants.tokenDuration).timeIntervalSince1970
		newToken.append("exp=\(endTime)\(Constants.delimeter)")

		var hashSource = newToken

		// This is equivalent to checking if the string we passed in is a url or not
		// Might need to change this
		if let message = UTF8EncodedString(string: message) {
			hashSource.append("url=\(message.data)")
		}

		let hmac = Crypto.HMAC(message: hashSource, key: key, algorithm: .sha1)

		newToken.append("hmac=\(hmac.hash)\(Constants.delimeter)")

		return newToken
	}
}


// MARK: - Constants

extension HMACTokenProvider {

	private struct UTF8EncodedString {

		let data: [CChar]
		let length: Int

		init?(string: String) {
			guard let encoded = string.cString(using: .utf8) else { return nil }

			data = encoded
			length = string.lengthOfBytes(using: .utf8)
		}
	}

	private enum Constants {
		/// The token duration is 15 minutes (900 seconds)
		static let tokenDuration: TimeInterval = 900
		static let delimeter = "~"
	}
}


/// This is a port of the EdgeAuth class included in Akamai / EdgeAuth-Token-Java
public struct EdgeAuth {

	/// Parameter name for the new token.
	let tokenName: String

	/// Secret required to generate the token. It must be hexadecimal digit string with even-length.
	let key: String

	/// To use to generate the token. (sha1, sha256, or md5)
	let algorithm: Crypto.HMAC.Algorithm

	/// What is the start time? ({@code NOW} for the current time)
	let startTime: Double

	/// When does this token expire? It overrides {@code windowSeconds}
	let endTime: Double

	/// Character used to delimit token body fields.
	let fieldDelimiter: String

	/// Character used to delimit acl.
	let aclDelimiter: String

	/// Causes strings to be url encoded before being used.
	let escapeEarly: Bool

	/// Additional data validated by the token but NOT included in the token body. It will be deprecated.
	let salt: String?

	/// Additional text added to the calculated digest.
	let payload: String?

	/// The session identifier for single use tokens or other advanced cases.
	let sessionID: String?

	init(tokenName: String, key: String, algorithm: Crypto.HMAC.Algorithm, lifetime: Existence, fieldDelim: String, aclDelim: String, escapeEarly: Bool, salt: String? = nil, payload: String? = nil, sessionID: String? = nil) {
		self.tokenName = tokenName
		self.key = key
		self.algorithm = algorithm
		self.fieldDelimiter = fieldDelim
		self.aclDelimiter = aclDelim
		self.escapeEarly = escapeEarly
		self.salt = salt
		self.payload = payload
		self.sessionID = sessionID

		switch lifetime {
		case .startEnd(let start, let end):
			self.startTime = start
			self.endTime = end

		case .duration(let duration):
			let epoch = Date().timeIntervalSince1970
			self.startTime = epoch
			self.endTime = epoch + duration
		}
	}
}


public extension EdgeAuth {

	/// Defines the timeframe the token is considered valid.
	enum Existence {

		/// Specify a start time, and end time
		case startEnd(Double, Double)

		/// Specify a duration. Upon initialation startTime is considered Date()
		case duration(Double)
	}

	static let `default` = EdgeAuth(tokenName: "__token__", key: "3be07c165a570b342d3cdfe836755ae4e145121520a22bdbb1f6310ca0556f78", algorithm: .sha256, lifetime: .duration(3600), fieldDelim: "~", aclDelim: "!", escapeEarly: false)
}


public extension EdgeAuth {

	func generateToken(path: String, isURL: Bool) -> String {
		var components = [String]()

		let startTimeString = String(format: "%.0f", startTime)
		components.append("st=\(startTimeString)")

		let endTimeString = String(format: "%.0f", endTime)
		components.append("exp=\(endTimeString)")

		if !isURL {
			let encodedPath = urlEncodedPath(path)
			components.append("acl=\(encodedPath)")
		}

		// session id
		if let sessionID = sessionID {
			components.append("id=\(sessionID)")
		}

		// payload
		if let payload = payload {
			components.append("data=\(payload)")
		}

		let token = components.joined(separator: fieldDelimiter)

		if isURL {
			let encodedPath = urlEncodedPath(path)
			components.append("url=\(encodedPath)")
		}

		if let salt = salt {
			components.append("salt=\(salt)")
		}

		let source = components.joined(separator: fieldDelimiter)
		let hashed = Crypto.HMAC(message: source, key: key, algorithm: algorithm).hash

		let result = [token, hashed].joined(separator: fieldDelimiter)

		return result
	}
}


private extension EdgeAuth {

	enum Keyed {
		static let startTime = "st"
		static let endTime = "exp"
		static let acl = "acl"
		static let sessionID = "id"
		static let payload = "data"
		static let url = "url"
		static let salt = "salt"
	}

	func urlEncodedPath(_ path: String) -> String {
		guard escapeEarly else { return path }

		let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path

		return encodedPath
	}

	//    private String escapeEarly(final String text) throws EdgeAuthException {
	//    if (this.escapeEarly == true) {
	//    try {
	//    StringBuilder newText = new StringBuilder(URLEncoder.encode(text, "UTF-8"));
	//    Pattern pattern = Pattern.compile("%..");
	//    Matcher matcher = pattern.matcher(newText);
	//    String tmpText;
	//    while (matcher.find()) {
	//    tmpText = newText.substring(matcher.start(), matcher.end()).toLowerCase();
	//    newText.replace(matcher.start(), matcher.end(), tmpText);
	//    }
	//    return newText.toString();
	//    } catch (UnsupportedEncodingException e) {
	//    return text;
	//    } catch (Exception e) {
	//    throw new EdgeAuthException(e.getMessage());
	//    }
	//    } else {
	//    return text;
	//    }
	//    }
}


let edgeAuth = EdgeAuth.default
let result = edgeAuth.generateToken(path: "/images", isURL: true)
print(result)


let test = HMACTokenProvider(message: "hello", key: "world")
print(test.generateToken())

