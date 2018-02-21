import Foundation
import FirebaseDatabase
import CoreLocation

class UserManager: Equatable {
    enum CreationResult {
        case failure(Error), success(UserManager)
    }
    
    typealias OnUpdate = (UserManager) -> Void
    
    let cohort: Cohort
    private(set) var allUsers: [User]
    private(set) var loggedInUserTrips: [Trip]
    private(set) var loggedInUser: User
    private var userDatabaseObservationHandle: UInt!
    private var tripsDatabaseObservationHandle: UInt!
    
    private let userDatabaseReference: DatabaseReference
    private let tripsDatabaseReference: DatabaseReference
    private let tripsQuery: DatabaseQuery
    
    static func new(for cohort: Cohort, withLoggedInUser loggedInUser: User, onCreate: @escaping (CreationResult) -> Void) {
        let (userReference, tripsReference) = UserManager.references(for: cohort)
        let tripsQuery = self.tripsQuery(from: tripsReference, forLoggedInUserID: loggedInUser.id)
        userReference.observeSingleEvent(of: .value, with: { snapshot in
            do {
                let (allUsers, loggedInUser) = try UserManager.userInfos(from: snapshot, withLoggedInUser: loggedInUser)
                tripsQuery.observeSingleEvent(of: .value, with: { snapshot in
                    do {
                        let trips = try self.trips(from: snapshot)
                        onCreate(.success(UserManager(cohort, loggedInUser: loggedInUser, loggedInUserTrips: trips, allUsers: allUsers, userDatabaseReference: userReference, tripsDatabaseReference: tripsReference, tripsQuery: tripsQuery)))
                    } catch let error {
                        onCreate(.failure(error))
                    }
                }, withCancel: { error in
                    onCreate(.failure(error))
                })
            } catch let error {
                // TODO: Log error
                onCreate(.failure(error))
            }
        }, withCancel: { error in
            onCreate(.failure(error))
        })
    }
    
    fileprivate init(_ cohort: Cohort, loggedInUser: User, loggedInUserTrips: [Trip], allUsers: [User], userDatabaseReference: DatabaseReference, tripsDatabaseReference: DatabaseReference, tripsQuery: DatabaseQuery) {
        self.cohort = cohort
        self.loggedInUser = loggedInUser
        self.loggedInUserTrips = loggedInUserTrips
        self.allUsers = allUsers
        self.userDatabaseReference = userDatabaseReference
        self.tripsDatabaseReference = tripsDatabaseReference
        self.tripsQuery = tripsQuery
        beginObservingUsers()
    }
    
    deinit {
        userDatabaseReference.removeObserver(withHandle: userDatabaseObservationHandle)
        tripsDatabaseReference.removeObserver(withHandle: tripsDatabaseObservationHandle)
    }
    
    func beginObservingUsers() {
        userDatabaseObservationHandle = userDatabaseReference.observe(.value) { [weak self] (snapshot: DataSnapshot) in
            guard let strongSelf = self else {
                return
            }
            
            do {
                let (allUsers, loggedInUser) = try UserManager.userInfos(from: snapshot, withLoggedInUser: strongSelf.loggedInUser)
                strongSelf.allUsers = allUsers
                strongSelf.loggedInUser = loggedInUser
                NotificationCenter.default.postUserUpdateNotification(with: strongSelf)
            } catch {
                // TODO: Log error
                return
            }
        }
        tripsDatabaseObservationHandle = tripsQuery.observe(.value) { [weak self] (snapshot: DataSnapshot) in
            guard let strongSelf = self else {
                return
            }
            
            do {
                guard let tripSnapshots = snapshot.children.allObjects as? [DataSnapshot] else {
                    throw DatabaseConversionError.invalidSnapshot(snapshot)
                }
                strongSelf.loggedInUserTrips = try tripSnapshots.map { try Trip($0) }
                NotificationCenter.default.postUserUpdateNotification(with: strongSelf)
            } catch {
                // TODO: Log error
                return
            }
        }
    }
    
    func loggedInUserLocation(at date: Date) -> CLLocation {
        let currentTrip = loggedInUserTrips.first {
            $0.metadata.dateInterval.contains(date)
        }
        return currentTrip?.metadata.address.location ?? loggedInUser.metadata.hometown.location
    }
    
    private static func references(for cohort: Cohort) -> (DatabaseReference, DatabaseReference) {
        let root = Database.database().reference(withPath: cohort.rawValue)
        return (root.child("users"), root.child("trips"))
    }
    
    private static func userInfos(from snapshot: DataSnapshot, withLoggedInUser loggedInUser: User) throws -> ([User], User) {
        guard let userSnapshots = snapshot.children.allObjects as? [DataSnapshot] else {
            throw DatabaseConversionError.invalidSnapshot(snapshot)
        }
        
        let allUsers = try userSnapshots.flatMap { try User($0) }
        guard let loggedInUser = allUsers.first(where: { $0.id == loggedInUser.id }) else {
            throw DatabaseConversionError.invalidSnapshot(snapshot)
        }
        return (allUsers, loggedInUser)
    }
    
    private static func tripsQuery(from tripsDatabaseReference: DatabaseReference, forLoggedInUserID loggedInUserID: User.ID) -> DatabaseQuery {
        return tripsDatabaseReference.queryOrdered(byChild: Trip.DBValues.userID).queryEqual(toValue: loggedInUserID)
    }
    
    private static func trips(from snapshot: DataSnapshot) throws -> [Trip] {
        guard let tripSnapshots = snapshot.children.allObjects as? [DataSnapshot] else {
            throw DatabaseConversionError.invalidSnapshot(snapshot)
        }
        return try tripSnapshots.map { try Trip($0) }
    }
    
    func registerForChanges(onUpdate: @escaping UserManager.OnUpdate) {
        NotificationCenter.default.registerForChanges(onUpdate: onUpdate, in: cohort)
    }
}

// MARK: - Equatable

func ==(lhs: UserManager, rhs: UserManager) -> Bool {
    return
        lhs.cohort == rhs.cohort &&
        lhs.allUsers == rhs.allUsers &&
        lhs.loggedInUser == rhs.loggedInUser
}

// MARK: - Notification extensions

fileprivate extension NotificationCenter {
    @discardableResult func registerForChanges(onUpdate: @escaping UserManager.OnUpdate, in cohort: Cohort) -> NSObjectProtocol {
        return addObserver(forName: .updatedUsers, object: nil, queue: nil, using: { notification in
            guard let userManager = notification.userManager else {
                return
            }
            onUpdate(userManager)
        })
    }
    
    func postUserUpdateNotification(with userManager: UserManager) {
        let userInfo: [AnyHashable: Any] = [Notification.userManagerKey: userManager]
        post(name: .updatedUsers, object: nil, userInfo: userInfo)
    }
}

fileprivate extension Notification {
    var userManager: UserManager? {
        return userInfo?[Notification.userManagerKey] as? UserManager
    }
}

fileprivate extension Notification {
    static let userManagerKey = "userManager"
}

fileprivate extension Notification.Name {
    static let updatedUsers = Notification.Name("usersDidChange")
}
