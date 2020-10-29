import UIKit


// Defines a type that can be init with a specified model
protocol Modelable {
    associatedtype Model
    init(model: Model)
}


// Defines the person model. does not specify modelable
protocol PersonModel {
    var first: String? { get }
    var last: String? { get }
}


// Define a person that is a PersonModel
class Person: PersonModel {
    var first: String?
    var last: String?
}


// Define the PersonFlyeight that is a PersonModel AND Modelable
// The modelable implementation just gives us easier boilerplate for the `flyweight` property on PersonModel
struct PersonFlyweight: PersonModel, Modelable {

    let first: String?
    let last: String?

    init(model: PersonModel) {
        self.first = model.first
        self.last = model.last
    }
}


// Each *Model protocol needs a boilerplate `flyweight`
// This is the part that woule be nice to be generic but this isn't the end of the world.
extension PersonModel {
    var flyweight: PersonFlyweight {
        let result = PersonFlyweight(model: self)

        return result
    }
}


// create a person
let jon = Person()

// you can access its flyweight
let test = jon.flyweight

// Create a flyweight from a PersonModel
let flyweight = PersonFlyweight(model: jon)


// even if we only know it's a PersonModel all the same properties are valid
let mark: PersonModel = Person()
let markFlyweight = mark.flyweight
let markFlyweightFlyweight = PersonFlyweight(model: mark)
