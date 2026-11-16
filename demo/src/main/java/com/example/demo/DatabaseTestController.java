package com.example.demo;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class DatabaseTestController
{
    private final JdbcTemplate jdbcTemplate;

    public DatabaseTestController(JdbcTemplate jdbcTemplate)
    {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/api/test/database")
    public Map<String, String> testDatabase()
    {
        String database = jdbcTemplate.queryForObject(
                "SELECT current_database()", String.class
        );

        return Map.of(
                "status", "connected",
                "database", database
        );
    }
}

