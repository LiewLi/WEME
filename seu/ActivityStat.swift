//
//  ActivityStat.swift
//  WEME
//
//  Created by liewli on 1/6/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit
import Charts

class ActivityStatVC:UIViewController, ChartViewDelegate {
    private var chartView:HorizontalBarChartView!
    var activityID:String!
    
    var totalRegister = 0
    var todayRegister = 0
    var totalLike = 0
    var todayLike = 0
    
    var activityName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "活动信息"
        view.backgroundColor = BACK_COLOR
        setupUI()
        fetchActivityInfo()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = true
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        
    }
    
    func setupUI() {
        chartView = HorizontalBarChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartView)
        
        chartView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(view.snp_topMargin).offset(20)
            make.bottom.equalTo(view.snp_bottomMargin).offset(-20)
        }
        
            
        chartView.delegate = self
        chartView.descriptionText = ""
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.pinchZoomEnabled = false
        chartView.maxVisibleValueCount = 1000
        chartView.drawGridBackgroundEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.noDataText = "获取数据中..."

        chartView.xAxis.labelPosition = .Bottom
        chartView.xAxis.labelFont = UIFont.systemFontOfSize(10)
        chartView.xAxis.drawAxisLineEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.gridLineWidth = 0.3
        
        chartView.leftAxis.enabled = false
//        chartView.leftAxis.labelFont = UIFont.systemFontOfSize(10)
//        chartView.leftAxis.drawAxisLineEnabled = true
//        chartView.leftAxis.drawGridLinesEnabled = true
//        chartView.leftAxis.gridLineWidth = 0.3
//        chartView.leftAxis.valueFormatter = NSNumberFormatter()
//        chartView.leftAxis.valueFormatter?.minimumFractionDigits = 0
        chartView.rightAxis.enabled = false
//        chartView.rightAxis.labelFont = UIFont.systemFontOfSize(10)
//        chartView.rightAxis.drawAxisLineEnabled = true
//        chartView.rightAxis.drawGridLinesEnabled = false
//        chartView.rightAxis.gridLineWidth = 0.3
//        chartView.rightAxis.valueFormatter = NSNumberFormatter()
//        chartView.rightAxis.valueFormatter?.minimumFractionDigits = 0
        
        chartView.animate(yAxisDuration: 2.5)
        
    }
    
    func fetchActivityInfo() {
        if let t = token {
            request(.POST, GET_ACTIVITY_STATISTIC_URL, parameters: ["token":t, "activityid":activityID], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"] == "successful" else {
                        return
                    }
                    S.totalRegister = json["result"]["registeredTotal"].int ?? 0
                    S.todayRegister = json["result"]["registeredToday"].int ?? 0
                    S.totalLike = json["result"]["likedTotal"].int ?? 0
                    S.todayLike = json["result"]["likedToday"].int ?? 0
                    S.activityName = json["result"]["activity"].stringValue ?? ""
                    S.configUI()
                    
                }
            })
        }
    }
    
    func configUI() {
        let x = ["历史关注", "今日关注", "历史报名", "今日报名"]
        let y = [BarChartDataEntry(value: Double(totalLike), xIndex: 0), BarChartDataEntry(value: Double(todayLike), xIndex: 1), BarChartDataEntry(value: Double(totalRegister), xIndex: 2), BarChartDataEntry(value: Double(todayRegister), xIndex: 3)]
        let dataSet = BarChartDataSet(yVals: y, label: activityName)
        dataSet.setColor(THEME_COLOR)
        dataSet.valueFormatter = NSNumberFormatter()
        dataSet.valueFormatter?.minimumSignificantDigits = 0
        let data = BarChartData(xVals: x, dataSet: dataSet)
        data.setValueFont(UIFont.init(name: "HelveticaNeue-Light", size: 10.0))
        chartView.data = data
        
    }
    
    
}