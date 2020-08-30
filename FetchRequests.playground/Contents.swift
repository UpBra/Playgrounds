import UIKit
import CoreData


class Foo: NSManagedObject {

	static let entityName = "Foo"

	@NSManaged var first: String?
	@NSManaged var last: String?
	@NSManaged var order: Int16
}


class Bar: NSManagedObject {

	static let entityName = "Bar"

	@NSManaged var identifier: String
	@NSManaged var dateModified: Date
}



// ----------------------------------------------------------------------
// New File
// ----------------------------------------------------------------------

extension Foo {

	enum Sort {
		static var first: NSSortDescriptor { return NSSortDescriptor(keyPath: \Foo.first, ascending: true) }
		static var order: NSSortDescriptor { return NSSortDescriptor(keyPath: \Foo.order, ascending: true) }
	}
}


extension NSFetchRequest where ResultType == Foo {

	convenience init(first: String, sortedBy: [NSSortDescriptor] = [Foo.Sort.order]) {
		self.init(entityName: Foo.entityName)

		predicate = NSPredicate(format: "%K == %@", #keyPath(Foo.first), first)
		sortDescriptors = [Foo.Sort.order]
	}
}


extension Bar {

	enum Sort {
		static var identifier: NSSortDescriptor { return NSSortDescriptor(keyPath: \Bar.identifier, ascending: true) }
	}
}


extension NSFetchRequest where ResultType == Bar {

	convenience init(identifier: String) {
		self.init(entityName: Bar.entityName)


	}
}


let fooRequest = NSFetchRequest<Foo>(first: "bob")
print(fooRequest)


let barRequest = NSFetchRequest<Bar>(identifier: "1")
print(barRequest)
