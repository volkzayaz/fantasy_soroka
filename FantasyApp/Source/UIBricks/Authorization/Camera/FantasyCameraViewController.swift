//
//  FantasyCameraViewController.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 20.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import AVFoundation

class FantasyCameraViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!

    private var captureSession: AVCaptureSession! = AVCaptureSession()
    private let stillImageOutput: AVCapturePhotoOutput! = AVCapturePhotoOutput()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var cameraPosition: AVCaptureDevice.Position = .front
    private let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .unspecified)

    private var completion: ((UIImage) -> Void)? = nil

    static func present(on viewController: UIViewController, completion: @escaping (UIImage) -> Void) {

        let vc = R.storyboard.authorization.fantasyCameraViewController()!
        vc.completion = completion

        let nav = FantasyNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen

        viewController.present(nav, animated: true, completion: nil)
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        captureSession.sessionPreset = AVCaptureSession.Preset.photo

        configureInput()

        guard captureSession.canAddOutput(stillImageOutput) else {
            print("Unable to access back camera!")
            return
        }

        captureSession.addOutput(stillImageOutput)

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait

        previewView.layer.addSublayer(videoPreviewLayer)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer!.frame = previewView.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
}

//MARK:- Camera Utils

extension FantasyCameraViewController {

    private func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let devices = self.discoverySession.devices

        guard !devices.isEmpty else {
            fatalError("Missing capture devices.")
        }

        return devices.first(where: { device in device.position == position })!
    }

    func configureInput() {
        captureSession.beginConfiguration()

        if let captureDeviceInput: AVCaptureInput = captureSession.inputs.first {
            captureSession.removeInput(captureDeviceInput)
        }

        var input: AVCaptureDeviceInput!

        do {
            input = try AVCaptureDeviceInput(device: bestDevice(in: cameraPosition))
        } catch let error as NSError {
            input = nil
            print(error.localizedDescription)
        }

        guard captureSession.canAddInput(input)  else {
            print("Unable to access back camera!")
            return
        }

        captureSession.addInput(input)

        captureSession.commitConfiguration()
    }
}

//MARK:- Actions

extension FantasyCameraViewController {

    @IBAction func takePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput!.capturePhoto(with: settings, delegate: self)
    }

    @IBAction func rotate(_ sender: Any) {
        cameraPosition = (cameraPosition == .front) ? .back : .front
        configureInput()
    }

    @IBAction func cancel(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

//MARK:- AVCapturePhotoCaptureDelegate

extension FantasyCameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        guard let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData) else {
            print("Unable to create image from camera's data!")
            return
        }

        guard let c = completion else {
            print("No complition block!")
            return
        }

        let fixedOrientationImage = image.fixedOrientation()
        FantasyPhotoEditorViewController.present(on: self, image: fixedOrientationImage) { [unowned self] (image) in
            c(image)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }

}
