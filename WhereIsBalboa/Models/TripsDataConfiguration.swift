import CoreLocation

struct TripsDataConfiguration: Equatable {
    var userManager: UserManager
    var keyedUsers: [Trip: User]
    var currentLocation: CLLocation
    var focusedDate: Date
    
    init(_ userManager: UserManager, _ trips: [Trip], focusedDate: Date) {
        self.userManager = userManager
        self.focusedDate = focusedDate
        var currentLocation: CLLocation?
        keyedUsers = trips.reduce([Trip: User]()) { aggregate, trip in
            guard let user = userManager.allUsers.first(where: { $0.id == trip.userID }) else {
                return aggregate
            }
            var updated = aggregate
            updated[trip] = user
            if user == userManager.loggedInUser {
                currentLocation = trip.metadata.address.location
            }
            return updated
        }
        self.currentLocation = currentLocation ?? userManager.loggedInUser.metadata.hometown.location
    }
}

func ==(lhs: TripsDataConfiguration, rhs: TripsDataConfiguration) -> Bool {
    return
        lhs.userManager == rhs.userManager &&
        lhs.keyedUsers == rhs.keyedUsers &&
        lhs.currentLocation == rhs.currentLocation &&
        lhs.focusedDate == rhs.focusedDate
}
