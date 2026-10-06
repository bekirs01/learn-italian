import Flutter
import UIKit
import XCTest

@testable import Runner

class RunnerTests: XCTestCase {
  func testWatchChannelContractNames() {
    XCTAssertEqual(WatchSyncChannelName.methodChannel, "lingo_core/watch_sync")
    XCTAssertEqual(WatchSyncChannelName.isWatchSupported, "isWatchSupported")
    XCTAssertEqual(WatchSyncChannelName.getWatchStatus, "getWatchStatus")
    XCTAssertEqual(WatchSyncChannelName.sendTestPayload, "sendTestPayload")
    XCTAssertEqual(WatchSyncChannelName.syncLearningPlan, "syncLearningPlan")
    XCTAssertEqual(WatchSyncChannelName.clearLearningPlan, "clearLearningPlan")
  }

  func testLearningPlanPlistKeepsContractFields() throws {
    let raw: [String: Any] = [
      "schemaVersion": 1,
      "targetLanguageCode": "it",
      "learnerLanguageCode": "tr",
      "items": [
        [
          "id": "word.basics.hello",
          "type": "word",
          "targetText": "ciao",
          "translation": "Merhaba",
        ],
      ],
      "schedule": [
        "enabled": true,
        "mode": "window_frequency",
        "startMinutes": 540,
        "endMinutes": 1260,
        "timesPerDay": 5,
      ],
      "updatedAtEpochMs": 0,
    ]
    let payload = try WatchLearningPlanCodec.plist(raw)
    XCTAssertEqual(payload["schemaVersion"] as? Int, 1)
    XCTAssertEqual(payload["targetLanguageCode"] as? String, "it")
    XCTAssertEqual(payload["learnerLanguageCode"] as? String, "tr")
    let items = payload["items"] as? [[String: Any]]
    XCTAssertEqual(items?.count, 1)
    XCTAssertEqual(items?.first?["id"] as? String, "word.basics.hello")
    let schedule = payload["schedule"] as? [String: Any]
    XCTAssertEqual(schedule?["mode"] as? String, "window_frequency")
    XCTAssertEqual(schedule?["startMinutes"] as? Int, 540)
    XCTAssertEqual(payload["updatedAtEpochMs"] as? Int, 0)
  }

  func testEmptyLearningPlanCanClearWithoutLanguageCodes() throws {
    let payload = try WatchLearningPlanCodec.plist(WatchLearningPlanCodec.empty())
    let items = payload["items"] as? [[String: Any]]
    XCTAssertEqual(items?.count, 0)
    let schedule = payload["schedule"] as? [String: Any]
    XCTAssertEqual(schedule?["enabled"] as? Bool, false)
    XCTAssertEqual(schedule?["mode"] as? String, "window_frequency")
  }

  func testWatchTestPayloadParsesAndStoresShape() throws {
    let raw: [String: Any] = [
      "type": "word",
      "id": "word.basics.hello",
      "targetText": "ciao",
      "translation": "Hello",
    ]
    let item = try WatchLearningItem.parse(dictionary: raw)
    XCTAssertEqual(item.id, "word.basics.hello")
    XCTAssertEqual(item.targetText, "ciao")
    XCTAssertEqual(item.translation, "Hello")
    XCTAssertFalse(item.isPhrase)

    let snapshot = WatchSnapshot.empty.upserting(item)
    XCTAssertEqual(snapshot.currentItem?.id, item.id)
    XCTAssertEqual(snapshot.items.count, 1)
    XCTAssertEqual(snapshot.dictionary()[WatchSyncEnvelopeKey.kind] as? String, WatchSyncEnvelopeKey.kindSnapshot)
  }

  func testLearningPlanSnapshotReadsLearnerLanguageCode() throws {
    let raw: [String: Any] = [
      "schemaVersion": 1,
      "targetLanguageCode": "it",
      "learnerLanguageCode": "fr",
      "items": [
        [
          "id": "word.basics.why",
          "type": "word",
          "targetText": "perché",
          "translation": "Pourquoi",
        ],
        [
          "id": "phrase.greetings.hello",
          "type": "phrase",
          "targetText": "Ciao.",
          "translation": "Bonjour.",
        ],
      ],
    ]
    let snapshot = try WatchSnapshot.parse(dictionary: raw)
    XCTAssertEqual(snapshot.targetLanguage, "it")
    XCTAssertEqual(snapshot.learnerLanguage, "fr")
    XCTAssertEqual(snapshot.items.count, 2)
    XCTAssertEqual(snapshot.items.first?.id, "word.basics.why")
    XCTAssertEqual(snapshot.items.first?.targetText, "perché")
    XCTAssertEqual(snapshot.items.first?.translation, "Pourquoi")
    XCTAssertEqual(snapshot.items.last?.id, "phrase.greetings.hello")
    XCTAssertEqual(snapshot.items.last?.targetText, "Ciao.")
    XCTAssertEqual(snapshot.items.last?.translation, "Bonjour.")
  }

  func testWatchStatusKeysWhenUnsupported() {
    let status = PhoneWatchSessionManager.shared.status
    XCTAssertNotNil(status["supported"])
    XCTAssertNotNil(status["paired"])
    XCTAssertNotNil(status["watchAppInstalled"])
    XCTAssertNotNil(status["reachable"])
  }
}
