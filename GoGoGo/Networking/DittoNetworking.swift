import Combine
import DittoSwift
import Foundation

@MainActor
final class DittoNetworking: ObservableObject {
    static let shared = DittoNetworking()

    let ditto: Ditto

    @Published private(set) var remotePeerCount = 0
    @Published private(set) var syncStatus = "Starting..."

    private var presenceObserver: DittoObserver?

    private init() {
        let config = DittoConfig(
            databaseID: Env.DITTO_DATABASE_ID,
            connect: .server(url: URL(string: Env.DITTO_URL)!)
        )

        do {
            ditto = try Ditto.openSync(config: config)
        } catch {
            fatalError("Ditto.openSync(config:) failed with error \"\(error)\"")
        }

        ditto.auth?.expirationHandler = { ditto, _ in
            await ditto.auth?.login(token: Env.DITTO_DEVELOPMENT_TOKEN, provider: .development) { _, error in
                if let error {
                    print("ERROR: Ditto login failed with error \"\(error)\"")
                }
            }
        }

        // P2P only (LAN / Bluetooth / AWDL) while still authenticating online.
        ditto.updateTransportConfig { transportConfig in
            transportConfig.connect.webSocketURLs.removeAll()
        }

        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
            do {
                try ditto.sync.start()
                syncStatus = "Syncing"
            } catch {
                syncStatus = "Sync failed: \(error.localizedDescription)"
            }
        } else {
            syncStatus = "Preview (sync disabled)"
        }

        presenceObserver = ditto.presence.observe { [weak self] presenceGraph in
            Task { @MainActor in
                self?.remotePeerCount = presenceGraph.remotePeers.count
            }
        }
    }
}
