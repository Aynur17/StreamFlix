console.log("Welcome to StreamFlix!");

const exploreButton = document.getElementById("explore-button");

const movieCatalogue = document.getElementById("movies");

// When the Explore movies button is clicked, it should scroll down
exploreButton.addEventListener("click", function() {
    movieCatalogue.scrollIntoView({
        behavior: "smooth"
    });
});