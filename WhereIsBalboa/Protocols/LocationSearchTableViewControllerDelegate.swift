import UIKit

protocol LocationSearchTableViewControllerDelegate: class {
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, selectedAddress address: Address)
    func locationSearchTableViewController(_ locationSearchTableViewController: LocationSearchTableViewController, encounteredError: Error?)
}
