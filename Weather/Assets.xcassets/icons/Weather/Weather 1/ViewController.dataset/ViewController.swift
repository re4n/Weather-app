//
//  ViewController.swift
//  Weather
//
//  Created by Ryan Rouxinol on 30/11/23.
//

import UIKit

class ViewController: UIViewController {
    private lazy var backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bg")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.contrastColor
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = UIColor.primaryColor
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 70)
        label.textColor = UIColor.primaryColor
        return label
    }()
    
    private lazy var weatherIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "sunIcon")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private lazy var humidityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Umidade"
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.contrastColor
        return label
    }()
    
    private lazy var humidityValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.contrastColor
        return label
    }()
    
    private lazy var HumidityStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [humidityLabel, humidityValueLabel])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var windLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Vento"
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.contrastColor
        return label
    }()
    
    private lazy var windValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.contrastColor
        return label
    }()
    
    private lazy var windStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [windLabel, windValueLabel])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var statsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [HumidityStackView, windStackView])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 3
        stackView.backgroundColor = UIColor.softGray
        stackView.layer.cornerRadius = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        return stackView
    }()
    
    private lazy var hourlyForecastLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.contrastColor
        label.text = "PREVISÃO POR HORA"
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
       return label
    }()
    
    private lazy var hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 67, height: 84)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register(HourlyForecastCollectionViewCell.self,
                                forCellWithReuseIdentifier: HourlyForecastCollectionViewCell.indentifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var dailyForecastLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.contrastColor
        label.text = "PROXIMOS DIAS"
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
       return label
    }()
    
    private lazy var dailyForecastTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.register(DailyForecastTableViewCell.self, forCellReuseIdentifier: DailyForecastTableViewCell.indentifier)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private lazy var loaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.translatesAutoresizingMaskIntoConstraints = false
        return loader
    }()
    
 
    private let service = Service()
    private var infoCity = City(lat: "-23.550520", lon: "-46.633308", name: "São Paulo")
    private var forecastResponse: ForecastResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchData()
    }
    
    private func fetchData(){
        showLoader()
        
        service.fetchData(city: infoCity) { [ weak self ] response in
            self?.forecastResponse = response
            DispatchQueue.main.async {
                self?.loadData()
            }
            
        }
    }
    
    private func loadData(){
        cityLabel.text = infoCity.name
        
        temperatureLabel.text = forecastResponse?.current.temp.toCelsius()
        humidityValueLabel.text = "\(forecastResponse?.current.humidity ?? 0)mm"
        windValueLabel.text = "\(forecastResponse?.current.windSpeed ?? 0)km/h"
        
        hourlyCollectionView.reloadData()
        
        hideLoader()
    }

    private func setupView() {
        view.backgroundColor = .white
        setHierarchy()
        setConstraints()
    }
        
    private func setHierarchy() {
        
        view.addSubview(backgroundView)
        view.addSubview(headerView)
        view.addSubview(statsStackView)
        view.addSubview(hourlyForecastLabel)
        view.addSubview(hourlyCollectionView)
        
        view.addSubview(dailyForecastLabel)
        view.addSubview(dailyForecastTableView)
        view.addSubview(loaderView)
        
        
        headerView.addSubview(cityLabel)
        headerView.addSubview(temperatureLabel)
        headerView.addSubview(weatherIcon)
        
        HumidityStackView.addArrangedSubview(humidityLabel)
        HumidityStackView.addArrangedSubview(humidityValueLabel)
                
        loaderView.addSubview(loader)
        
    }
    
    
    
    private func setConstraints() {
           NSLayoutConstraint.activate([
               backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
               backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
           ])
        
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
                headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 35),
                headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -35),
                headerView.heightAnchor.constraint(equalToConstant: 169)
            ])
        
            NSLayoutConstraint.activate([
                cityLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15),
                cityLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
                cityLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
                cityLabel.heightAnchor.constraint(equalToConstant: 20),
                temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 21),
                temperatureLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 26),
                weatherIcon.heightAnchor.constraint(equalToConstant: 86),
                weatherIcon.widthAnchor.constraint(equalToConstant: 86),
                weatherIcon.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -26),
                weatherIcon.centerYAnchor.constraint(equalTo: temperatureLabel.centerYAnchor),
                weatherIcon.leadingAnchor.constraint(equalTo: temperatureLabel.trailingAnchor, constant: 15)
            ])
        
            NSLayoutConstraint.activate([
                statsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
                statsStackView.widthAnchor.constraint(equalToConstant: 205),
                statsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        
            NSLayoutConstraint.activate([
                hourlyForecastLabel.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 29),
                hourlyForecastLabel.leadingAnchor.constraint(equalTo: statsStackView.leadingAnchor, constant: 35),
                hourlyForecastLabel.trailingAnchor.constraint(equalTo: statsStackView.trailingAnchor, constant: -35),
                hourlyCollectionView.topAnchor.constraint(equalTo: hourlyForecastLabel.bottomAnchor, constant: 22),
                hourlyCollectionView.heightAnchor.constraint(equalToConstant: 84),
                hourlyCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hourlyCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
            NSLayoutConstraint.activate([
                dailyForecastLabel.topAnchor.constraint(equalTo: hourlyCollectionView.bottomAnchor, constant: 29),
                dailyForecastLabel.leadingAnchor.constraint(equalTo: hourlyCollectionView.leadingAnchor, constant: 35),
                dailyForecastLabel.trailingAnchor.constraint(equalTo: hourlyCollectionView.trailingAnchor, constant: -35),
                dailyForecastTableView.topAnchor.constraint(equalTo: dailyForecastLabel.bottomAnchor, constant: 1),
                dailyForecastTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                dailyForecastTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                dailyForecastTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
            NSLayoutConstraint.activate([
                loaderView.topAnchor.constraint(equalTo: view.topAnchor),
                loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                loader.centerXAnchor.constraint(equalTo: loaderView.centerXAnchor),
                loader.centerYAnchor.constraint(equalTo: loaderView.centerYAnchor)
            ])
        
    }
    
    
    private func showLoader() {
        loaderView.isHidden = false
        loader.startAnimating()
    }
    
    private func hideLoader() {
        loaderView.isHidden = true
        loader.stopAnimating()
    }
}


extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        forecastResponse?.hourly.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCollectionViewCell.indentifier,
                                                            for: indexPath) as? HourlyForecastCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let forecast = forecastResponse?.hourly[indexPath.row]
        cell.loadData(time: forecast?.dt.toHourFormat(),
                      icon: UIImage(named: forecast?.weather.first?.icon ?? ""),
                      temp: forecast?.temp.toCelsius())
        return cell
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DailyForecastTableViewCell.indentifier, for: indexPath)
        return cell
    }

}

