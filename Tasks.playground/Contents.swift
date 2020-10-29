import UIKit



class Task {

    typealias WorkItem = () -> Void

    let doFirst: WorkItem
    let doSecond: WorkItem

    init(first: @escaping WorkItem, second: @escaping WorkItem) {
        doFirst = first
        doSecond = second
    }

    func start(completion: @escaping WorkItem) {
        queue.async(group: group, execute: DispatchWorkItem(block: {
            self.doFirst()
        }))

        queue.async(group: group, execute: DispatchWorkItem(block: {
            self.doSecond()
        }))

        queue.async(group: group, execute: DispatchWorkItem(block: {
            completion()
        }))
    }

    func oneTime(workItem: @escaping WorkItem) {
        queue.async(group: group, execute: DispatchWorkItem(block: {
            workItem()
        }))
    }

    private let queue = DispatchQueue(label: "hello")
    private let group = DispatchGroup()
}


let test = Task(first: {
    sleep(3)
    print("first", Thread.isMainThread)
    sleep(1)
}) {
    print("second", Thread.isMainThread)
}

test.start {
    print("complete", Thread.isMainThread)
}

test.oneTime {
    print("hello", Thread.isMainThread)
}
