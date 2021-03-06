
import Foundation
import UIKit
import AVKit

extension PhotoSnippetViewController: AVCaptureFileOutputRecordingDelegate
{
  func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?)
  {
   guard (error == nil) else
   {
    print ("Video Recording Error to URL:\n \"\(outputFileURL.path)\"\n \(error!.localizedDescription)")
    return
   }
  
   print ("Video Recording successful to URL:\n\"\(outputFileURL.path)\"")
  
   guard let preview = PhotoItem.renderVideoPreview(for: outputFileURL) else
   {
    return
   }
  
   let newPhotoItem = PhotoItem(photoSnippet: self.photoSnippet,
                               image: preview,
                               cachedImageWidth: self.imageSize,
                               newVideoID: self.photoSnippetVideoID)
  
   insertNewPhotoItem(newPhotoItem, with: BatchAnimationOptions.withSmallJump(0.3))
 }
 
 func showVideoShootingController ()
 {
  let storyboard = UIStoryboard(name: "MediaViewControllers", bundle: nil)
  guard let videoVC = storyboard.instantiateViewController(withIdentifier: "VideoShootingVC") as? VideoShootingViewController
   else
  {
   return
  }
  videoVC.videoSnippetID = photoSnippet.id!.uuidString
  videoVC.modalPresentationStyle = .fullScreen
 
  videoVC.transitioningDelegate = imagePickerTransitionDelegate
  self.present(videoVC, animated: true)
 }
}

class VideoShootingPreviewView: UIView
{
 override class var layerClass: AnyClass
 {
  return AVCaptureVideoPreviewLayer.self
 }
 
 var videoShootingPreviewLayer: AVCaptureVideoPreviewLayer
 {
  return layer as! AVCaptureVideoPreviewLayer
 }
}

class VideoShootingViewController: UIViewController
{
 let shootingSession = AVCaptureSession()
 var videoOutput: AVCaptureMovieFileOutput?
 var videoSnippetID: String!
 
 @IBOutlet var preview: VideoShootingPreviewView!
 @IBOutlet var shootingBarButton: UIButton!
 
 weak var timer: Timer?
 var recordTime: TimeInterval = 0.0
 {
  didSet
  {
   let HH = Int(recordTime/3600)
   let MM = Int((recordTime - Double(HH) * 3600) / 60)
   let SS = Int(recordTime - Double(HH) * 3600 - Double(MM) * 60)
   timerLabel.text  = "\(HH < 10 ? "0" : "")\(HH):\(MM < 10 ? "0" : "")\(MM):\(SS < 10 ? "0" : "")\(SS)"
   
  }
 }
 
 lazy var timerLabel: UILabel =
 {
   let timer = UILabel(frame: CGRect.zero)
   timer.backgroundColor = UIColor.clear
   timer.textAlignment = .right
   timer.font = .boldSystemFont(ofSize: 16)
   timer.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
   preview.addSubview(timer)
   timer.translatesAutoresizingMaskIntoConstraints = false
   NSLayoutConstraint.activate(
    [
     timer.topAnchor.constraint  (equalTo:  preview.topAnchor,  constant:  15),
     timer.trailingAnchor.constraint (equalTo:  preview.trailingAnchor, constant: -15),
     timer.widthAnchor.constraint(equalToConstant: 150),
     timer.heightAnchor.constraint (equalToConstant: 30)
    ]
   )
   
   return timer
 }()
 
 func getVideoOuputURL(with newVideoID: UUID) -> URL
 {
  let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  let videoSnippetURL = docFolder.appendingPathComponent(self.videoSnippetID)
  let videoFileName = newVideoID.uuidString + PhotoItem.videoFormatFile
  return videoSnippetURL.appendingPathComponent(videoFileName)
 }
 
 
 func checkAudioAuthorization()
 {
  switch AVCaptureDevice.authorizationStatus(for: .audio)
  {
   case .authorized:
     print ("***** Audio Status is authorized *****")
     configueShootingSession ()
   case .notDetermined:
    AVCaptureDevice.requestAccess(for: .audio)
    { granted in
     if granted
     {
      print ("***** Audio Status was not detemined and now is authorized *****")
      self.configueShootingSession ()
     }
    }
   
   default: return
  
  }
 }
 
 func checkVideoAuthorization()
 {
  switch AVCaptureDevice.authorizationStatus(for: .video)
  {
   case .authorized:
    print ("***** Video Status is authorized. Proceeding with with audio authorization *****")
    checkAudioAuthorization()
   case .notDetermined:
   AVCaptureDevice.requestAccess(for: .video)
   { granted in
    if granted
    {
     print ("***** Video Status was not detemined and now is authorized *****")
     self.checkAudioAuthorization()
    }
   }
   
   default: return
  }
 }
 
 func configueSessionInput (deviceType: AVCaptureDevice.DeviceType, mediaType: AVMediaType, position: AVCaptureDevice.Position)
 {
  guard let device = AVCaptureDevice.default(deviceType, for: mediaType, position: position),
        let deviceInput = try? AVCaptureDeviceInput(device: device), shootingSession.canAddInput(deviceInput)
  else
  {
   print ("Unable to add \(mediaType.rawValue) input to the current session")
   return
  }
  shootingSession.addInput(deviceInput)
  
 
  
 }

 func configueSessionVideoFileOutput ()
 {
  shootingSession.beginConfiguration()
  let videoFileOutput = AVCaptureMovieFileOutput()
  guard shootingSession.canAddOutput(videoFileOutput) else
  {
   print ("Unable to add video file output to the current session")
   return
   
  }
  shootingSession.sessionPreset = .high
  shootingSession.addOutput(videoFileOutput)
  self.videoOutput = videoFileOutput
  
  if let videoConnection = videoFileOutput.connection(with: .video), videoConnection.isVideoOrientationSupported
  {
   videoConnection.videoOrientation = (view.bounds.width > view.bounds.height) ? .landscapeRight : .portrait
  }
  
  shootingSession.commitConfiguration()
 }
 
 func configueShootingSession ()
 {
  configueSessionInput(deviceType: .builtInWideAngleCamera, mediaType: .video, position: .unspecified)
  configueSessionInput(deviceType: .builtInMicrophone, mediaType: .audio, position: .unspecified)
  
  preview.videoShootingPreviewLayer.session = shootingSession
  preview.videoShootingPreviewLayer.videoGravity = .resizeAspectFill
  preview.videoShootingPreviewLayer.masksToBounds = true
  preview.videoShootingPreviewLayer.connection?.videoOrientation =
   (view.bounds.size.width > view.bounds.size.height) ? .landscapeRight : .portrait
  
  shootingBarButton.isEnabled = true
  
  shootingSession.startRunning()
 }
 
 override var supportedInterfaceOrientations: UIInterfaceOrientationMask
 {
  return [.portrait, .landscapeRight]
 }
 
 override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
 {
  super.traitCollectionDidChange(previousTraitCollection)
 }
 
 override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
 {
  super.viewWillTransition(to: size, with: coordinator)
  
  let orientation: AVCaptureVideoOrientation = (size.width > size.height) ? .landscapeRight : .portrait
  
  shootingSession.beginConfiguration()
  
  if let videoConnection = videoOutput?.connection(with: .video), videoConnection.isVideoOrientationSupported
  {
    videoConnection.videoOrientation = orientation
  }
  
  if let previewConnection = preview.videoShootingPreviewLayer.connection
  {
   previewConnection.videoOrientation = orientation
  }
  
  shootingSession.commitConfiguration()
 
 }
 
 override func viewDidLoad()
 {
  super.viewDidLoad()
  shootingBarButton.isEnabled = false
  checkVideoAuthorization()
 
 }

 override func viewWillAppear(_ animated: Bool)
 {
   super.viewWillAppear(animated)
 }
 
 override func viewWillDisappear(_ animated: Bool)
 {
   super.viewWillDisappear(animated)
  
   if let output = videoOutput, output.isRecording
   {
    output.stopRecording()
   }
  
   if shootingSession.isRunning {shootingSession.stopRunning()}
  
 }
 @IBAction func cancellShootingPress(_ sender: UIBarButtonItem)
 {
  if let output = videoOutput, output.isRecording
  {
   output.stopRecording()
  }
  
  if shootingSession.isRunning {shootingSession.stopRunning()}
  
  self.presentingViewController?.dismiss(animated: true, completion: nil)
 }

 func startShooting(with recordDelegate: AVCaptureFileOutputRecordingDelegate)
 {
  shootingBarButton.setImage(UIImage(named: "stop.recording.tab.icon"), for: .normal)
  
  UIView.animate(withDuration: 0.35,
                 delay: 0,
                 options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction],
                 animations:
                 {[weak self] in
                  self?.shootingBarButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                  self?.timerLabel.alpha = 0.5
                 },
                 completion: nil)
  
  let newVideoID = UUID()
  (recordDelegate as! PhotoSnippetViewController).photoSnippetVideoID = newVideoID
  let newVideoURL = getVideoOuputURL(with: newVideoID)
  videoOutput!.startRecording(to: newVideoURL, recordingDelegate: recordDelegate)
  timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] _ in self?.recordTime += 1}
 }
 
 func stopShooting()
 {
  recordTime = 0.0
  timer?.invalidate()
  videoOutput!.stopRecording()
 }
 
 @IBAction func makeShootingPress(_ sender: UIButton)
 {
  if (videoOutput == nil)
  {
   configueSessionVideoFileOutput()
  }
  
  if (videoOutput!.isRecording)
  {
    shootingBarButton.setImage(UIImage(named: "start.recording.tab.icon"), for: .normal)
    UIView.animate(withDuration: 0.3,
                   delay: 0,
                   options: [.curveEaseInOut],
                   animations:
                   {[weak self] in
                     self?.shootingBarButton.transform = .identity
                     self?.timerLabel.alpha = 0.0
                     self?.timerLabel.transform = CGAffineTransform(translationX: 0, y: -150)
                   },
                   completion: {[weak self] _ in self?.stopShooting()})
   
  }
  else
  if let presenter = self.presentingViewController as? UINavigationController,
     let recordDelegate = presenter.topViewController as? PhotoSnippetViewController
  {
  
    timerLabel.alpha = 0.0
    timerLabel.transform = CGAffineTransform(translationX: 0, y: -150)
    timerLabel.text = "00:00:00"
   
    UIView.animate(withDuration: 0.5,
                   delay: 0.0,
                   usingSpringWithDamping: 50,
                   initialSpringVelocity: 0,
                   options: [.curveEaseInOut],
                   animations:
                   {[weak self] in
                    self?.timerLabel.alpha = 1.0
                    self?.timerLabel.transform = .identity
                   },
                   completion: {[weak self] _ in self?.startShooting(with: recordDelegate)})
   
  }
   
 }

 deinit
 {
  timer?.invalidate()
 }
}
