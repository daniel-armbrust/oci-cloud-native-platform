const ADMIN_TOKEN_KEY = "admin_access_token";
const ADMIN_REFRESH_TOKEN_KEY = "admin_refresh_token";
const PIZZA_API_BASE_URL = (window.ADMIN_CONFIG && window.ADMIN_CONFIG.pizzaApiBaseUrl) || "http://localhost:8083";
const PIZZA_IMAGE_BASE_URL = (window.ADMIN_CONFIG && window.ADMIN_CONFIG.pizzaImageBaseUrl) || "";

const shellNode = document.querySelector("[data-pizza-id]");
const pageMessageNode = document.getElementById("page-message");
const logoutButton = document.getElementById("logout-button");
const pizzaForm = document.getElementById("pizza-form");
const pizzaImageFileInput = document.getElementById("pizza-image-file");
const uploadPizzaImageButton = document.getElementById("upload-pizza-image");
const pizzaImageUploadStatus = document.getElementById("pizza-image-upload-status");

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

function fillForm(pizza) {
    document.getElementById("pizza-id").value = pizza.id;
    document.getElementById("pizza-title").textContent = pizza.name;
    document.getElementById("pizza-subtitle").textContent = `${pizza.category} • ${pizza.available ? "disponivel" : "indisponivel"}`;
    document.getElementById("pizza-name").value = pizza.name;
    document.getElementById("pizza-slug").value = pizza.slug;
    document.getElementById("pizza-category").value = pizza.category;
    document.getElementById("pizza-description").value = pizza.description;
    document.getElementById("pizza-image-url").value = pizza.image_url;
    document.getElementById("pizza-price-small").value = Number(pizza.price_small || 0).toFixed(2);
    document.getElementById("pizza-price-medium").value = Number(pizza.price_medium || 0).toFixed(2);
    document.getElementById("pizza-price-large").value = Number(pizza.price_large || 0).toFixed(2);
    document.getElementById("pizza-available").value = String(Boolean(pizza.available));
    document.getElementById("pizza-status").textContent = pizza.available ? "Disponivel" : "Indisponivel";
    document.getElementById("pizza-summary-category").textContent = pizza.category || "-";
    document.getElementById("pizza-summary-small").textContent = `R$ ${Number(pizza.price_small || 0).toFixed(2)}`;
    document.getElementById("pizza-summary-medium").textContent = `R$ ${Number(pizza.price_medium || 0).toFixed(2)}`;
    document.getElementById("pizza-summary-large").textContent = `R$ ${Number(pizza.price_large || 0).toFixed(2)}`;
    document.getElementById("pizza-summary-image").textContent = pizza.image_url || "-";
    const previewNode = document.getElementById("pizza-summary-image-preview");
    const previewUrl = buildPizzaImageUrl(pizza.image_url);
    if (previewUrl) {
        previewNode.src = previewUrl;
        previewNode.alt = `Pizza ${pizza.name}`;
        previewNode.classList.remove("hidden");
    } else {
        previewNode.removeAttribute("src");
        previewNode.alt = "Preview da pizza indisponivel";
        previewNode.classList.add("hidden");
    }
    pizzaImageUploadStatus.textContent = "";
}

async function uploadPizzaImage() {
    const file = pizzaImageFileInput.files && pizzaImageFileInput.files[0];
    if (!file) {
        pizzaImageUploadStatus.textContent = "Selecione uma imagem antes do upload.";
        pizzaImageUploadStatus.style.color = "var(--danger)";
        return;
    }

    const formData = new FormData();
    formData.append("image", file);
    formData.append("slug", document.getElementById("pizza-slug").value.trim() || document.getElementById("pizza-name").value.trim() || "pizza");

    uploadPizzaImageButton.disabled = true;
    pizzaImageUploadStatus.textContent = "Enviando imagem...";
    pizzaImageUploadStatus.style.color = "var(--muted)";

    try {
        const response = await authorizedPizzaFetch("/pizzas/upload-image", {
            method: "POST",
            body: formData,
        });
        const payload = await response.json().catch(() => ({}));
        if (!response.ok || payload.status !== "success") {
            throw new Error(readPayloadMessage(payload, "Falha ao enviar imagem."));
        }

        document.getElementById("pizza-image-url").value = payload.data.image_url;
        document.getElementById("pizza-summary-image").textContent = payload.data.image_url;
        const previewNode = document.getElementById("pizza-summary-image-preview");
        const previewUrl = buildPizzaImageUrl(payload.data.image_url);
        if (previewUrl) {
            previewNode.src = previewUrl;
            previewNode.alt = `Pizza ${document.getElementById("pizza-name").value.trim() || "preview"}`;
            previewNode.classList.remove("hidden");
        }
        pizzaImageUploadStatus.textContent = "Imagem enviada com sucesso.";
        pizzaImageUploadStatus.style.color = "var(--primary)";
    } catch (error) {
        pizzaImageUploadStatus.textContent = error.message || "Nao foi possivel enviar a imagem.";
        pizzaImageUploadStatus.style.color = "var(--danger)";
    } finally {
        uploadPizzaImageButton.disabled = false;
    }
}

async function loadDetail() {
    setPageMessage("", false);
    const pizzaId = shellNode.dataset.pizzaId;

    try {
        const response = await authorizedPizzaFetch(`/pizzas/${pizzaId}`);
        const payload = await response.json().catch(() => ({}));
        if (!response.ok || payload.status !== "success") {
            throw new Error(readPayloadMessage(payload, "Falha ao carregar pizza."));
        }

        fillForm(payload.data);
    } catch (error) {
        setPageMessage(error.message || "Nao foi possivel carregar a pizza.");
    }
}

async function savePizza(event) {
    event.preventDefault();
    setPageMessage("", false);

    const pizzaId = document.getElementById("pizza-id").value;
    const submitButton = document.getElementById("save-pizza");
    submitButton.disabled = true;

    const payload = {
        name: document.getElementById("pizza-name").value.trim(),
        slug: document.getElementById("pizza-slug").value.trim(),
        description: document.getElementById("pizza-description").value.trim(),
        category: document.getElementById("pizza-category").value.trim(),
        image_url: document.getElementById("pizza-image-url").value.trim(),
        available: document.getElementById("pizza-available").value === "true",
        price_small: Number(document.getElementById("pizza-price-small").value),
        price_medium: Number(document.getElementById("pizza-price-medium").value),
        price_large: Number(document.getElementById("pizza-price-large").value),
    };

    try {
        const response = await authorizedPizzaFetch(`/pizzas/${pizzaId}`, {
            method: "PUT",
            body: JSON.stringify(payload),
        });
        const result = await response.json().catch(() => ({}));
        if (!response.ok || result.status !== "success") {
            throw new Error(readPayloadMessage(result, "Falha ao salvar pizza."));
        }

        setPageMessage("Pizza atualizada com sucesso.", false);
        showPopup("Pizza atualizada com sucesso.");
        await loadDetail();
    } catch (error) {
        setPageMessage(error.message || "Nao foi possivel salvar a pizza.");
    } finally {
        submitButton.disabled = false;
    }
}

if (ensureAdmin()) {
    logoutButton.addEventListener("click", logout);
    pizzaForm.addEventListener("submit", savePizza);
    uploadPizzaImageButton.addEventListener("click", uploadPizzaImage);
    loadDetail();
}
