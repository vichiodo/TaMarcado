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
    var title:String!
    var subtitle:String!
    var coordinate: CLLocationCoordinate2D
    var ponto:Ponto?

    override init(){
        coordinate = CLLocationCoordinate2D()
    }
    
    
    func criaPonto(localizacao: CLLocationCoordinate2D, nome:String, endereco:String){
        self.coordinate = localizacao
        self.title = nome
        self.subtitle = endereco
    }

    func adicionarPin(mapa: MKMapView){
        var aux: CLLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
    
        
        CLGeocoder().reverseGeocodeLocation(aux, completionHandler: { (placemarks, error) -> Void in
            if (error != nil){
                println("ERRO")
                self.subtitle = "Endereco nao encontrado !!!"
                return
            }
            else {
                var placemark: CLPlacemark = placemarks.last as! CLPlacemark
                var newString: String = placemark.thoroughfare.stringByAppendingString(", ")
                var newNewString: String!
                if placemark.subThoroughfare != nil {
                    newNewString = newString.stringByAppendingString(placemark.subThoroughfare)
                }
                else {
                    newNewString = placemark.thoroughfare
                }
            }
            
            mapa.addAnnotation(self)
        })
    }
    
    func adicionarPin2(mapa: MKMapView){
        var aux: CLLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        
        
        CLGeocoder().reverseGeocodeLocation(aux, completionHandler: { (placemarks, error) -> Void in
            if (error != nil){
                println("ERRO")
                self.subtitle = "Endereco nao encontrado !!!"
                return
            }
            else {
                var placemark: CLPlacemark = placemarks.last as! CLPlacemark
                var newString: String = placemark.thoroughfare.stringByAppendingString(", ")
                var newNewString: String!
                if placemark.subThoroughfare != nil {
                    newNewString = newString.stringByAppendingString(placemark.subThoroughfare)
                }
                else {
                    newNewString = placemark.thoroughfare
                }
                
                self.subtitle = newNewString
                if self.ponto == nil{
                    self.ponto = PontoManager.sharedInstance.novoPonto()
                
                }
                self.ponto?.nome = self.title
                self.ponto?.endereco = newNewString
                self.ponto?.localizacao = aux
                PontoManager.sharedInstance.salvarPonto()
                
                
            }
            
            mapa.addAnnotation(self)
        })
    }

}
