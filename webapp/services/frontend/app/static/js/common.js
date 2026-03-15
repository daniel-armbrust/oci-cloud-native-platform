function updatePizzaCartItemCount() {
    return 0;
}

function hasStoredSession() {
    const keys = [
        "user_access_token",
        "access_token",
        "auth_access_token",
        "token",
        "refresh_token",
    ];

    return keys.some((key) => window.localStorage.getItem(key));
}

function updateHeroMenu(authenticated) {
    document.querySelectorAll("[data-guest-only]").forEach((node) => {
        node.classList.toggle("d-none", authenticated);
    });

    document.querySelectorAll("[data-auth-only]").forEach((node) => {
        node.classList.toggle("d-none", !authenticated);
    });
}

function logoutUser() {
    [
        "user_access_token",
        "access_token",
        "auth_access_token",
        "token",
        "refresh_token",
    ].forEach((key) => window.localStorage.removeItem(key));

    updateHeroMenu(false);
}

function initHeroMenu() {
    updateHeroMenu(hasStoredSession());

    document.querySelectorAll('[data-action="logout"]').forEach((node) => {
        node.addEventListener("click", (event) => {
            event.preventDefault();
            logoutUser();
        });
    });
}

function showFlashMessage(message) {
    const node = document.getElementById("flash-message");
    if (!node) {
        return;
    }

    node.textContent = message;
    node.classList.remove("d-none");
}

function hideFlashMessage() {
    const node = document.getElementById("flash-message");
    if (!node) {
        return;
    }

    node.textContent = "";
    node.classList.add("d-none");
}
