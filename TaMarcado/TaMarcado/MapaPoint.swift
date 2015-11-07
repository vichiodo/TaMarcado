//
//  MapaPoint.swift
//  TaMarcado
//
//  Created by Ricardo Hochman on 11/06/15.
//  Copyright (c) 2015 Ricardo Hochman. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapaPoint: NSObject, MKAnnotation {
    var title:String?
    var subtitle:String?
    var coordinate: CLLocationCoordinate2D
    var ponto:Ponto?
    
    override init(){
        coordinate = CLLocationCoordinate2D()
    }
    
    func criaPonto(localizacao: CLLocationCoordinate2D, nome:String, endereco:String) {
        self.coordinate = localizacao
        self.title = nome
        self.subtitle = endereco
    }
    
    func adicionarPin(mapa: MKMapView, adicionando: Bool) {
        let aux: CLLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(aux, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
//                self.subtitle = "Buscando endereço..."
//                if self.ponto == nil {
//                    self.ponto = PontoManager.sharedInstance.novoPonto()
//                }
//                self.ponto?.nome = self.title
//                self.ponto?.endereco = "Buscando endereço..."
//                self.ponto?.localizacao = aux
//                PontoManager.sharedInstance.salvarPonto()
            }
            else {
                let placemark: CLPlacemark = placemarks!.last!
                let newString: String = placemark.thoroughfare!.stringByAppendingString(", ")
                var newNewString: String!
                if placemark.subThoroughfare != nil {
                    newNewString = newString.stringByAppendingString(placemark.subThoroughfare!)
                }
                else {
                    newNewString = placemark.thoroughfare
                }
                if adicionando {
                    self.subtitle = newNewString
                    if self.ponto == nil {
                        self.ponto = PontoManager.sharedInstance.novoPonto()
                    }
                    self.ponto?.nome = self.title!
                    self.ponto?.endereco = newNewString
                    self.ponto?.localizacao = aux
                    PontoManager.sharedInstance.salvarPonto()
                }
            }
            mapa.addAnnotation(self)
        })
    }
    
}
