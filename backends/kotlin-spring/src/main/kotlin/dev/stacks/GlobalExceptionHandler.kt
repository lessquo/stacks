package dev.stacks

import org.springframework.dao.DataIntegrityViolationException
import org.springframework.http.HttpStatus
import org.springframework.http.ProblemDetail
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import java.sql.SQLException

@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(DataIntegrityViolationException::class)
    fun handleIntegrity(ex: DataIntegrityViolationException): ProblemDetail {
        if (sqlState(ex) == "23505") {
            return ProblemDetail.forStatusAndDetail(HttpStatus.CONFLICT, "Email already exists")
        }
        throw ex
    }

    private fun sqlState(ex: Throwable): String? {
        var cause: Throwable? = ex
        while (cause != null) {
            if (cause is SQLException) return cause.sqlState
            cause = cause.cause
        }
        return null
    }
}
