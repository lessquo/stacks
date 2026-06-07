package dev.stacks

import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException
import java.util.UUID

@Service
class UserService(private val users: UserRepository) {
    fun create(email: String): User = users.save(User(email))

    fun get(id: UUID): User =
        users.findById(id).orElseThrow { ResponseStatusException(HttpStatus.NOT_FOUND) }
}
