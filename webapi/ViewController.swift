//
//  ViewController.swift
//  webapi
//
//  Created by 山口 智生 on 2015/02/24.
//  Copyright (c) 2015年 Tomoki Yamaguchi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var tablecell: UITableViewCell!
    @IBOutlet weak var backbutton: UIButton!
  
    
    var shopnamelist :[String] = []{
        didSet{
            println("set")
            myTableView.reloadData()
        }
    }
    var shopaddresslist: [String] = []
    var shopphotolist:[String] = []
    
    
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate //AppDelegateのインスタンスを取得
    
    var timer : NSTimer!
    
    var loadedflag = false
    
    @IBAction func bu_back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    // Segue 準備
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toSubViewController") {
            //segue前に実行すべき処理
        }
    }
    
    /*
    Cellが選択された際に呼び出される.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Num: \(indexPath.row)")
        println("shopname: \(self.shopnamelist[indexPath.row])")
        
        appDelegate.selectedid = indexPath.row
        
        appDelegate.activeShopData.name = self.shopnamelist[indexPath.row]
        appDelegate.activeShopData.address = self.shopaddresslist[indexPath.row]
        appDelegate.activeShopData.photourl = self.shopphotolist[indexPath.row]
        
        performSegueWithIdentifier("toSubViewController",sender: nil)
    }
    
    /*
    Cellの総数を返す.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shopnamelist.count
    }
    
    /*
    Cellに値を設定する.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Cellのフォーマットを取得する.
        let cell = tableView.dequeueReusableCellWithIdentifier("shopcell", forIndexPath: indexPath) as UITableViewCell
        
        var imageView = tableView.viewWithTag(1) as UIImageView
        imageView.image = appDelegate.imgdata[indexPath.row]
        
        let label1 = tableView.viewWithTag(2) as UILabel
        label1.text = "\(self.shopnamelist[indexPath.row])"

        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let a = myTableView.indexPathForSelectedRow(){
            myTableView.deselectRowAtIndexPath(a, animated: true)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadedflag = false
        
        var url: NSURL = NSURL(string:appDelegate.urlstring)!
        var myRequest = NSMutableURLRequest(URL:  url)
        myRequest.HTTPMethod = "GET"
        
        // use NSURLSession
        var task = NSURLSession.sharedSession().dataTaskWithRequest(myRequest, completionHandler: { data, response, error in
            if (error == nil) {
                let json = JSON(data: data)
                for var i = 0;i<json["results"]["results_returned"].string!.toInt()!;i++ {
                    if let stringdata = json["results"]["shop"][i]["name"].string{
                        println(stringdata)
                        
                        self.shopnamelist.append(stringdata)
                        self.shopaddresslist.append(json["results"]["shop"][i]["address"].string!)
                        self.shopphotolist.append(json["results"]["shop"][i]["photo"]["pc"]["l"].string!)
                        
                        
                        //let imgurl = NSURL(string: json["results"]["shop"][i]["logo_image"].string!)
                        let imgurl = NSURL(string: json["results"]["shop"][i]["photo"]["mobile"]["l"].string!)
                        var err: NSError?
                        var imageData :NSData = NSData(contentsOfURL: imgurl!,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)!;
                        self.appDelegate.imgdata[i] = UIImage(data:imageData)!
                    }
                }
                self.loadedflag = true
            } else {
                println(error)
            }
        })
        task.resume()
        
        
        
        //タイマーを作る.
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
        
        myTableView.dataSource = self
        myTableView.delegate = self
        
        //myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "shopcell")
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {//画面遷移する
        if timer.valid == true {
            //timerを破棄する.
            timer.invalidate()
        }
    }
    
    override func viewWillAppear(animated: Bool) {//画面遷移してくる
    }
    
    func onUpdate(timer : NSTimer){
        println("count")
        if(self.loadedflag){
            self.backbutton.titleLabel?.text = "検索に戻る"
        }else{
            self.backbutton.titleLabel?.text = "Loading..."
        }
    }
}

