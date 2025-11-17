import Foundation
import Combine
import Alamofire

public final class MGSSEClient {
    public private(set) var task: URLSessionDataTask?
    private var subject = PassthroughSubject<String, Error>()
    private var session: URLSession?

    public init() {}

    public var eventsPublisher: AnyPublisher<String, Error> {
        subject.eraseToAnyPublisher()
    }

    public func start(url: URL, headers: HTTPHeaders? = nil) {
        stop()
        let cfg = URLSessionConfiguration.default
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.name) }

        session = URLSession(configuration: cfg, delegate: nil, delegateQueue: nil)
        task = session?.dataTask(with: request)
        task?.resume()
        listenLoop()
    }

    private func listenLoop() {
        guard let session = session, let task = task else { return }
        DispatchQueue.global(qos: .background).async { [weak self] in
            while task.state == .running {
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
    }

    public func stop() {
        task?.cancel()
        task = nil
        session?.invalidateAndCancel()
        session = nil
        subject.send(completion: .finished)
    }
}
