import Foundation
import Combine
import Network

public final class MGWebSocketClient: NSObject {
    public static let shared = MGWebSocketClient()

    private var socket: URLSessionWebSocketTask?
    private var session: URLSession!
    private var pingTimer: Timer?
    private let pingInterval: TimeInterval = 10
    private var isConnected = false
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 6
    private var lastURL: URL?
    private var lastHeaders: [String: String]?

    private let subject = PassthroughSubject<String, Error>()
    public var messagesPublisher: AnyPublisher<String, Error> { subject.eraseToAnyPublisher() }

    private let monitor = NWPathMonitor()
    private var isNetworkAvailable = true

    private override init() {
        super.init()
        let cfg = URLSessionConfiguration.default
        session = URLSession(configuration: cfg, delegate: self, delegateQueue: OperationQueue())
        startNetworkMonitor()
    }

    deinit {
        stopNetworkMonitor()
    }

    // MARK: Connect / Disconnect
    public func connect(url: URL, headers: [String: String]? = nil) {
        lastURL = url
        lastHeaders = headers
        disconnect()
        var request = URLRequest(url: url)
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        socket = session.webSocketTask(with: request)
        socket?.resume()
        isConnected = true
        reconnectAttempts = 0
        startPing()
        receiveLoop()
    }

    public func disconnect() {
        isConnected = false
        pingTimer?.invalidate()
        pingTimer = nil
        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil
    }

    // MARK: Send
    public func send(_ text: String, completion: ((Error?) -> Void)? = nil) {
        socket?.send(.string(text)) { error in completion?(error) }
    }

    // MARK: Receive Loop
    private func receiveLoop() {
        socket?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(.string(let text)):
                self.subject.send(text)
            case .success(.data(let data)):
                if let s = String(data: data, encoding: .utf8) { self.subject.send(s) }
            case .failure(let err):
                self.subject.send(completion: .failure(err))
                self.handleDisconnect()
            @unknown default:
                break
            }
            if self.isConnected { self.receiveLoop() }
        }
    }

    // MARK: Heartbeat
    private func startPing() {
        DispatchQueue.main.async {
            self.pingTimer?.invalidate()
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: self.pingInterval, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.socket?.sendPing { error in
                    if let err = error {
                        self.subject.send(completion: .failure(err))
                        self.handleDisconnect()
                    }
                }
            }
        }
    }

    // MARK: Reconnect logic
    private func handleDisconnect() {
        guard reconnectAttempts < maxReconnectAttempts else { return }
        isConnected = false
        pingTimer?.invalidate()
        pingTimer = nil
        reconnectAttempts += 1
        let delay = pow(2.0, Double(reconnectAttempts))
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self, self.isNetworkAvailable else { return }
            if let url = self.lastURL {
                self.connect(url: url, headers: self.lastHeaders)
            }
        }
    }

    // MARK: Network Monitor
    private func startNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.isNetworkAvailable = path.status == .satisfied
            if self.isNetworkAvailable && !self.isConnected {
                // try reconnect
                if let url = self.lastURL {
                    self.connect(url: url, headers: self.lastHeaders)
                }
            }
        }
        let queue = DispatchQueue(label: "WebSocketNetworkMonitor")
        monitor.start(queue: queue)
    }

    private func stopNetworkMonitor() {
        monitor.cancel()
    }
}

extension MGWebSocketClient: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                           didOpenWithProtocol protocol: String?) {
        #if DEBUG
        print("WebSocket opened")
        #endif
        isConnected = true
        reconnectAttempts = 0
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                           didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        #if DEBUG
        print("WebSocket closed: \(closeCode)")
        #endif
        isConnected = false
        handleDisconnect()
    }
}
