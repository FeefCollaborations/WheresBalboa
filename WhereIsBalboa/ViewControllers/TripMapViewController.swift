import UIKit
import MapKit
import Cluster

class TripMapViewController: UIViewController, MKMapViewDelegate {
    typealias TripTapHandler = (Trip, Balbabe) -> Void
    typealias TripGroupTapHandler = ([Trip: Balbabe]) -> Void
    
    @IBOutlet private var mapView: MKMapView!
    
    static let loggedInUserAnnotationColor = UIColor.green
    static let friendAnnotationColor = UIColor.blue

    private let clusterManager = ClusterManager()
    private let loggedInUser: Balbabe
    private var configuration: TripsDataConfiguration
    var onTripTap: TripTapHandler?
    var onTripGroupTap: TripGroupTapHandler?
    
    // MARK: - Init
    
    init(_ configuration: TripsDataConfiguration, loggedInUser: Balbabe, onTripTap: TripTapHandler?, onTripGroupTap: TripGroupTapHandler?) {
        self.configuration = configuration
        self.loggedInUser = loggedInUser
        self.onTripTap = onTripTap
        self.onTripGroupTap = onTripGroupTap
        super.init(nibName: nil, bundle: nil)
        updateAnnotations()
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
        mapView.delegate = self
        clusterManager.reload(mapView, visibleMapRect: mapView.visibleMapRect)
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
        if let annotation = annotation as? ClusterAnnotation {
            let tripAnnotations = annotation.annotations as! [TripAnnotation]
            let containsLoggedInUser = tripAnnotations.contains(where: { $0.balbabe == loggedInUser })
            let annotationColor: UIColor = containsLoggedInUser ? TripMapViewController.loggedInUserAnnotationColor : TripMapViewController.friendAnnotationColor
            let annotationStyle = ClusterAnnotationStyle.color(annotationColor, radius: 20)
            
            let identifier = "Cluster"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if let view = view as? ClusterAnnotationView {
                view.annotation = annotation
                view.configure(with: annotationStyle)
            } else {
                view = ClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier, style: annotationStyle)
            }
            return view
        } else {
            let tripAnnotation = annotation as! TripAnnotation
            let containsLoggedInUser = tripAnnotation.balbabe == loggedInUser
            let annotationColor: UIColor = containsLoggedInUser ? TripMapViewController.loggedInUserAnnotationColor : TripMapViewController.friendAnnotationColor
            
            let identifier = "Pin"
            let view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                view = dequeuedView
                view.annotation = annotation
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            view.pinTintColor = annotationColor
            view.canShowCallout = true
            let button = UIButton(type: .infoDark)
            button.setImage(#imageLiteral(resourceName: "chatBubble").scaled(toSize: CGSize(width: 20, height: 20)), for: .normal)
            view.rightCalloutAccessoryView = button
            return view
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusterManager.reload(mapView, visibleMapRect: mapView.visibleMapRect)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard
            let cluster = view.annotation as? ClusterAnnotation,
            let tripAnnotations = cluster.annotations as? [TripAnnotation]
        else {
            return
        }
        // Selected group annotation
        mapView.deselectAnnotation(view.annotation, animated: true)
        let keyedBalbabes = tripAnnotations.reduce([Trip: Balbabe]()) { aggregate, tripAnnotation in
            var updated = aggregate
            updated[tripAnnotation.trip] = tripAnnotation.balbabe
            return updated
        }
        onTripGroupTap?(keyedBalbabes)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let tripAnnotation = view.annotation as? TripAnnotation {
            onTripTap?(tripAnnotation.trip, tripAnnotation.balbabe)
        }
    }
    
    // MARK: - Helpers
    
    private func updateAnnotations() {
        let annotations = configuration.keyedBalbabes.map { TripAnnotation($1, $0) }
        clusterManager.removeAll()
        clusterManager.add(annotations)
        if isViewLoaded {
            clusterManager.reload(mapView, visibleMapRect: mapView.visibleMapRect)
        }
    }
}

