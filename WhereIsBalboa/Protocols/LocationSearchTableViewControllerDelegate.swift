import UIKit

protocol LocationSearchTableViewControllerDelegate: class {
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, selectedLocationListing locationListing: LocationListing)
}
