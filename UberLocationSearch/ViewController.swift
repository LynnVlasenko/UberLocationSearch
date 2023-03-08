//
//  ViewController.swift
//  UberLocationSearch
//
//  Created by Алина Власенко on 07.03.2023.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    //create map
    let mapView = MKMapView()
    
    //array for locations
    var locations = [Location]()
    
    // MARK: - UIElements
    
    private let field: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter destination"
        field.layer.cornerRadius = 9
        field.backgroundColor = .tertiarySystemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        //field.frame = CGRect(x: 20, y: 100, width: 300, height: 50)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = "Uber"
        
        addSubview()
        applyConstraints()
        field.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height-view.frame.size.height/5)
        tableView.frame = CGRect(x: 0, y: view.frame.size.height-view.frame.size.height/5, width: view.frame.size.width, height: view.frame.size.height-mapView.frame.size.height)
    }
    
    // MARK: - addSubview
    
    private func addSubview() {
        view.addSubview(mapView)
        mapView.addSubview(field)
        view.addSubview(tableView)
    }
    
    // MARK: - Constraints
    
    private func applyConstraints() {
        
        let fieldConstraints = [
            field.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            field.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            field.heightAnchor.constraint(equalToConstant: 50),
            field.widthAnchor.constraint(equalToConstant: 350)
        ]
        
        NSLayoutConstraint.activate(fieldConstraints)
    }
    
    // MARK: - Private
    //create annotations, setRegion, zoom settings
    private func searchViewController(didSelectLocationWith coordinates: CLLocationCoordinate2D?) {
        guard let coordinates = coordinates else {
            return
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        
        mapView.setRegion(MKCoordinateRegion(
            center: coordinates,
            span: MKCoordinateSpan(
                latitudeDelta: 0.2,
                longitudeDelta: 0.2
            )
        ),
        animated: true 
        )
    }
}

// MARK: - Extension for Field

extension ViewController: UITextFieldDelegate {
    //function for update location data in table
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        if let text = field.text, !text.isEmpty {
            LocationManager.shared.findLocations(with: text) { [weak self] locations in
                DispatchQueue.main.async {
                    self?.locations = locations
                    self?.tableView.reloadData()
                }
            }
        }
        return true
    }
}


// MARK: - Extension for Table

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = locations[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Notify map controller to show pin at selected place
        let coordinate = locations[indexPath.row].coordinates
        
        searchViewController(didSelectLocationWith: coordinate)
    }
}
