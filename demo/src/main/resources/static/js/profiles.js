// Select an existing profile
function selectProfile(profileName) {
    alert("You selected " + profileName);
}

// Add a new profile
function addProfile() {
    const profileName = prompt("Enter a name for your new profile:");

    if (profileName === null) {
        return;
    }

    if (profileName.trim() === "") {
        alert("Please enter a profile name.");
        return;
    }

    alert("Profile " + profileName + " has been created!");
}
