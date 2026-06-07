package dev.stacks

import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import java.time.OffsetDateTime
import java.util.UUID

data class CreateUserRequest(
    @field:NotBlank @field:Email
    val email: String,
)

data class UserResponse(
    val id: UUID,
    val email: String,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime,
)

fun User.toResponse() = UserResponse(id!!, email, createdAt!!, updatedAt!!)
