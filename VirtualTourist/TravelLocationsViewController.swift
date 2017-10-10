//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/21/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: CoreDataViewController, PinDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    //Propeties
    var deleteMode: DeleteMode = .Off
    var pinModel = PinModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController = createFetchedResultsController(for: Pin.self)
        
        //Set up Map
        mapView.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 1
        
        //Setup View Elements
        let label = DeleteModeLabel(below: view)
        view.addSubview(label)
        
        //Set up Delegates
        fetchedResultsController?.delegate = self
        pinModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchedResultsController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController?.delegate = nil
    }
      
    //MARK: Actions
    @IBAction func longPress(_ gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            pinModel.addPin(at: gestureRecognizer.location(in: mapView))
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        deleteMode.toggle()
        
        view.shiftSubviews(with: deleteMode.opertation)
        
        longPressGestureRecognizer.isEnabled = !longPressGestureRecognizer.isEnabled
    }
}

//MARK: MKMapViewDelegate Functions

extension TravelLocationsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinObject = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinObject == nil {
            pinObject = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinObject?.canShowCallout = false
            pinObject?.animatesDrop = true
            pinObject?.tintColor = .red
        } else {
            pinObject?.annotation = annotation
        }
        return pinObject
    }
    
    //Load pins when map finishes rendering
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        pinModel.loadPins()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //If delete mode is on, delete pin
        //If delete mode is off, go to Photo view for that pin
        switch deleteMode {
        case .On:
            pinModel.deletePin(view)

        case .Off:
            if let pin = view.annotation as? Pin {
                pushPhotoVC(with: pin)

            }
        }
    }
}

//MARK: FetchedResultsControllerDelegate Functions

extension TravelLocationsViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let pin = anObject as? Pin else {
            preconditionFailure("All changes in Map View Controller should be for Pins")
        }
        
        switch type {
        case .insert:
            mapView.addAnnotation(pin)
            do {
                try controller.managedObjectContext.save()
            } catch {
                print("Error saving while inserting pin: \(error.localizedDescription)")
            }
            
        case .delete:
            mapView.removeAnnotation(pin)
            do {
                try controller.managedObjectContext.save()
            } catch {
                print("Error saving while inserting pin: \(error.localizedDescription)")
            }
            
        case .update:
            print("We won't do anything on update")
            
        case .move:
            fatalError("You can't move pins!")
        }
    }
}

extension TravelLocationsViewController {
    
    func pushPhotoVC(with pin: Pin) {
        guard let photoVC = storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController else {
            //TODO: show error
            print("Could not open photo view")
            return
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.PhotoAttributeNames.CreationDate, ascending: true)]
        
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
        fetchRequest.predicate = predicate
        
        guard let context = fetchedResultsController?.managedObjectContext else {
            fatalError("No FRC set in pushPhotoVC")
        }
        
        let frController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        photoVC.fetchedResultsController = frController
        photoVC.pin = pin
        
        navigationController?.pushViewController(photoVC, animated: true)
    }
}
