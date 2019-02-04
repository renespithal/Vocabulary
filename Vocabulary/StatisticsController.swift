//
//  StatisticsViewController.swift
//  Vocabulary
//
//  Created by Alex on 14/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import TBEmptyDataSet
import RealmSwift
import PieCharts
import SwiftCharts

class StatisticsController: StyleableTableViewController, PieChartDelegate {
    
   
    var chartView: PieChart!
    var weekView: PieChart!
    
    fileprivate static let alpha: CGFloat = 0.5
  
    var regularConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    //variables for statistics data:
    var sessionsToday : Results<StudySession>!
    var sessionsYesterday : Results<StudySession>!
    var sessionsDBYesterday : Results<StudySession>! //day before yesterday
    var sessionsDBDBYesterday: Results<StudySession>! //day before day before yesterday
    var sessionsDBDBDBYesterday: Results<StudySession>!
    var actions : Results<StudyAction>!
    var actionsYes : Results<StudyAction>!
     var actionsNo : Results<StudyAction>!
  
    let today = Date()
    var dateFormatter = DateFormatter()
    var date: String = ""
    var yesterday: String = ""
    var dayBeforeYesterday: String = ""
    var dayBeforeDayBeforeYesterday: String = ""
    var dayBeforeDayBeforeDayBeforeYesterday: String = ""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tableView.register(Cell2.self, forCellReuseIdentifier: "Cell2")
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        date = dateFormatter.string(from: today)
        
        chartView = PieChart.init()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        weekView = PieChart.init()
        weekView.translatesAutoresizingMaskIntoConstraints = false
        
        viewSetup()
    }
    
    override func viewSetup() {
        
        super.viewSetup()
        self.navigationItem.title = NSLocalizedString("Statistics", comment: "")
        
        tableView.rowHeight = 300
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! Cell2
  
        if indexPath.row == 0 {
            cell.customTextLabel.text = "Known words of all learned words:"
            cell.customDetailedTextLabel.text = "of today's training sessions"
            cell.contentView .addSubview(chartView)
            
            if UIScreen.main.bounds.size.width < 375 { //fur iPhone5 andere constraints setzen
                chartView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 35).isActive = true
                chartView.widthAnchor.constraint(equalToConstant: 300).isActive = true
                chartView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
                chartView.heightAnchor.constraint(equalToConstant: 300).isActive = true
            }else if UIScreen.main.bounds.size.width == 375 { //iPhone6
                    chartView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 35).isActive = true
                    chartView.widthAnchor.constraint(equalToConstant: 300).isActive = true
                    chartView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 40).isActive = true
                    chartView.heightAnchor.constraint(equalToConstant: 300).isActive = true
            }else{
                chartView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 35).isActive = true
                chartView.widthAnchor.constraint(equalToConstant: 300).isActive = true
                chartView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 60).isActive = true
                chartView.heightAnchor.constraint(equalToConstant: 300).isActive = true
            }



        }
        if indexPath.row == 1 {
            cell.customTextLabel.text = "Training session statistics:"
            cell.customDetailedTextLabel.text = "of today and the last 4 days"
            cell.contentView.addSubview(weekView)
            
            if UIScreen.main.bounds.size.width < 375{
                weekView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 40).isActive = true
                weekView.widthAnchor.constraint(equalToConstant: 300).isActive = true
                weekView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
                weekView.heightAnchor.constraint(equalToConstant: 300).isActive = true
            }else if UIScreen.main.bounds.size.width == 375{
                weekView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 50).isActive = true
                weekView.widthAnchor.constraint(equalToConstant: 300).isActive = true
                weekView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 40).isActive = true
                weekView.heightAnchor.constraint(equalToConstant: 300).isActive = true
            }else{
                weekView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 50).isActive = true
                weekView.widthAnchor.constraint(equalToConstant: 300).isActive = true
                weekView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 60).isActive = true
                weekView.heightAnchor.constraint(equalToConstant: 300).isActive = true
            }
        }
        
        return cell
    }
    
    
    
  
    
    override func viewDidAppear(_ animated: Bool) {
        
        chartView?.layers = [createPlainTextLayer(), createTextWithLinesLayer()]
        chartView?.delegate = self
        chartView?.models = createModels() // order is important - models have to be set at the end
        
        weekView.layers = [createCustomViewsLayer(), createTextLayer()]
        weekView.delegate = self
        weekView.models = createWeekModels()
        
    }
    
    // MARK: - PieChartDelegate
    
    func onSelected(slice: PieSlice, selected: Bool) {
        print("Selected: \(selected), slice: \(slice)")
    }
    
    // MARK: - Models
    
    fileprivate func createModels() -> [PieSliceModel] {
        
        //let dateFormatter  = DateFormatter()
       
        
        
        actions = RealmHelper.sharedInstance.realm.objects(StudyAction.self).filter("day = %@", date)
        actionsYes = RealmHelper.sharedInstance.realm.objects(StudyAction.self).filter("day = %@ AND wordKnown == 1", date)
         actionsNo = RealmHelper.sharedInstance.realm.objects(StudyAction.self).filter("day = %@ AND wordKnown == 0", date)
        let yes = actionsYes.count
        let all = actions.count
        let no = actionsNo.count
        let percentYes = (Double(yes) / Double(all)) * 100.0
        let percentNo = (Double(no) / Double(all)) * 100.0
        
        
        
        if(all > 0){
            let models = [
                PieSliceModel(value: Double(percentYes), color: UIColor.green),
                PieSliceModel(value: Double(percentNo), color: UIColor.red)
            ]
           
            return models
        }
        else{ //wenn noch keine Wörter gelernt wurden, einfach nichts anzeigen
            let models = [
                
                PieSliceModel(value: 0, color: UIColor.lightGray)
            ]
           
            return models
        }
        
        
    }
    
    fileprivate func createWeekModels() -> [PieSliceModel] {
        
        
        //let dateFormatter  = DateFormatter()
        //dateFormatter.dateFormat = "dd-MM-yyyy"
        //date = dateFormatter.string(from: today)
        
        let monthsToAdd = 0
        let daysToAdd = -1
        let yearsToAdd = 0
        
        var dateComponent = DateComponents()
        
        dateComponent.month = monthsToAdd
        dateComponent.day = daysToAdd
        dateComponent.year = yearsToAdd
        
        let ystrday = Calendar.current.date(byAdding: dateComponent, to: today)
        self.yesterday = dateFormatter.string(from: ystrday!)
        
        let dbyesterday = Calendar.current.date(byAdding: dateComponent, to: ystrday!)
        self.dayBeforeYesterday = dateFormatter.string(from: dbyesterday!)
       
        let dbdbyesterday = Calendar.current.date(byAdding: dateComponent, to: dbyesterday!)
        self.dayBeforeDayBeforeYesterday = dateFormatter.string(from: dbdbyesterday!)
        
        let dbdbdbyesterday = Calendar.current.date(byAdding: dateComponent, to: dbdbyesterday!)
        self.dayBeforeDayBeforeDayBeforeYesterday = dateFormatter.string(from: dbdbdbyesterday!)
        
       //Sessions der letzten 4 tage + von heute ermitteln
        sessionsToday = RealmHelper.sharedInstance.realm.objects(StudySession.self).filter("day = %@", date)
        sessionsYesterday = RealmHelper.sharedInstance.realm.objects(StudySession.self).filter("day = %@", yesterday)
        sessionsDBYesterday = RealmHelper.sharedInstance.realm.objects(StudySession.self).filter("day = %@", dayBeforeYesterday)
        sessionsDBDBYesterday = RealmHelper.sharedInstance.realm.objects(StudySession.self).filter("day = %@", dayBeforeDayBeforeYesterday)
        sessionsDBDBDBYesterday = RealmHelper.sharedInstance.realm.objects(StudySession.self).filter("day = %@", dayBeforeDayBeforeDayBeforeYesterday)
        
        let allSessionsOf5Days = sessionsToday.count + sessionsYesterday.count + sessionsDBYesterday.count + sessionsDBDBYesterday.count + sessionsDBDBDBYesterday.count
        
        let percentToday = (Double(sessionsToday.count)/Double(allSessionsOf5Days)) * 100.0
        let percentYesterday = (Double(sessionsYesterday.count)/Double(allSessionsOf5Days)) * 100.0
        let percentDayBeforeYD = (Double(sessionsDBYesterday.count)/Double(allSessionsOf5Days)) * 100.0
        let percentDayBeforeDBYD = (Double(sessionsDBDBYesterday.count)/Double(allSessionsOf5Days)) * 100.0
        let percentDayBeforeDBDBYD = (Double(sessionsDBDBDBYesterday.count)/Double(allSessionsOf5Days)) * 100.0

        
        let models = [
            PieSliceModel(value: percentToday, color: highlightColor0),
            PieSliceModel(value: percentYesterday, color: highlightColor1),
            PieSliceModel(value: percentDayBeforeYD, color: highlightColor2),
            PieSliceModel(value: percentDayBeforeDBYD, color: highlightColor3),
            PieSliceModel(value: percentDayBeforeDBDBYD, color: highlightColor4),
        ]
        return models
    }
    
    
    // MARK: - Layers
    
    fileprivate func createPlainTextLayer() -> PiePlainTextLayer {
        
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.viewRadius = 10
        textLayerSettings.hideOnOverflow = true
        textLayerSettings.label.font = UIFont.systemFont(ofSize: 8)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        textLayerSettings.label.textGenerator = {slice in
            return formatter.string(from: slice.data.percentage * 100 as NSNumber).map{"\($0)%"} ?? ""
        }
        
        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        return textLayer
    }
    
    fileprivate func createTextWithLinesLayer() -> PieLineTextLayer {
        let lineTextLayer = PieLineTextLayer()
        var lineTextLayerSettings = PieLineTextLayerSettings()
        lineTextLayerSettings.lineColor = UIColor.lightGray
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        lineTextLayerSettings.label.font = UIFont.systemFont(ofSize: 14)
        lineTextLayerSettings.label.textGenerator = {slice in
            return formatter.string(from: slice.data.model.value as NSNumber).map{"\($0)%"} ?? ""
        }
        
        lineTextLayer.settings = lineTextLayerSettings
        return lineTextLayer
    }
    
    fileprivate func createCustomViewsLayer() -> PieCustomViewsLayer {
        let viewLayer = PieCustomViewsLayer()
        
        let settings = PieCustomViewsLayerSettings()
        settings.viewRadius = 135
        settings.hideOnOverflow = false
        viewLayer.settings = settings
        
        viewLayer.viewGenerator = createViewGenerator()
        
        return viewLayer
    }
    
    fileprivate func createTextLayer() -> PiePlainTextLayer {
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.viewRadius = 60
        textLayerSettings.hideOnOverflow = true
        textLayerSettings.label.font = UIFont.systemFont(ofSize: 12)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        textLayerSettings.label.textGenerator = {slice in
            return formatter.string(from: slice.data.model.value as NSNumber).map{"\($0)%"} ?? ""
        }
        
        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        return textLayer
    }
    
    fileprivate func createViewGenerator() -> (PieSlice, CGPoint) -> UIView {
        return {slice, center in
            
            let container = UIView()
            container.frame.size = CGSize(width: 100, height: 40)
            container.center = center
            let view = UIImageView()
            view.frame = CGRect(x: 30, y: 0, width: 40, height: 40)
            container.addSubview(view)
            
            
            let specialTextLabel = UILabel()
            specialTextLabel.textAlignment = .center
        
            if (slice.data.id == 0 && slice.data.percentage > (0.0)){ 
                specialTextLabel.text = self.date
                specialTextLabel.font = UIFont.systemFont(ofSize: 16.0)
            }
            if (slice.data.id == 1 && slice.data.percentage > (0.0)){
                specialTextLabel.text = self.yesterday
                specialTextLabel.font = UIFont.systemFont(ofSize: 16.0)
            }
            if (slice.data.id == 2 && slice.data.percentage > (0.0)) {
                specialTextLabel.text = self.dayBeforeYesterday
                specialTextLabel.font = UIFont.systemFont(ofSize: 16.0)
            }
            if (slice.data.id == 3 && slice.data.percentage > (0.0)) {
                specialTextLabel.text = self.dayBeforeDayBeforeYesterday
                specialTextLabel.font = UIFont.systemFont(ofSize: 16.0)
            }
            if (slice.data.id == 4 && slice.data.percentage > (0.0)) {
                specialTextLabel.text = self.dayBeforeDayBeforeDayBeforeYesterday
                specialTextLabel.font = UIFont.systemFont(ofSize: 16.0)
            }
           
            specialTextLabel.sizeToFit()
            specialTextLabel.frame = CGRect(x: 0, y: 15, width: 100, height: 20)
            container.addSubview(specialTextLabel)
            container.frame.size = CGSize(width: 100, height: 40)
            
            
            return container
        }}
    
    
    
    
}
