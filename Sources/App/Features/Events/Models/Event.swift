import Fluent
import Foundation
import Vapor

final class Event: Model, Content {
    static let schema = Schema.event

    typealias IDValue = UUID

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "event_date")
    var date: Date
    
    @Field(key: "location")
    var location: String
    
    @Field(key: "is_current")
    var isCurrent: Bool
    
    @Children(for: \.$event)
    var presentations: [Presentation]

    @Children(for: \.$event)
    var slots: [Slot]
    
    init() {}
}

extension Event {
    static func getCurrent(on db: Database) async throws -> Event {
        guard let event = try await Event.query(on: db).filter(\.$isCurrent == true).first() else {
            throw Abort(.notFound, reason: "could not locate current event")
        }
        
        return event
    }
    
    func shouldBeReturned(by request: Request) -> Bool {
        // if the request has a query parameter of 'event' (the event ID)
        // then only return 'true' if the ID provided matches this event
        if let targetEvent: String = try? request.query.get(String.self, at: "event") {
            // case insensitive comparison
            return targetEvent.lowercased() == id?.uuidString.lowercased()
        }
        
        // otherwise return 'true' only if the event is current (i.e. is this years event)
        return isCurrent
    }
}
