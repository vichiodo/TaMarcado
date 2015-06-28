//
//  ViewController.swift
//  TaMarcado
//
//  Created by Ricardo Hochman on 11/06/15.
//  Copyright (c) 2015 Ricardo Hochman. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapaViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var btnLocalizacao: UIButton!
    
    var locationManager: CLLocationManager! = CLLocationManager()
    var locations: NSArray = []
    var txtField: UITextField?
    var linha: Int?
    
    // recupera os dados salvos no CoreData
    lazy var pontos:Array<Ponto> = {
        return PontoManager.sharedInstance.buscarPontos()
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // inicia o CLLocationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        // se for a primeira vez, pede pro usuario autorizar a localização
        let request = CLLocationManager.authorizationStatus()
        if request == CLAuthorizationStatus.NotDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        
        // busca pela localização atual
        locationManager.startUpdatingLocation()
        mapa.userTrackingMode = MKUserTrackingMode.Follow
        let image = UIImage(named: "localp") as UIImage!
        btnLocalizacao.setImage(image, forState: .Normal)
        
        // atualiza o mapa com os pins nos respectivos lugares
        pontos = PontoManager.sharedInstance.buscarPontos()
        mapa.removeAnnotations(mapa.annotations)
        for var i = 0; i < pontos.count; ++i {
            var mp = MapaPoint()
            mp.criaPonto(((pontos[i].localizacao as! CLLocation).coordinate as CLLocationCoordinate2D), nome: pontos[i].nome, endereco: pontos[i].endereco)
            mp.adicionarPin(mapa, adicionando: false)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        // se vier de um toque na tabela, foca nesse pin
        if linha > -1 {
            let localPonto = (pontos[linha!].localizacao as! CLLocation).coordinate as CLLocationCoordinate2D
            var region = MKCoordinateRegionMakeWithDistance(localPonto, 500, 500)
            mapa.setRegion(region, animated: true)
            linha = -1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tipoMapa(sender: AnyObject) { // segmented control para os tipo de mapa
        switch (sender as! UISegmentedControl).selectedSegmentIndex{
        case 0:
            mapa.mapType = MKMapType.Standard
        case 1:
            mapa.mapType = MKMapType.Satellite
        case 2:
            mapa.mapType = MKMapType.Hybrid
        default:
            break
        }
    }
    
    @IBAction func marcar(sender: AnyObject) { // criar um pin novo
        locationManager.startUpdatingLocation()
        mapa.userTrackingMode = MKUserTrackingMode.Follow
        let image = UIImage(named: "localp") as UIImage!
        btnLocalizacao.setImage(image, forState: .Normal)
        
        var nomeLocal: String = ""
        
        let alerta: UIAlertController = UIAlertController(title: "Nome do local", message: nil, preferredStyle: .Alert)
        alerta.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Nome"
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.autocorrectionType = UITextAutocorrectionType.Yes
            self.txtField = textField
        }
        
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: nil))

        let salvar: UIAlertAction = UIAlertAction(title: "Salvar", style: .Default, handler: { (ACTION) -> Void in
            nomeLocal = self.txtField!.text
            
            if (nomeLocal == "" || nomeLocal == " ") {
                nomeLocal = "Local"
            }
            
            var mp = MapaPoint()
            mp.criaPonto((self.locations.lastObject as! CLLocation).coordinate, nome: nomeLocal as String, endereco: "buscando...")
            mp.adicionarPin(self.mapa, adicionando: true)
        })
        [alerta.addAction(salvar)]
        
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    @IBAction func localizacaoAtual(sender: AnyObject) {
        // encontra o usuario e mostra sua localização
        let image = UIImage(named: "localp") as UIImage!
        btnLocalizacao.setImage(image, forState: .Normal)
        locationManager.startUpdatingLocation()
        mapa.userTrackingMode = MKUserTrackingMode.Follow
        mapa.setRegion(MKCoordinateRegionMake(mapa.userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
    }
    
    // metodo para atualizar a localização do usuario
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if mapa.userTrackingMode == .None {
            let image = UIImage(named: "local") as UIImage!
            btnLocalizacao.setImage(image, forState: .Normal)
        }
        self.locations = locations
    }
}

