//
//  ViewController.swift
//  sampleSwiftQRCodeReader
//
//  http://docs.fabo.io/swift/avfoundation/008_avfoundation.html
//

import UIKit
import AVFoundation
import Spring

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var qrcodeView: UIView?
    
    @IBOutlet weak var httpLabel: UILabel!
    
    var startButton : SpringButton!
    var myVideoLayer :Any? = nil
    
    var qrURL:NSURL? = nil
    
    // セッションの作成.
    let mySession: AVCaptureSession! = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セッションの作成.
        let mySession: AVCaptureSession! = AVCaptureSession()
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // デバイスを格納する.
        var myDevice: AVCaptureDevice!
        
        // バックカメラをmyDeviceに格納.
        for device in devices! {
            if((device as AnyObject).position == AVCaptureDevicePosition.back){
                myDevice = device as! AVCaptureDevice
            }
        }
        
        // バックカメラから入力(Input)を取得.
        let myVideoInput = try! AVCaptureDeviceInput.init(device: myDevice)
        
        if mySession.canAddInput(myVideoInput) {
            // セッションに追加.
            mySession.addInput(myVideoInput)
        }
        
        // 出力(Output)をMeta情報に.
        let myMetadataOutput: AVCaptureMetadataOutput! = AVCaptureMetadataOutput()
        
        if mySession.canAddOutput(myMetadataOutput) {
            // セッションに追加.
            mySession.addOutput(myMetadataOutput)
            // Meta情報を取得した際のDelegateを設定.
            myMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // 判定するMeta情報にQRCodeを設定.
            myMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        }
        
        // 画像を表示するレイヤーを生成.
        myVideoLayer = AVCaptureVideoPreviewLayer.init(session: mySession) as! AVCaptureVideoPreviewLayer
        
        (myVideoLayer as! AVCaptureVideoPreviewLayer).frame = self.view.bounds
        (myVideoLayer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // Viewに追加.
        self.view.layer.addSublayer(myVideoLayer as! AVCaptureVideoPreviewLayer)
        
        // セッション開始.
        mySession.startRunning()
    }
    
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    // Meta情報を検出際に呼ばれるdelegate.
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count > 0 {
            let qrData: AVMetadataMachineReadableCodeObject  = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            print("\(qrData.type)")
            print("\(qrData.stringValue)")
            qrURL = NSURL(string: qrData.stringValue)
//            var getmetadataObject : AVMetadataObject? = AVMetadataObject()
            
            let gv:AVCaptureVideoPreviewLayer = myVideoLayer as! AVCaptureVideoPreviewLayer
            let gvmo = gv.transformedMetadataObject(for: metadataObjects[0] as! AVMetadataObject)
            //getmetadataObject.bounds.origin.x

            if (startButton != nil){
                self.startButton.removeFromSuperview()
            }
            
            self.startButton = SpringButton(frame: CGRect(x:0,y:0,width:120,height:50))
            
            self.startButton.backgroundColor = UIColor.red;
            self.startButton.layer.masksToBounds = true
            self.startButton.setTitle("start", for: .normal)
            self.startButton.layer.cornerRadius = 20.0
            self.startButton.layer.position = CGPoint(x: (gvmo?.bounds.midX)!, y:(gvmo?.bounds.midY)!)
            
            // アニメーションの設定
            self.startButton.animation = "fadeOut"
            self.startButton.autostart = true
            self.startButton.repeatCount = 10
            self.startButton.duration = 5.0
            self.startButton.force = 3.0
            
            self.view.addSubview(startButton)
            self.startButton.addTarget(self, action: #selector(ViewController.onClickStartButton), for: .touchUpInside)
//
            
            // SafariでURLを表示.
            // UIApplication.sharedApplication().openURL(NSURL(string: qrData.stringValue)!)
            
//            // create the request & response
//            let URL: Foundation.URL = Foundation.URL(string: qrData.stringValue)!
//            let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
//            let session = URLSession.shared
//            
//            // create some JSON data and configure the request
//            let params = ["value1":"id", "value2":"key", "value3":"in"] as Dictionary<String, String>
//            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            
//            // send the request
//            var data = Data()
//            var response = URLResponse()
//            var error = Error.self
//            
//            
//            
////            let task = session.dataTask(with: request, completionHandler: (data, response, error -> Void 
////                if error != nil {
////                    print("Error: \(error)")
////                } else {
////                    let responseString = NSString(data: data!, encoding: String.Encoding.utf8)
////                    print("Response: \(response)")
////                    print("Response String: \(responseString?.description)")
////                }
////            )
//            
//            task.resume()
//            
//            // セッション中止.
            mySession.stopRunning()
        }
    }
    
    func onClickStartButton(){
        mySession.stopRunning()
        
        print(self.qrURL)
        UIApplication.shared.openURL(self.qrURL as! URL)
    }
}
