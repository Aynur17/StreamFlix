package com.example.demo.exception;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Thrown when request data fails validation. Mapped to 400 Bad Request.
 * Holds one message per invalid field so the client can show all problems at once.
 */
public class InvalidInputException extends RuntimeException {

    private final Map<String, String> fieldErrors;

    public InvalidInputException(Map<String, String> fieldErrors) {
        super("The request contains invalid data.");
        this.fieldErrors = Collections.unmodifiableMap(new LinkedHashMap<>(fieldErrors));
    }

    public Map<String, String> getFieldErrors() {
        return fieldErrors;
    }
}
