const DEFAULT_AUTH_BASE_URL = `${window.location.protocol}//${window.location.hostname}:8084`;
const AUTH_BASE_URL = window.__AUTH_BASE_URL || DEFAULT_AUTH_BASE_URL;

const form = document.getElementById("login-form");
const submitBtn = document.getElementById("submit-btn");
const message = document.getElementById("message");

function setMessage(text) {
    message.textContent = text || "";
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

form.addEventListener("submit", async (event) => {
    event.preventDefault();
    setMessage("");
    submitBtn.disabled = true;

    const email = form.email.value.trim();
    const password = form.password.value;

    if (!email || !password) {
        setMessage("Informe email e senha.");
        submitBtn.disabled = false;
        return;
    }

    try {
        const response = await fetch(`${AUTH_BASE_URL}/auth`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ email, password })
        });

        const data = await response.json().catch(() => ({}));

        if (!response.ok || data.status !== "success") {
            const errorMessage = data.message || "Falha ao autenticar usuário.";
            setMessage(errorMessage);
            submitBtn.disabled = false;
            return;
        }

        const accessToken = data.data && data.data.access_token;
        const refreshToken = data.data && data.data.refresh_token;

        if (!accessToken) {
            setMessage("Resposta de autenticação inválida.");
            submitBtn.disabled = false;
            return;
        }

        localStorage.setItem("admin_access_token", accessToken);
        if (refreshToken) {
            localStorage.setItem("admin_refresh_token", refreshToken);
        }

        const payload = parseJwtPayload(accessToken);
        const adminId = payload && payload.sub ? payload.sub : "authenticated";
        document.cookie = `admin=${encodeURIComponent(adminId)}; path=/; SameSite=Lax`;

        window.location.href = "/admin/users";
    } catch (_err) {
        setMessage("Não foi possível conectar ao serviço de autenticação.");
        submitBtn.disabled = false;
    }
});
