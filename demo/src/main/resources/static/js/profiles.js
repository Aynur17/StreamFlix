const profiles = [
    {
        id: 1,
        name: "Profile 1",
        ageCategory: "16",
        avatar: "profile1.png"
    },
    {
        id: 2,
        name: "Profile 2",
        ageCategory: "9",
        avatar: "profile2.png"
    }
];

const profilesContainer = document.getElementById("profiles-container");
const addProfileSection = document.getElementById("add-profile-section");
const profileForm = document.getElementById("profile-form");
const cancelButton = document.getElementById("cancel");

// Display all profiles
function displayProfiles() {
    // clear existing profiles
    profilesContainer.innerHTML = "";

    profiles.forEach(function (profile) {
        const profileElement = document.createElement("div");
        profileElement.classList.add("profile");

        const profileImage = document.createElement("img");

        if (profile.avatar) {
            profileImage.src = "images/" + profile.avatar;
        } else {
            profileImage.src = "images/default-avatar.png";
        }

        profileImage.alt = profile.name;

        const profileName = document.createElement("h3");
        profileName.textContent = profile.name;

        const ageCategory = document.createElement("p");
        ageCategory.textContent = profile.ageCategory + "+";

        profileElement.appendChild(profileImage);
        profileElement.appendChild(profileName);
        profileElement.appendChild(ageCategory);

        profileElement.addEventListener("click", function (event) {
            alert("You selected" + profile.name);
        });

        profilesContainer.appendChild(profileElement);
    });

    // add the Add Profile option
    const addProfileCard = document.createElement("div");
    addProfileCard.classList.add("add-profile-card");

    const plusSign = document.createElement("div");
    plusSign.classList.add("add-profile");
    plusSign.textContent = "+";

    const addProfileText = document.createElement("p");
    addProfileText.textContent = "Add Profile";

    addProfileCard.appendChild(plusSign);
    addProfileCard.appendChild(addProfileText);

    addProfileCard.addEventListener("click", function (event) {
        addProfileSection.hidden = false;
    });

    profilesContainer.appendChild(addProfileCard);
}

// Create a new profile using the form
profileForm.addEventListener("submit", function (event) {
    event.preventDefault();

    const name = document.getElementById("profile-name").value;
    const ageCategory = document.getElementById("age-category").value;

    const selectedAvatar = document.querySelector('input[name="avatar"]:checked');

    let avatar = "";

    if (selectedAvatar !== null) {
        avatar = selectedAvatar.value;
    }

    // Create a new profile object
    const newProfile = {
        id: profiles.length + 1,
        name: name,
        ageCategory: ageCategory,
        avatar: avatar,
    };

    // add profile to the array
    profiles.push(newProfile);

    // update the displayed profiles
    displayProfiles();

    // reset the form and close it
    profileForm.reset();
    addProfileSection.hidden = true;
});

// cancel button
cancelButton.addEventListener("click", function (event) {
    profileForm.reset();
    addProfileSection.hidden = true;
});

displayProfiles(); // to display profiles when page loads