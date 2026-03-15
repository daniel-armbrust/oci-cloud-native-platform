const ADMIN_TOKEN_KEY = "admin_access_token";
const ADMIN_REFRESH_TOKEN_KEY = "admin_refresh_token";
const PIZZA_API_BASE_URL = (window.ADMIN_CONFIG && window.ADMIN_CONFIG.pizzaApiBaseUrl) || "http://localhost:8083";
const PIZZA_IMAGE_BASE_URL = (window.ADMIN_CONFIG && window.ADMIN_CONFIG.pizzaImageBaseUrl) || "";

const pizzasListNode = document.getElementById("pizzas-list");
const pizzasLoadingNode = document.getElementById("pizzas-loading");
const pizzasEmptyNode = document.getElementById("pizzas-empty");
const pageMessageNode = document.getElementById("page-message");
const refreshButton = document.getElementById("refresh-pizzas");
const logoutButton = document.getElementById("logout-button");
const searchInput = document.getElementById("pizza-search");
const searchButton = document.querySelector(".search-field__button");
const openCreatePizzaButton = document.getElementById("open-create-pizza");
const createPizzaModal = document.getElementById("create-pizza-modal");
const closeCreatePizzaButton = document.getElementById("close-create-pizza");
const createPizzaForm = document.getElementById("create-pizza-form");
const createPizzaImageFileInput = document.getElementById("create-pizza-image-file");
const uploadCreatePizzaImageButton = document.getElementById("upload-create-pizza-image");
const createPizzaImageUploadStatus = document.getElementById("create-pizza-image-upload-status");

let loadedPizzas = [];

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

function showPopup(text) {
    window.alert(text);
}

function buildPizzaApiUrl(path = "") {
    return `${PIZZA_API_BASE_URL.replace(/\/$/, "")}${path}`;
}

function buildPizzaImageUrl(imageName) {
    if (!imageName || !PIZZA_IMAGE_BASE_URL) return "";
    return `${PIZZA_IMAGE_BASE_URL.replace(/\/$/, "")}/${encodeURIComponent(imageName)}`;
}

function normalizeSearchValue(value) {
    return (value || "").toString().trim().toLowerCase();
}

function buildSearchTokens(value) {
    return normalizeSearchValue(value)
        .split(/[^a-z0-9]+/i)
        .filter(Boolean);
}

function matchesSearch(pizza, query) {
    if (!query) return true;

    const queryTokens = buildSearchTokens(query);
    const candidateTokens = [
        pizza.name,
        pizza.slug,
        pizza.category,
        pizza.description,
    ].flatMap(buildSearchTokens);

    return queryTokens.every((queryToken) =>
        candidateTokens.some((candidateToken) => candidateToken.startsWith(queryToken))
    );
}

async function authorizedFetch(url, options = {}) {
    const headers = {
        ...(options.headers || {}),
        Authorization: `Bearer ${getAdminToken()}`,
    };

    if (!(options.body instanceof FormData) && !headers["Content-Type"]) {
        headers["Content-Type"] = "application/json";
    }

    const response = await fetch(url, {
        ...options,
        headers,
    });

    if (response.status === 401 || response.status === 403) {
        logout();
        throw new Error("Sessao invalida.");
    }

    return response;
}

async function authorizedPizzaFetch(path, options = {}) {
    return authorizedFetch(buildPizzaApiUrl(path), options);
}

function readPayloadMessage(payload, fallback) {
    return payload?.detail || payload?.message || payload?.data?.message || fallback;
}

function openCreatePizzaModal() {
    createPizzaModal.classList.remove("hidden");
    createPizzaModal.setAttribute("aria-hidden", "false");
    createPizzaImageUploadStatus.textContent = "";
}

function closeCreatePizzaModal() {
    createPizzaModal.classList.add("hidden");
    createPizzaModal.setAttribute("aria-hidden", "true");
    createPizzaForm.reset();
    createPizzaImageUploadStatus.textContent = "";
}

function buildAvailabilityPill(available) {
    return available
        ? '<span class="pill pill-status-active">Disponivel</span>'
        : '<span class="pill pill-status-inactive">Indisponivel</span>';
}

function renderPizzas(pizzas) {
    if (!pizzas.length) {
        pizzasEmptyNode.classList.remove("hidden");
        pizzasListNode.innerHTML = "";
        return;
    }

    pizzasEmptyNode.classList.add("hidden");
    pizzasListNode.innerHTML = pizzas.map((pizza) => `
        <a class="user-card" href="/admin/cardapio/${pizza.id}" role="listitem">
            ${buildPizzaImageUrl(pizza.image_url) ? `<img class="pizza-card-image" src="${buildPizzaImageUrl(pizza.image_url)}" alt="Pizza ${pizza.name}">` : ""}
            <div>
                <h3 class="user-card__name">${pizza.name}</h3>
            </div>
            <div class="pill-row">
                ${buildAvailabilityPill(pizza.available)}
            </div>
        </a>
    `).join("");
}

function applySearch() {
    const query = normalizeSearchValue(searchInput.value);
    const filteredPizzas = loadedPizzas.filter((pizza) => matchesSearch(pizza, query));
    const emptyText = query
        ? "Nenhuma pizza combina com a pesquisa."
        : "Nenhuma pizza encontrada.";

    pizzasEmptyNode.textContent = emptyText;
    renderPizzas(filteredPizzas);
}

async function loadPizzas() {
    pizzasLoadingNode.classList.remove("hidden");
    pizzasEmptyNode.classList.add("hidden");
    pizzasListNode.innerHTML = "";
    setPageMessage("", false);

    try {
        const response = await authorizedPizzaFetch("/pizzas");
        const payload = await response.json().catch(() => ({}));
        if (!response.ok || payload.status !== "success") {
            throw new Error(readPayloadMessage(payload, "Falha ao carregar cardapio."));
        }
        loadedPizzas = payload.data || [];
        pizzasLoadingNode.classList.add("hidden");
        applySearch();
    } catch (error) {
        loadedPizzas = [];
        pizzasLoadingNode.classList.add("hidden");
        pizzasEmptyNode.classList.remove("hidden");
        pizzasEmptyNode.textContent = "Nao foi possivel carregar o cardapio.";
        setPageMessage(error.message || "Erro ao buscar pizzas.");
    }
}

async function createPizza(event) {
    event.preventDefault();
    setPageMessage("", false);

    const submitButton = document.getElementById("submit-create-pizza");
    submitButton.disabled = true;

    const payload = {
        name: document.getElementById("create-pizza-name").value.trim(),
        slug: document.getElementById("create-pizza-slug").value.trim(),
        description: document.getElementById("create-pizza-description").value.trim(),
        category: document.getElementById("create-pizza-category").value.trim(),
        image_url: document.getElementById("create-pizza-image-url").value.trim(),
        available: document.getElementById("create-pizza-available").value === "true",
        price_small: Number(document.getElementById("create-pizza-price-small").value),
        price_medium: Number(document.getElementById("create-pizza-price-medium").value),
        price_large: Number(document.getElementById("create-pizza-price-large").value),
    };

    try {
        const response = await authorizedPizzaFetch("/pizzas", {
            method: "POST",
            body: JSON.stringify(payload),
        });
        const result = await response.json().catch(() => ({}));
        if (!response.ok || result.status !== "success") {
            throw new Error(readPayloadMessage(result, "Falha ao criar pizza."));
        }
        closeCreatePizzaModal();
        showPopup("Pizza criada com sucesso.");
        await loadPizzas();
        window.location.href = `/admin/cardapio/${result.data.id}`;
    } catch (error) {
        setPageMessage(error.message || "Nao foi possivel criar a pizza.");
    } finally {
        submitButton.disabled = false;
    }
}

async function uploadPizzaImage(fileInput, imageUrlInputId, statusNode, actionButton, fallbackNameInputId, fallbackSlugInputId) {
    const file = fileInput.files && fileInput.files[0];
    if (!file) {
        statusNode.textContent = "Selecione uma imagem antes do upload.";
        statusNode.style.color = "var(--danger)";
        return;
    }

    const nameValue = document.getElementById(fallbackNameInputId)?.value.trim();
    const slugValue = document.getElementById(fallbackSlugInputId)?.value.trim();
    const formData = new FormData();
    formData.append("image", file);
    formData.append("slug", slugValue || nameValue || "pizza");

    actionButton.disabled = true;
    statusNode.textContent = "Enviando imagem...";
    statusNode.style.color = "var(--muted)";

    try {
        const response = await authorizedPizzaFetch("/pizzas/upload-image", {
            method: "POST",
            body: formData,
        });
        const payload = await response.json().catch(() => ({}));
        if (!response.ok || payload.status !== "success") {
            throw new Error(readPayloadMessage(payload, "Falha ao enviar imagem."));
        }

        document.getElementById(imageUrlInputId).value = payload.data.image_url;
        statusNode.textContent = "Imagem enviada com sucesso.";
        statusNode.style.color = "var(--primary)";
    } catch (error) {
        statusNode.textContent = error.message || "Nao foi possivel enviar a imagem.";
        statusNode.style.color = "var(--danger)";
    } finally {
        actionButton.disabled = false;
    }
}

if (ensureAdmin()) {
    refreshButton.addEventListener("click", loadPizzas);
    logoutButton.addEventListener("click", logout);
    searchInput.addEventListener("input", applySearch);
    searchButton.addEventListener("click", applySearch);
    openCreatePizzaButton.addEventListener("click", openCreatePizzaModal);
    closeCreatePizzaButton.addEventListener("click", closeCreatePizzaModal);
    createPizzaModal.addEventListener("click", (event) => {
        if (event.target === createPizzaModal) closeCreatePizzaModal();
    });
    createPizzaForm.addEventListener("submit", createPizza);
    uploadCreatePizzaImageButton.addEventListener("click", () =>
        uploadPizzaImage(
            createPizzaImageFileInput,
            "create-pizza-image-url",
            createPizzaImageUploadStatus,
            uploadCreatePizzaImageButton,
            "create-pizza-name",
            "create-pizza-slug",
        )
    );
    loadPizzas();
}
