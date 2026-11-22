package com.example.demo.model;

public class Movie
{
    private long id;
    private String title;
    private int releaseYear;
    private int minimumAge;

    public Movie(long id, String title, int releaseYear, int minimumAge)
    {
        this.id = id;
        this.title = title;
        this.releaseYear = releaseYear;
        this.minimumAge = minimumAge;
    }

    public long getId()
    {
        return id;
    }

    public String getTitle()
    {
        return title;
    }

    public int getReleaseYear()
    {
        return releaseYear;
    }

    public int getMinimumAge()
    {
        return minimumAge;
    }
}
