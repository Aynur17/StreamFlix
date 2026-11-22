
package com.example.demo.service;

import com.example.demo.model.Movie;
import com.example.demo.repository.MovieRepository;
import org.springframework.stereotype.Service;

@Service
public class MovieService
{
    private final MovieRepository movieRepository;

    public MovieService(MovieRepository movieRepository)
    {
        this.movieRepository = movieRepository;
    }


    public Movie getMovieById(long id)
    {
        if (id <= 0)
        {
            throw new IllegalArgumentException("Movie ID must be positive");
        }

        return movieRepository.findById(id);
    }

}

