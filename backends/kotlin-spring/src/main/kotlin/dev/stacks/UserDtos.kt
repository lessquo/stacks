package dev.stacks

import java.time.OffsetDateTime
import java.util.UUID

data class CreateUserRequest(val email: String)

data class UserResponse(
    val id: UUID,
    val email: String,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime,
)

fun User.toResponse() = UserResponse(id!!, email, createdAt!!, updatedAt!!)
