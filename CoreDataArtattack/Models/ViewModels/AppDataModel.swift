import Foundation
import MapKit
import CoreData
import CoreLocation

class ApplicationData: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // pour la carte
    var selectedPlace: Place?
    
    // région affichée
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6083, longitude: 1.4418), // par défaut : Basilique Saint-Sernin
        latitudinalMeters: 2500,
        longitudinalMeters: 2500
    )
    
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("❌ Autorisation refusée — on garde la région par défaut.")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinates = locations.first?.coordinate else { return }
        
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: coordinates,
                latitudinalMeters: 2500,
                longitudinalMeters: 2500
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Erreur de localisation : \(error.localizedDescription)")
        // on ne change rien : la région par défaut reste utilisée
    }
}
