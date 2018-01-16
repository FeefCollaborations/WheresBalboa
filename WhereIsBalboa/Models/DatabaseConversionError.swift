import FirebaseDatabase

enum DatabaseConversionError: Error {
    case invalidSnapshot(DataSnapshot)
}
