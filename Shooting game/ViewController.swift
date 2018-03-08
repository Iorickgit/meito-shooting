
//  ViewController.swift
//  かわすやつ
//
//  Created by メイト on 2017/12/25.
//  Copyright © 2017年 com.litech. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet var label: UILabel! //タイマーのラベル
    
    let width: CGFloat = UIScreen.main.bounds.size.width //画像幅
    let height: CGFloat = UIScreen.main.bounds.size.height//たて
    
    var positionY: [CGFloat] = [0.0] //画像の位置の配列
    
    var dy: [CGFloat] = [0.05]
     //画像の動かす幅の配列<-速さ
    
    
    var imgViews: [CGRect] = []
    var timeCount = 0
    var myTimer = Timer()
    
    
    var playerImageView: UIImageView!
    var playerMotionManager: CMMotionManager!
    var speedX: Double = 0.0
    var speedY: Double = 0.0
    
    
    var tekiImageView: UIImageView!
    var zibuntamaImageView: UIImageView!
    
    let screenSize = UIScreen.main.bounds.size
    
    var timer: Timer!
    var shot: Timer!
    var tama: Timer!

    let structView = UIView(frame: CGRect(x: 0, y: 0, width: 375
        , height: 800))
    
    let aaView = UIView(frame: CGRect(x: 0, y: 0, width: 100
        , height: 80))
    
    //wallViewのフレーム情報を入れて置く配列
    var wallRectArray = [CGRect]()
    
    func start() {
        //タイマーを動かす
        timer = Timer.scheduledTimer(timeInterval: 0.005, target: self,
                                     selector: #selector(self.timerUpdate), userInfo: nil, repeats: true)
        timer.fire()
        
        shot = Timer.scheduledTimer(timeInterval: 0.2, target: self,
                                     selector: #selector(self.shotUpdate), userInfo: nil, repeats: true)
        shot.fire()
        
        tama = Timer.scheduledTimer(timeInterval: 0.005, target: self,
                                     selector: #selector(self.tamaUpdate), userInfo: nil, repeats: true)
        tama.fire()
        
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        positionY = [height/2] //画面位を画面幅の中心にする
    
        //playetViewを生成
        // プレイヤーの大きさと位置を指定
        playerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        playerImageView.center = structView.center
        //UIImageを作成
        let playerImage: UIImage = UIImage(named: "icon.png")!
        
        playerImageView.image = playerImage
        start()
        
        //MotionManegerを作成
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        self.startAccelerometer()
        
       self.view.addSubview(playerImageView)
        
        // 敵の大きさと位置を指定
        tekiImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        tekiImageView.center = aaView.center
        //UIImageを作成
        let tekiImage: UIImage = UIImage(named: "teki.png")!
        
        tekiImageView.image = tekiImage
        
        
        self.view.addSubview(tekiImageView)
        
    }
    
  
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func startAccelerometer() {
        //加速度を取得する
        let handler: CMAccelerometerHandler = {(CMAccelerometerData:CMAccelerometerData?, error:Error?) ->
            Void in
            self.speedX += CMAccelerometerData!.acceleration.x
            self.speedY += CMAccelerometerData!.acceleration.y
            
            //プレイヤーの中心位置を設定
            var posX = self.playerImageView.center.x + (CGFloat(self.speedX) / 3)
            var posY = self.playerImageView.center.y - (CGFloat(self.speedY) / 3)
            
            //画面上からプレイヤーがはみ出しそうだったら、posX/posYを修正
            if posX <= self.playerImageView.frame.width / 2 {
                self.speedX = 0
                posX = self.playerImageView.frame.width / 2
            }
            if posY <= self.playerImageView.frame.width / 2 {
                self.speedY = 0
                posY = self.playerImageView.frame.width / 2
            }
            if posX >= self.screenSize.width - (self.playerImageView.frame.width / 2) {
                self.speedX = 0
                posX = self.screenSize.width - (self.playerImageView.frame.width / 2)
            }
            if posY >= self.screenSize.height - (self.playerImageView.frame.width / 2) {
                self.speedY = 0
                posY = self.screenSize.height - (self.playerImageView.frame.width / 2)
            }
            
            self.playerImageView.center = CGPoint(x: posX, y: posY)
            
            
            for wallRect in self.imgViews {
                if (wallRect.intersects(self.playerImageView.frame)){
                    self.gameCheck(result: "gameover", messege: "敵に当たりました")
                    return
                }
            }
        }
        //加速度の開始
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
    }
    
    func gameCheck(result: String, messege: String){
        //加速度を止める
        if playerMotionManager.isAccelerometerActive {
            playerMotionManager.stopAccelerometerUpdates()
        }
        
        let gameCheckAlert: UIAlertController = UIAlertController(title: result, message: messege,
                                                                  preferredStyle: .alert)
        
        self.present(gameCheckAlert, animated: true, completion: nil)
    }

    @objc func timerUpdate() {
        timeCount += 1
        label.text = "\(timeCount)点"
        
        
        if timeCount < 1 {
            myTimer.invalidate()
        }
    }
    
    
    @objc func shotUpdate() {
        // プレイヤーの大きさと位置を指定
        zibuntamaImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        zibuntamaImageView.center = playerImageView.center
        //UIImageを作成
        let zibuntamaImage: UIImage = UIImage(named: "kougeki.png")!
        
        zibuntamaImageView.image = zibuntamaImage
        
        self.view.addSubview(zibuntamaImageView)
    }
    
    @objc func tamaUpdate() {
        
        positionY[0] -= dy[0] //画像の位置をdx分ずらす
        zibuntamaImageView.center.y = playerImageView.center.y //上の画像をずらした位置にずらす
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }
    
}



