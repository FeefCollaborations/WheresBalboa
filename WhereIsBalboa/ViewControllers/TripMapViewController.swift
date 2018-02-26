import UIKit
import MapKit
import ClusterKit

class TripMapViewController: UIViewController, MKMapViewDelegate {
    typealias TripTapHandler = (Trip, User) -> Void
    typealias TripGroupTapHandler = ([Trip: User]) -> Void
    
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var centerMapButton: UIButton!
    
    static let loggedInUserAnnotationColor = UIColor.green
    static let friendAnnotationColor = UIColor.blue

    private var configuration: TripsDataConfiguration
    private var shouldCenterOnUser = true
    var onTripTap: TripTapHandler?
    var onTripGroupTap: TripGroupTapHandler?
    
    // MARK: - Init
    
    init(_ configuration: TripsDataConfiguration, onTripTap: TripTapHandler?, onTripGroupTap: TripGroupTapHandler?) {
        self.configuration = configuration
        self.onTripTap = onTripTap
        self.onTripGroupTap = onTripGroupTap
        super.init(nibName: nil, bundle: nil)
        guard #available(iOS 11.0, *) else {
            edgesForExtendedLayout = []
            return
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let centerButtonImage = #imageLiteral(resourceName: "centerLocation").withRenderingMode(.alwaysTemplate)
        centerMapButton.setImage(centerButtonImage, for: .normal)
        centerMapButton.setImage(centerButtonImage, for: .selected)
        centerMapButton.addTarget(self, action: #selector(tappedCenterMapButton), for: .touchUpInside)
        updateShouldCenterOnUser(to: shouldCenterOnUser)
        mapView.delegate = self
        let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
        algorithm.cellSize = 200
        mapView.clusterManager.algorithm = algorithm
        mapView.clusterManager.marginFactor = 1
        updateAnnotations()
    }
    
    // MARK: - Accessors
    
    func update(_ configuration: TripsDataConfiguration) {
        guard self.configuration != configuration else {
            return
        }
        self.configuration = configuration
        updateAnnotations()
    }
    
    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let cluster = annotation as? CKCluster else {
            return nil
        }
        
        if cluster.count > 1 {
            let tripAnnotations = cluster.annotations as! [TripAnnotation]
            let containsLoggedInUser = tripAnnotations.contains(where: { $0.user == configuration.userManager.loggedInUser })
            let annotationColor: UIColor = containsLoggedInUser ? TripMapViewController.loggedInUserAnnotationColor : TripMapViewController.friendAnnotationColor

            let identifier = "Cluster"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CKClusterView
            if let clusterView = view {
                clusterView.annotation = annotation
            } else {
                view = CKClusterView(annotation: annotation, reuseIdentifier: identifier)
            }
            view?.updateBorderColor(to: annotationColor)
            view?.title.text = "\(cluster.count)"
            return view
        } else if let tripAnnotation = cluster.firstAnnotation as? TripAnnotation {
            let containsLoggedInUser = tripAnnotation.user == configuration.userManager.loggedInUser
            let annotationColor: UIColor = containsLoggedInUser ? TripMapViewController.loggedInUserAnnotationColor : TripMapViewController.friendAnnotationColor

            let identifier = containsLoggedInUser ? "UserPin" : "Pin"
            let view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                view = dequeuedView
                view.annotation = tripAnnotation
            } else {
                view = MKPinAnnotationView(annotation: tripAnnotation, reuseIdentifier: identifier)
            }
            view.pinTintColor = annotationColor
            view.canShowCallout = true
            
            let whatsappButton = UIButton(type: .infoDark)
            whatsappButton.setImage(#imageLiteral(resourceName: "chatBubble").scaled(toSize: CGSize(width: 20, height: 20)), for: .normal)
            view.leftCalloutAccessoryView = whatsappButton
            view.rightCalloutAccessoryView = UIButton(type: .infoDark)
            
            return view
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.clusterManager.updateClustersIfNeeded()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard
            let cluster = view.annotation as? CKCluster,
            let tripAnnotations = cluster.annotations as? [TripAnnotation],
            cluster.count != 1
        else {
            return
        }
        
        mapView.deselectAnnotation(view.annotation, animated: true)
        let keyedUsers = tripAnnotations.reduce([Trip: User]()) { aggregate, tripAnnotation in
            var updated = aggregate
            updated[tripAnnotation.trip] = tripAnnotation.user
            return updated
        }
        onTripGroupTap?(keyedUsers)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard
            let clusterAnnotation = view.annotation as? CKCluster,
            let tripAnnotation = clusterAnnotation.firstAnnotation as? TripAnnotation
        else {
            return
        }
        if control == view.rightCalloutAccessoryView {
            onTripTap?(tripAnnotation.trip, tripAnnotation.user)
        } else {
            UIApplication.shared.open(tripAnnotation.user.metadata.whatsappURL, options: [:])
        }
    }
    
    // MARK: - Button response
    
    @objc private func tappedCenterMapButton() {
        updateShouldCenterOnUser(to: !shouldCenterOnUser)
    }
    
    private func updateShouldCenterOnUser(to shouldCenterOnUser: Bool) {
        self.shouldCenterOnUser = shouldCenterOnUser
        if shouldCenterOnUser {
            mapView.setCenter(configuration.currentLocation.coordinate, animated: true)
        }
        centerMapButton.isSelected = shouldCenterOnUser
        centerMapButton.tintColor = shouldCenterOnUser ? .blue : .white
    }
    
    // MARK: - Helpers
    
    private func updateAnnotations() {
        guard isViewLoaded else {
            return
        }
        
        let annotations = configuration.keyedUsers.map {
            return TripAnnotation($1, $0, isLoggedInUser: $1 == configuration.userManager.loggedInUser)
        }
        guard
            let oldAnnotations = mapView.clusterManager.annotations as? [TripAnnotation],
            annotations != oldAnnotations
        else {
            return
        }
        mapView.clusterManager.annotations = annotations
        
        defer {
            mapView.clusterManager.updateClustersIfNeeded()
        }
        
        guard let currentUserTrip = configuration.keyedUsers.first(where: { $0.value == configuration.userManager.loggedInUser }).map({ $0.0 }) else {
            return
        }
        
        let coordinate = currentUserTrip.metadata.address.location.coordinate
        if
            shouldCenterOnUser,
            coordinate.latitude != mapView.centerCoordinate.latitude && coordinate.longitude != mapView.centerCoordinate.longitude {
            mapView.setCenter(coordinate, animated: true)
        }
    }
}

