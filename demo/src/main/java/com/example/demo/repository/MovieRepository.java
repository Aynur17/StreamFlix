package com.example.demo.repository;

import com.example.demo.model.Movie;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.jdbc.core.RowMapper;

@Repository
public class MovieRepository
{
    private final JdbcTemplate jdbcTemplate;

    public MovieRepository(JdbcTemplate jdbcTemplate)
    {
        this.jdbcTemplate = jdbcTemplate;
    }


    private final RowMapper<Movie> movieRowMapper = (rs, rowNum) ->
            new Movie(
                    rs.getLong("id"),
                    rs.getString("title"),
                    rs.getInt("releaseYear"),
                    rs.getInt("minimumAge")
            );



    public Movie findById(long id)
    {
        String sql = "SELECT id, title, releaseYear, minimumAge " +
                    "FROM movies " +
                    "WHERE id = ?";

        return jdbcTemplate.queryForObject(sql, movieRowMapper, id);
    }

}
