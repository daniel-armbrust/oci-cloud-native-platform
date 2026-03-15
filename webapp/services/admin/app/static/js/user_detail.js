const ADMIN_TOKEN_KEY = "admin_access_token";
const ADMIN_REFRESH_TOKEN_KEY = "admin_refresh_token";

const shellNode = document.querySelector("[data-user-id]");
const pageMessageNode = document.getElementById("page-message");
const logoutButton = document.getElementById("logout-button");
const userForm = document.getElementById("user-form");

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

function formatDate(value) {
    if (!value) return "-";
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime())
        ? value
        : new Intl.DateTimeFormat("pt-BR", { dateStyle: "short", timeStyle: "short" }).format(parsed);
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

function renderAddresses(addresses) {
    const listNode = document.getElementById("addresses-list");
    const emptyNode = document.getElementById("addresses-empty");

    if (!addresses.length) {
        emptyNode.classList.remove("hidden");
        listNode.innerHTML = "";
        return;
    }

    emptyNode.classList.add("hidden");
    listNode.innerHTML = addresses.map((address) => `
        <article class="stack-card">
            <h3>${address.street}, ${address.number || "s/n"}</h3>
            <p>${[address.complement, address.neighborhood, address.city, address.state, address.zip_code].filter(Boolean).join(" | ")}</p>
            <div class="pill-row">
                ${address.is_default ? '<span class="pill pill-status-active">Padrao</span>' : '<span class="pill pill-role-user">Secundario</span>'}
            </div>
        </article>
    `).join("");
}

function renderOrders(orders) {
    const listNode = document.getElementById("orders-list");
    const emptyNode = document.getElementById("orders-empty");

    if (!orders.length) {
        emptyNode.classList.remove("hidden");
        listNode.innerHTML = "";
        return;
    }

    emptyNode.classList.add("hidden");
    listNode.innerHTML = orders.map((order) => `
        <article class="stack-card">
            <h3>Pedido ${order.id}</h3>
            <p>Status: ${order.status} | Total: R$ ${Number(order.total_amount || 0).toFixed(2)}</p>
            <p>${order.delivery_address || "Endereco nao informado"}</p>
            <p>${formatDate(order.created_at)}</p>
            <div class="order-items">
                ${order.items.map((item) => `
                    <div class="order-item">
                        <span>${item.pizza_name} (${item.size || "sem tamanho"})</span>
                        <strong>${item.quantity} x R$ ${Number(item.price || 0).toFixed(2)}</strong>
                    </div>
                `).join("")}
            </div>
        </article>
    `).join("");
}

function fillForm(user) {
    document.getElementById("user-id").value = user.id;
    document.getElementById("user-title").textContent = user.name;
    document.getElementById("user-subtitle").textContent = `${user.email} • ${user.role}`;
    document.getElementById("user-name").value = user.name;
    document.getElementById("user-email").value = user.email;
    document.getElementById("user-whatsapp").value = user.whatsapp || "";
    document.getElementById("user-role").value = user.role;
    document.getElementById("user-active").value = String(Boolean(user.active));
    document.getElementById("user-password").value = "";
    document.getElementById("user-created-at").textContent = formatDate(user.created_at);
    document.getElementById("user-updated-at").textContent = formatDate(user.updated_at);
}

async function loadDetail() {
    setPageMessage("", false);
    const userId = shellNode.dataset.userId;

    try {
        const response = await authorizedFetch(`/api/admin/users/${userId}`);
        const payload = await response.json().catch(() => ({}));
        if (!response.ok || payload.status !== "success") {
            throw new Error(payload.detail || payload.message || "Falha ao carregar usuario.");
        }

        fillForm(payload.data.user);
        renderAddresses(payload.data.addresses || []);
        renderOrders(payload.data.orders || []);
    } catch (error) {
        setPageMessage(error.message || "Nao foi possivel carregar o usuario.");
    }
}

async function saveUser(event) {
    event.preventDefault();
    setPageMessage("", false);

    const userId = document.getElementById("user-id").value;
    const submitButton = document.getElementById("save-user");
    submitButton.disabled = true;

    const payload = {
        name: document.getElementById("user-name").value.trim(),
        email: document.getElementById("user-email").value.trim(),
        whatsapp: document.getElementById("user-whatsapp").value.trim(),
        role: document.getElementById("user-role").value,
        active: document.getElementById("user-active").value === "true",
        password: document.getElementById("user-password").value,
    };

    if (!payload.password) delete payload.password;

    try {
        const response = await authorizedFetch(`/api/admin/users/${userId}`, {
            method: "PUT",
            body: JSON.stringify(payload),
        });
        const result = await response.json().catch(() => ({}));
        if (!response.ok || result.status !== "success") {
            throw new Error(result.detail || result.message || "Falha ao salvar usuario.");
        }

        setPageMessage("Usuario atualizado com sucesso.", false);
        showPopup("Dados do usuario atualizados com sucesso.");
        await loadDetail();
    } catch (error) {
        setPageMessage(error.message || "Nao foi possivel salvar o usuario.");
    } finally {
        submitButton.disabled = false;
    }
}

if (ensureAdmin()) {
    logoutButton.addEventListener("click", logout);
    userForm.addEventListener("submit", saveUser);
    loadDetail();
}
