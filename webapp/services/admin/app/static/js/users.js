const ADMIN_TOKEN_KEY = "admin_access_token";
const ADMIN_REFRESH_TOKEN_KEY = "admin_refresh_token";

const usersListNode = document.getElementById("users-list");
const usersLoadingNode = document.getElementById("users-loading");
const usersEmptyNode = document.getElementById("users-empty");
const pageMessageNode = document.getElementById("page-message");
const logoutButton = document.getElementById("logout-button");
const searchInput = document.getElementById("user-search");
const searchButton = document.querySelector(".search-field__button");
const refreshButton = document.getElementById("refresh-users");
const openCreateUserButton = document.getElementById("open-create-user");
const createUserModal = document.getElementById("create-user-modal");
const closeCreateUserButton = document.getElementById("close-create-user");
const createUserForm = document.getElementById("create-user-form");
const createUserWhatsappInput = document.getElementById("create-user-whatsapp");

let loadedUsers = [];

function getAdminToken() {
    return window.localStorage.getItem(ADMIN_TOKEN_KEY);
}

function parseJwtPayload(token) {
    try {
        const payloadPart = token.split(".")[1];
        if (!payloadPart) return null;
        const base64 = payloadPart.replace(/-/g, "+").replace(/_/g, "/");
        const normalized = base64.padEnd(base64.length + ((4 - base64.length % 4) % 4), "=");
        return JSON.parse(window.atob(normalized));
    } catch (_err) {
        return null;
    }
}

function ensureAdmin() {
    const token = getAdminToken();
    const payload = token ? parseJwtPayload(token) : null;
    if (!payload || payload.role !== "admin" || payload.type !== "access") {
        window.location.href = "/login";
        return false;
    }
    return true;
}

function setPageMessage(text, isError = true) {
    pageMessageNode.textContent = text || "";
    pageMessageNode.style.color = isError ? "var(--danger)" : "var(--primary)";
}

function buildRolePill(role) {
    return role === "admin"
        ? '<span class="pill pill-role-admin">Admin</span>'
        : '<span class="pill pill-role-user">Usuario</span>';
}

function buildStatusPill(active) {
    return active
        ? '<span class="pill pill-status-active">Ativo</span>'
        : '<span class="pill pill-status-inactive">Inativo</span>';
}

function normalizeSearchValue(value) {
    return (value || "").toString().trim().toLowerCase();
}

function buildSearchTokens(value) {
    return normalizeSearchValue(value)
        .split(/[^a-z0-9]+/i)
        .filter(Boolean);
}

function matchesSearch(user, query) {
    if (!query) return true;

    const queryTokens = buildSearchTokens(query);
    const candidateTokens = [
        user.name,
        user.email,
        user.role,
        user.whatsapp,
    ].flatMap(buildSearchTokens);

    return queryTokens.every((queryToken) =>
        candidateTokens.some((candidateToken) => candidateToken.startsWith(queryToken))
    );
}

function renderUsers(users, emptyText = "Nenhum usuario encontrado.") {
    if (!users.length) {
        usersEmptyNode.classList.remove("hidden");
        usersEmptyNode.textContent = emptyText;
        usersListNode.innerHTML = "";
        return;
    }

    usersEmptyNode.classList.add("hidden");
    usersListNode.innerHTML = users.map((user) => `
        <a class="user-card" href="/admin/users/${user.id}" role="listitem">
            <div>
                <h3 class="user-card__name">${user.name}</h3>
                <div class="user-card__email">${user.email}</div>
            </div>
            <div class="pill-row">
                ${buildRolePill(user.role)}
                ${buildStatusPill(user.active)}
            </div>
            <div class="meta-line">${user.whatsapp || "Sem WhatsApp"}</div>
        </a>
    `).join("");
}

function showPopup(text) {
    window.alert(text);
}

function formatWhatsapp(value) {
    const digits = (value || "").replace(/\D/g, "").slice(0, 11);

    if (digits.length <= 2) return digits ? `(${digits}` : "";
    if (digits.length <= 7) return `(${digits.slice(0, 2)}) ${digits.slice(2)}`;
    if (digits.length <= 10) return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}-${digits.slice(6)}`;
    return `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7)}`;
}

function openCreateUserModal() {
    createUserModal.classList.remove("hidden");
    createUserModal.setAttribute("aria-hidden", "false");
}

function closeCreateUserModal() {
    createUserModal.classList.add("hidden");
    createUserModal.setAttribute("aria-hidden", "true");
    createUserForm.reset();
}

function applySearch() {
    const query = normalizeSearchValue(searchInput.value);
    const filteredUsers = loadedUsers.filter((user) => matchesSearch(user, query));
    const emptyText = query
        ? "Nenhum usuario combina com a pesquisa."
        : "Nenhum usuario encontrado.";

    renderUsers(filteredUsers, emptyText);
}

function logout() {
    window.localStorage.removeItem(ADMIN_TOKEN_KEY);
    window.localStorage.removeItem(ADMIN_REFRESH_TOKEN_KEY);
    document.cookie = "admin=; Max-Age=0; path=/; SameSite=Lax";
    window.location.href = "/login";
}

async function authorizedFetch(url, options = {}) {
    const response = await fetch(url, {
        ...options,
        headers: {
            ...(options.headers || {}),
            Authorization: `Bearer ${getAdminToken()}`,
        },
    });

    if (response.status === 401 || response.status === 403) {
        logout();
        throw new Error("Sessao invalida.");
    }

    return response;
}

async function loadUsers() {
    usersLoadingNode.classList.remove("hidden");
    usersEmptyNode.classList.add("hidden");
    usersListNode.innerHTML = "";
    setPageMessage("", false);

    try {
        const response = await authorizedFetch("/api/admin/users");
        const payload = await response.json().catch(() => ({}));

        if (!response.ok || payload.status !== "success") {
            throw new Error(payload.detail || payload.message || "Falha ao carregar usuarios.");
        }

        loadedUsers = payload.data || [];
        usersLoadingNode.classList.add("hidden");
        applySearch();
    } catch (error) {
        loadedUsers = [];
        usersLoadingNode.classList.add("hidden");
        usersEmptyNode.classList.remove("hidden");
        usersEmptyNode.textContent = "Nao foi possivel carregar os usuarios.";
        setPageMessage(error.message || "Erro ao buscar usuarios.");
    }
}

async function createUser(event) {
    event.preventDefault();
    setPageMessage("", false);

    const submitButton = document.getElementById("submit-create-user");
    submitButton.disabled = true;

    const payload = {
        name: document.getElementById("create-user-name").value.trim(),
        email: document.getElementById("create-user-email").value.trim(),
        whatsapp: document.getElementById("create-user-whatsapp").value.trim(),
        role: document.getElementById("create-user-role").value,
        active: document.getElementById("create-user-active").value === "true",
        password: document.getElementById("create-user-password").value,
    };

    try {
        const response = await authorizedFetch("/api/admin/users", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
        });
        const result = await response.json().catch(() => ({}));
        if (!response.ok || result.status !== "success") {
            throw new Error(result.detail || result.message || "Falha ao criar usuario.");
        }

        closeCreateUserModal();
        showPopup("Usuario criado com sucesso.");
        await loadUsers();
        window.location.href = `/admin/users/${result.data.id}`;
    } catch (error) {
        setPageMessage(error.message || "Nao foi possivel criar o usuario.");
    } finally {
        submitButton.disabled = false;
    }
}

if (ensureAdmin()) {
    logoutButton.addEventListener("click", logout);
    searchInput.addEventListener("input", applySearch);
    searchButton.addEventListener("click", applySearch);
    refreshButton.addEventListener("click", loadUsers);
    openCreateUserButton.addEventListener("click", openCreateUserModal);
    closeCreateUserButton.addEventListener("click", closeCreateUserModal);
    createUserModal.addEventListener("click", (event) => {
        if (event.target === createUserModal) closeCreateUserModal();
    });
    createUserWhatsappInput.addEventListener("input", (event) => {
        event.currentTarget.value = formatWhatsapp(event.currentTarget.value);
    });
    createUserForm.addEventListener("submit", createUser);
    loadUsers();
}
