const ADMIN_TOKEN_KEY = "admin_access_token";
const ADMIN_REFRESH_TOKEN_KEY = "admin_refresh_token";

const zonesListNode = document.getElementById("zones-list");
const zonesLoadingNode = document.getElementById("zones-loading");
const zonesEmptyNode = document.getElementById("zones-empty");
const pageMessageNode = document.getElementById("page-message");
const refreshButton = document.getElementById("refresh-zones");
const logoutButton = document.getElementById("logout-button");
const searchInput = document.getElementById("zone-search");
const searchButton = document.querySelector(".search-field__button");

let loadedZones = [];

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

function logout() {
    window.localStorage.removeItem(ADMIN_TOKEN_KEY);
    window.localStorage.removeItem(ADMIN_REFRESH_TOKEN_KEY);
    document.cookie = "admin=; Max-Age=0; path=/; SameSite=Lax";
    window.location.href = "/login";
}

function setPageMessage(text, isError = true) {
    pageMessageNode.textContent = text || "";
    pageMessageNode.style.color = isError ? "var(--danger)" : "var(--primary)";
}

function normalizeSearchValue(value) {
    return (value || "").toString().trim().toLowerCase();
}

function buildSearchTokens(value) {
    return normalizeSearchValue(value)
        .split(/[^a-z0-9]+/i)
        .filter(Boolean);
}

function matchesSearch(zone, query) {
    if (!query) return true;

    const queryTokens = buildSearchTokens(query);
    const candidateTokens = [
        zone.name,
        zone.city,
        zone.state,
        zone.neighborhood,
    ].flatMap(buildSearchTokens);

    return queryTokens.every((queryToken) =>
        candidateTokens.some((candidateToken) => candidateToken.startsWith(queryToken))
    );
}

async function authorizedFetch(url, options = {}) {
    const response = await fetch(url, {
        ...options,
        headers: {
            "Content-Type": "application/json",
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

function renderZones(zones) {
    if (!zones.length) {
        zonesEmptyNode.classList.remove("hidden");
        zonesListNode.innerHTML = "";
        return;
    }

    zonesEmptyNode.classList.add("hidden");
    zonesListNode.innerHTML = zones.map((zone) => `
        <a class="user-card" href="/admin/delivery-zones/${zone.id}" aria-label="Abrir detalhes da zona ${zone.name}">
            <div class="user-card__header">
                <div>
                    <h3>${zone.name}</h3>
                    <p>${[zone.city, zone.state, zone.neighborhood].filter(Boolean).join(" • ") || "Regiao nao informada"}</p>
                </div>
                <span class="pill ${zone.active ? "pill-status-active" : "pill-status-inactive"}">
                    ${zone.active ? "Ativa" : "Inativa"}
                </span>
            </div>
        </a>
    `).join("");
}

function applySearch() {
    const query = normalizeSearchValue(searchInput.value);
    const filteredZones = loadedZones.filter((zone) => matchesSearch(zone, query));
    const emptyText = query
        ? "Nenhuma zona combina com a pesquisa."
        : "Nenhuma zona de entrega encontrada.";

    zonesEmptyNode.textContent = emptyText;
    renderZones(filteredZones);
}

async function loadZones() {
    zonesLoadingNode.classList.remove("hidden");
    zonesEmptyNode.classList.add("hidden");
    zonesListNode.innerHTML = "";
    setPageMessage("", false);

    try {
        const response = await authorizedFetch("/api/admin/delivery-zones");
        const payload = await response.json().catch(() => ({}));
        if (!response.ok || payload.status !== "success") {
            throw new Error(payload.detail || payload.message || "Falha ao carregar delivery zones.");
        }
        loadedZones = payload.data || [];
        zonesLoadingNode.classList.add("hidden");
        applySearch();
    } catch (error) {
        loadedZones = [];
        zonesLoadingNode.classList.add("hidden");
        zonesEmptyNode.classList.remove("hidden");
        zonesEmptyNode.textContent = "Nao foi possivel carregar as delivery zones.";
        setPageMessage(error.message || "Erro ao buscar delivery zones.");
    }
}

if (ensureAdmin()) {
    refreshButton.addEventListener("click", loadZones);
    logoutButton.addEventListener("click", logout);
    searchInput.addEventListener("input", applySearch);
    searchButton.addEventListener("click", applySearch);
    loadZones();
}
