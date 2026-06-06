package dev.stacks

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.hibernate.annotations.Generated
import org.hibernate.generator.EventType
import java.time.OffsetDateTime
import java.util.UUID

@Entity
@Table(name = "users")
class User(
    @Column(nullable = false, unique = true)
    var email: String,
) {
    @Id
    @Generated(event = [EventType.INSERT])
    var id: UUID? = null

    @Generated(event = [EventType.INSERT])
    var createdAt: OffsetDateTime? = null

    @Generated(event = [EventType.INSERT, EventType.UPDATE])
    var updatedAt: OffsetDateTime? = null
}
