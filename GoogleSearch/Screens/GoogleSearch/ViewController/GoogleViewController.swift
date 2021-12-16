//
//  GoogleViewController.swift
//  GoogleSearch
//
//  Created by Александр Басов on 12/16/21.
//

import UIKit
import SafariServices
import Speech
import AVKit

class GoogleViewController: UIViewController {

    // - UI
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnStart: UIButton!
    
    // - DataSource
    private var dataSource: GoogleDataSource?
    
    // - Data
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // - ViewModel
    private let viewModel = GoogleViewModel()
    
    // - Manager
    private let network = NetworkManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

}

//MARK: - Actions
private extension GoogleViewController {
   
    @IBAction func searchButtonAction(_ sender: UIButton) {
        updateSearchButton()
    }
    
    @IBAction func btnStartSpeechToText(_ sender: Any) {
        if audioEngine.isRunning {
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            self.btnStart.isEnabled = false
        } else {
            self.startRecording()
        }
    }
    
    func showErrorLabel(withText text: String) {
        errorLbl.text = text
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.errorLbl.alpha = 1
            self?.errorLbl.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.errorLbl.alpha = 0
                self?.errorLbl.isHidden = true
            }
        }
    }
    
    func showProgressView() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.progressView.alpha = 1
            self?.progressView.isHidden = false
        }
    }
    
    func hideProgressView() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.progressView.alpha = 0
            self?.progressView.isHidden = true
        }
    }
    
    func makeRequest() {
        if let text = textField.text, !text.isEmpty {
            viewModel.getItems(text: text)
            tableView.reloadData()
        } else {
            showErrorLabel(withText: Text.textIsEmpty)
        }
    }
    
    func updateSearchButton() {
        guard let text = textField.text, !text.isEmpty else { return }
        if viewModel.isSearchActive {
            viewModel.isSearchActive = false
            network.stopRequest()
            searchButton.backgroundColor = .systemGreen
            searchButton.setTitle(Text.search, for: .normal)
            viewModel.items.removeAll()
            tableView.reloadData()
        } else {
            viewModel.isSearchActive = true
            searchButton.backgroundColor = .systemBlue
            searchButton.setTitle(Text.stop, for: .normal)
            makeRequest()
        }
    }
}

//MARK: - TextFieldDelegate
extension GoogleViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateSearchButton()
        textField.endEditing(true)
        return true
    }
    
}

//MARK: - GoogleDelegate
extension GoogleViewController: GoogleDelegate {
    
    func scrollViewDidScroll(y: CGFloat) {
        if y != 0 {
            textField.endEditing(true)
        }
    }
    
    func didTapOnItem(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    func didChangeProgress(progress: Progress) {
        progressView.observedProgress = progress
    }
    
    func showProgress() {
        showProgressView()
    }
    
    func hideProgress() {
        hideProgressView()
        tableView.reloadData()
    }
    
    func showError(text: String) {
        showErrorLabel(withText: text)
        showAlert(message: text)
    }
    
    func fetchFinished() {
        viewModel.isSearchActive = false
        searchButton.backgroundColor = .systemGreen
        searchButton.setTitle(Text.search, for: .normal)
    }
    
}

//MARK: - SFSpeechRecognizerDelegate
extension GoogleViewController: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.btnStart.isEnabled = true
        } else {
            self.btnStart.isEnabled = false
        }
    }
    
}

// MARK: - Configure
private extension GoogleViewController {
    
    func configure() {
        configureDataSource()
        setUI()
        configureSpeech()
        textField.delegate = self
        viewModel.delegate = self
    }
    
    func configureDataSource() {
        dataSource = GoogleDataSource(tableView: tableView, viewModel: viewModel)
        dataSource?.delegate = self
    }
    
    func setUI() {
        errorLbl.alpha = 0
        errorLbl.isHidden = true
        progressView.alpha = 0
        progressView.setProgress(0, animated: true)
        btnStart.isEnabled = false
    }
    
    func configureSpeech() {
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in

            var isButtonEnabled = false

            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            OperationQueue.main.addOperation() {
                self.btnStart.isEnabled = isButtonEnabled
            }
        }
    }
    
}

// MARK: - Voice
private extension GoogleViewController {
    
    func startRecording() {

        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true

        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in

            var isFinal = false

            if result != nil {

                self.textField.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }

            if error != nil || isFinal {

                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.btnStart.isEnabled = true
            }
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        self.audioEngine.prepare()

        do {
            try self.audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }

        self.textField.text = Text.placeholder
    }
}

// MARK: - Constants
private extension GoogleViewController {
    
    struct Text {
        static let textIsEmpty = "Add search text!"
        static let placeholder = "Say something, I'm listening!"
        static let search = "Google Search"
        static let stop = "Stop"
    }
}
