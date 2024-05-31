import Fluent

final class EventMigrationV3: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.event)
            .field("tito_event", .string)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.event)
            .deleteField("tito_event")
            .update()
    }
}
