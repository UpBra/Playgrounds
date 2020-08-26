import UIKit

let set = CharacterSet.urlPathAllowed

// :
let character = Character(":")

if character.unicodeScalars.allSatisfy(set.contains(_:)) {
	print("character \(character) is in allowed set")
} else {
	print("character \(character) is not in allowed set")
}

let string = String(character)
let percentEncoded = string.addingPercentEncoding(withAllowedCharacters: set) ?? ""

if percentEncoded.contains(string) {
	print("character \(character) was not percent encoded")
} else {
	print("character \(character) was percent encoded")
}



let stupidUrlString = "http://www.percentencoding.com/"
var components = URLComponents(string: stupidUrlString)
components?.path = "stupid:example^path".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!

if let url = components?.url {
	print(url)
}

if let url = URL(string: stupidUrlString) {
	print(url.absoluteURL)
}
