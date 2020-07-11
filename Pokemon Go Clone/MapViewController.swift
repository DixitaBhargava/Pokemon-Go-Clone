//
//  MapViewController.swift
//  Pokemon Go Clone
//
//  Created by Dixita Bhargava on 07/07/20.
//  Copyright © 2020 Dixita Bhargava. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var manager = CLLocationManager()
    var updateCount = 0
    
    var pokemons : [Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokemons = getAllPokemon()
        
        manager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // Setup
        }else{
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            setup()
        }
    }
    
    func setup() {
        mapView.showsUserLocation = true
        manager.startUpdatingLocation()
        mapView.delegate = self
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            if let center = self.manager.location?.coordinate {
                var annoCoord = center
                annoCoord.latitude += (Double.random(in: 0...200) - 100) / 50000.0
                annoCoord.longitude += (Double.random(in: 0...200) - 100) / 50000.0
                if let pokemon = self.pokemons.randomElement(){
                    let anno = PokeAnnotation(coord: annoCoord, pokemon: pokemon)
                    self.mapView.addAnnotation(anno)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        if annotation is MKUserLocation {
            annoView.image = UIImage(named: "player")
        }else{
            if let pokeAnnotation = annotation as? PokeAnnotation {
                if let imageName = pokeAnnotation.pokemon.imageName {
                    annoView.image = UIImage(named: imageName)
                }
            }
        }
        var frame = annoView.frame
        frame.size.height = 50.0
        frame.size.width = 50.0
        annoView.frame = frame
        
        return annoView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        if view.annotation is MKUserLocation {
            
        }else{
            if let center = manager.location?.coordinate {
                if let pokeCenter = view.annotation?.coordinate{
                    let region = MKCoordinateRegion(center: pokeCenter, latitudinalMeters: 200, longitudinalMeters: 200)
                    mapView.setRegion(region, animated: false)
                    
                    if let pokeAnnotation = view.annotation as? PokeAnnotation{
                        if let pokemonName = pokeAnnotation.pokemon.name{
                            if mapView.visibleMapRect.contains( MKMapPoint(center)) {
                                //caught
                                pokeAnnotation.pokemon.caught = true
                                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                                
                                let AlertVC = UIAlertController(title: "Congrats!!", message: "You caught a \(pokemonName)", preferredStyle: .alert)
                                let pokeDexAction = UIAlertAction(title: "PokeDex", style: .default) { (action) in
                                    self.performSegue(withIdentifier: "moveToPokeDex", sender: nil)
                                }
                                
                                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                
                                AlertVC.addAction(pokeDexAction)
                                AlertVC.addAction(okAction)
                                present(AlertVC, animated: true, completion: nil)
                                
                            }else{
                                //tooooo far
                                let AlertVC = UIAlertController(title: "Oopsyy!", message: "You were too far away from this Pokemon to catch it. Try moving closer!", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                AlertVC.addAction(okAction)
                                present(AlertVC, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if updateCount < 3 {
            if let center = manager.location?.coordinate {
                let region = MKCoordinateRegion(center: center, latitudinalMeters: 200, longitudinalMeters: 200)
                mapView.setRegion(region, animated: false)
            }
            updateCount += 1
        }else{
            manager.stopUpdatingLocation()
        }
    }
    
    @IBAction func centerTapped(_ sender: UIButton) {
        
        if let center = manager.location?.coordinate {
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(region, animated: true)
        }
    }
}
