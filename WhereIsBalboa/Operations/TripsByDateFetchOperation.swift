import Foundation
import FirebaseDatabase

class TripsByDateFetchOperation: AsynchronousOperation, ResultGeneratingOperation {
    typealias Completion = (Result<[Trip]>) -> Void

    private let date: Date
    private let cohort: Cohort
    private let calendar: Calendar
    let onComplete: Completion
    init(_ date: Date, _ cohort: Cohort, _ calendar: Calendar = .current, onComplete: @escaping Completion) {
        self.date = date
        self.cohort = cohort
        self.calendar = calendar
        self.onComplete = onComplete
    }
    
    override func start() {
        super.start()
        Database.database().reference(withPath: cohort.rawValue + "/trips").queryEnding(atValue: date.endOfDay().timeIntervalSince1970 - 1, childKey: "endTimestamp").observeSingleEvent(of: .value, with: { [weak self, date] snapshot in
            defer {
                self?.state = .finished
            }
            do {
                guard let tripSnapshots = snapshot.children.allObjects as? [DataSnapshot] else {
                    throw DatabaseConversionError.invalidSnapshot(snapshot)
                }
                let trips = tripSnapshots.flatMap { try? Trip($0) }
                let currentTrips = trips.filter { trip in
                    guard trip.metadata.dateInterval.contains(date) else {
                        return false
                    }
                    if trip.metadata.dateInterval.end.endOfDay() == date.endOfDay() {
                        return trip.metadata.dateInterval.start.startOfDay() == date.startOfDay()
                    }
                    return true
                }
                self?.onComplete(.success(currentTrips))
            } catch let error {
                self?.onComplete(.failure(error))
            }
        }, withCancel: { [weak self] error in
            self?.onComplete(.failure(error))
            self?.state = .finished
        })
    }
}
