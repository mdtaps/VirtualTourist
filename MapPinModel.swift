//
//  MapPinModel.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 9/10/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import CoreData
import MapKit

protocol PinDelegate {
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? { get set }
    weak var mapView: MKMapView! { get set }
}

class PinModel: NSObject {
    
    var delegate: PinDelegate?
    
    func addPin(at touchLocation: CGPoint) {
        
        guard let context = delegate?.fetchedResultsController?.managedObjectContext else {
            fatalError("Could not get context when adding pin")
        }
        
        guard let coordinateOnMap = delegate?.mapView.convert(touchLocation, toCoordinateFrom: delegate?.mapView) else {
            
            fatalError("Could not get touch coordinate from touch location")
        }
        
        let _ = Pin(coordinate: coordinateOnMap,
                    context: context)
        
        do {
            try delegate?.fetchedResultsController?.performFetch()
        } catch {
            print("bummer")
        }
        dump(delegate?.fetchedResultsController?.fetchedObjects)
    }
    
    func loadPins() {
        
        guard let delegate = delegate else {
            fatalError("No Pin Model Delegate set")
        }
        
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            guard let pins = try delegate.fetchedResultsController?.managedObjectContext.fetch(request) else {
                throw NSError(domain: "loadPins",
                              code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to load pins"])
            }
            
            for pin in pins {
                delegate.mapView.addAnnotation(pin)
                
            }
        } catch let error as NSError {
            dump(error)
        }
    }
    
    func deletePin(_ annotationView: MKAnnotationView) {
        
        guard let context = delegate?.fetchedResultsController?.managedObjectContext else {
            fatalError("Could not get context in delete pin")
        }
        guard let annotation = annotationView.annotation as? NSManagedObject else {
            fatalError("Could not get annotation from annotation view in delete pin")
        }
        
        context.delete(annotation)
    }
}

extension PinModel: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let pin = anObject as? Pin else {
            preconditionFailure("All changes in Map View Controller should be for Pins")
        }
        
        switch type {
        case .insert:
            delegate?.mapView.addAnnotation(pin)
            
        case .delete:
            delegate?.mapView.removeAnnotation(pin)
            
        case .update:
            delegate?.mapView.removeAnnotation(pin)
            delegate?.mapView.addAnnotation(pin)
            
        case .move:
            fatalError("You can't move pins!")
        }
    }

}
