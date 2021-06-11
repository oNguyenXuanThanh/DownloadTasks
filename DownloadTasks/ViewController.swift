//
//  ViewController.swift
//  DownloadTasks
//
//  Created by Thanh Nguyen Xuan on 11/06/2021.
//

import UIKit

private struct Constants {
    static let simpleDownloadURL = "https://data25.chiasenhac.com/download2/2172/5/2171043-de949f5d/128/Tron%20Tim%20-%20Den_%20MTV%20Band.mp3"
    static let progressDownloadURL = "https://data25.chiasenhac.com/stream2/2171/5/2170940-6197d93a/flac/The%20Playah%20Special%20Performance_%20-%20Soobin.flac"
}

class ViewController: UIViewController, URLSessionDelegate {

    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var downloadProgressView: UIProgressView!

    private lazy var urlSession = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: nil
    )

    @IBAction private func simpleDownloadButtonTapped(_ sender: Any) {
        guard let url = URL(string: Constants.simpleDownloadURL) else {
            return
        }
        let downloadTask = URLSession.shared.downloadTask(with: url) { downloadedURL, response, clientSideError in
            // Handle error nếu cần
            print("Client side error: \(clientSideError?.localizedDescription ?? "nil")")

            // Handle response trả về từ server download nếu cần
            print("Download response code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")

            // Check URL file tạm thời sau khi download thành công
            guard let downloadedURL = downloadedURL else {
                print("Downloaded file URL is nil")
                return
            }
            print("Downloaded temp file: \(downloadedURL.absoluteString)")

            do {
                // Lấy dường dẫn của thư mục document
                let documentURL = try FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                )
                // Tạo ra đường dẫn lưu file cuối cùng bằng cách nối thêm đuôi file download
                // vào đường dẫn của thư mục Document
                let saveURL = documentURL.appendingPathComponent(url.lastPathComponent)

                // Xóa file cũ nếu đã tồn tại
                try? FileManager.default.removeItem(at: saveURL)

                // Move file download tạm thời sang đường dẫn mới
                try FileManager.default.moveItem(at: downloadedURL, to: saveURL)
                print("Download file successfully at: \(saveURL.absoluteString)")
                DispatchQueue.main.async {
                    self.messageLabel.text = "Download completed"
                }
            } catch {
                print("File error: \(error.localizedDescription)")
            }
        }
        downloadTask.resume()
    }

    @IBAction private func downloadWithProgressButton(_ sender: Any) {
        guard let url = URL(string: Constants.progressDownloadURL) else {
            return
        }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }

}

extension ViewController: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        // Tính toán tiến độ download dựa trên tổng số byte đã download
        // trên tổng số byte cần download
        let downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        // Cập nhật tiến độ download lên UIProgressBar trên main thread
        DispatchQueue.main.async {
            self.downloadProgressView.progress = downloadProgress
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        // Check downloadTask.response nếu cần
        print("Downloaded temp file: \(location.absoluteString)")

        do {
            // Lấy dường dẫn của thư mục document
            let documentURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            // Unwrap download url từ downloadTask
            guard let downloadURL = downloadTask.originalRequest?.url else {
                return
            }
            // Tạo ra đường dẫn lưu file cuối cùng bằng cách nối thêm đuôi file download
            // vào đường dẫn của thư mục Document
            let saveURL = documentURL.appendingPathComponent(downloadURL.lastPathComponent)

            // Xóa file cũ nếu đã tồn tại
            try? FileManager.default.removeItem(at: saveURL)

            // Move file download tạm thời sang đường dẫn mới
            try FileManager.default.moveItem(at: location, to: saveURL)
            print("Download file successfully at: \(saveURL.absoluteString)")
            DispatchQueue.main.async {
                self.messageLabel.text = "Download completed"
            }
        } catch {
            print("File error: \(error.localizedDescription)")
        }
    }

}
