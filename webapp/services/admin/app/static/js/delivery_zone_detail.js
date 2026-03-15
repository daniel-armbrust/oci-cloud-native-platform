const ADMIN_TOKEN_KEY = "admin_access_token";
const ADMIN_REFRESH_TOKEN_KEY = "admin_refresh_token";

const shellNode = document.querySelector("[data-zone-id]");
const pageMessageNode = document.getElementById("page-message");
const logoutButton = document.getElementById("logout-button");
const zoneForm = document.getElementById("zone-form");

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

function fillForm(zone) {
    document.getElementById("zone-id").value = zone.id;
    document.getElementById("zone-title").textContent = zone.name;
    document.getElementById("zone-subtitle").textContent =
        `${[zone.city, zone.state, zone.neighborhood].filter(Boolean).join(" • ") || "Regiao nao informada"} • ${zone.active ? "ativa" : "inativa"}`;
    document.getElementById("zone-name").value = zone.name;
    document.getElementById("zone-city").value = zone.city || "";
    document.getElementById("zone-state").value = zone.state || "";
    document.getElementById("zone-neighborhood").value = zone.neighborhood || "";
    document.getElementById("zone-delivery-fee").value = Number(zone.delivery_fee || 0).toFixed(2);
    document.getElementById("zone-active").value = String(Boolean(zone.active));
    document.getElementById("zone-status").textContent = zone.active ? "Ativa" : "Inativa";
    document.getElementById("zone-summary-city").textContent = zone.city || "-";
    document.getElementById("zone-summary-state").textContent = zone.state || "-";
    document.getElementById("zone-summary-neighborhood").textContent = zone.neighborhood || "-";
    document.getElementById("zone-summary-fee").textContent = `R$ ${Number(zone.delivery_fee || 0).toFixed(2)}`;
}

async function loadDetail() {
    setPageMessage("", false);
    const zoneId = shellNode.dataset.zoneId;

    try {
        const response = await authorizedFetch(`/api/admin/delivery-zones/${zoneId}`);
        const payload = await response.json().catch(() => ({}));
        if (!response.ok || payload.status !== "success") {
            throw new Error(payload.detail || payload.message || "Falha ao carregar zona.");
        }

        fillForm(payload.data);
    } catch (error) {
        setPageMessage(error.message || "Nao foi possivel carregar a zona.");
    }
}

async function saveZone(event) {
    event.preventDefault();
    setPageMessage("", false);

    const zoneId = document.getElementById("zone-id").value;
    const submitButton = document.getElementById("save-zone");
    submitButton.disabled = true;

    const payload = {
        name: document.getElementById("zone-name").value.trim(),
        city: document.getElementById("zone-city").value.trim(),
        state: document.getElementById("zone-state").value.trim(),
        neighborhood: document.getElementById("zone-neighborhood").value.trim(),
        delivery_fee: Number(document.getElementById("zone-delivery-fee").value),
        active: document.getElementById("zone-active").value === "true",
    };

    try {
        const response = await authorizedFetch(`/api/admin/delivery-zones/${zoneId}`, {
            method: "PUT",
            body: JSON.stringify(payload),
        });
        const result = await response.json().catch(() => ({}));
        if (!response.ok || result.status !== "success") {
            throw new Error(result.detail || result.message || "Falha ao salvar zona.");
        }

        setPageMessage("Zona de entrega atualizada com sucesso.", false);
        showPopup("Zona de entrega atualizada com sucesso.");
        await loadDetail();
    } catch (error) {
        setPageMessage(error.message || "Nao foi possivel salvar a zona.");
    } finally {
        submitButton.disabled = false;
    }
}

if (ensureAdmin()) {
    logoutButton.addEventListener("click", logout);
    zoneForm.addEventListener("submit", saveZone);
    loadDetail();
}
