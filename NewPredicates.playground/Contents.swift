import Foundation
import CoreData


// MARK: - CoreDataModel

protocol CoreDataModel: NSManagedObject { }


// MARK: - Sample NSManagedObject Subclass

class Foo: NSManagedObject, CoreDataModel {
    @NSManaged var first: String?
    @NSManaged var favorite: Bool
    @NSManaged var birthday: Date
}


// MARK: - Predicates

extension CoreDataModel {

    static func predicate<Value>(_ kp: KeyPath<Self, Value>, _ op: NSComparisonPredicate.Operator, _ value: Value?) -> NSPredicate {
        let ex1 = \Self.self == kp ? NSExpression.expressionForEvaluatedObject() : NSExpression(forKeyPath: kp)
        let ex2 = NSExpression(forConstantValue: value)

        return NSComparisonPredicate(leftExpression: ex1, rightExpression: ex2, modifier: .direct, type: op)
    }
}


// MARK: - Tests

func printPredicates(old: NSPredicate, new: NSPredicate) {
    print("Old: ", old)
    print("New: ", new)
    print("==: ", old == new)
}

func testStrings() {
    let old = NSPredicate(format: "%K = %@", #keyPath(Foo.first), "bob")
    let new = Foo.predicate(\.first, .equalTo, "bob")
    printPredicates(old: old, new: new)
}

func testBools() {
    let old = NSPredicate(format: "%K = %d", #keyPath(Foo.favorite), true)
    let new = Foo.predicate(\.favorite, .equalTo, true)
    printPredicates(old: old, new: new)
}

func testDates() {
    let date = Date()
    let old = NSPredicate(format: "%K = %@", #keyPath(Foo.birthday), date as NSDate)
    let new = Foo.predicate(\.birthday, .equalTo, date)
    printPredicates(old: old, new: new)
}

func testDateRange() {
    let past = Date.distantPast
    let future = Date.distantFuture

    let old = NSPredicate(format: "%K > %@ AND %K < %@", #keyPath(Foo.birthday), past as NSDate, #keyPath(Foo.birthday), future as NSDate)
    let new = NSCompoundPredicate(andPredicateWithSubpredicates: [Foo.predicate(\.birthday, .greaterThan, past), Foo.predicate(\.birthday, .lessThan, future)])
    printPredicates(old: old, new: new)
}

testStrings()
testBools()
testDates()
testDateRange()
