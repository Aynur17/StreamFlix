package com.example.demo.exception;

/**
 * Thrown when a request conflicts with existing data (e.g. a duplicate name). Mapped to 409 Conflict.
 */
public class ConflictException extends RuntimeException {

    public ConflictException(String message) {
        super(message);
    }
}
