const DEFAULT_AUTH_BASE_URL = authApiHost || `${window.location.protocol}//${window.location.hostname}:8084`;
const LOGIN_AUTH_BASE_URL = DEFAULT_AUTH_BASE_URL.replace(/\/$/, "");

function setLoginMessage(text) {
    const messageNode = document.getElementById("message");
    if (!messageNode) {
        return;
    }

    messageNode.textContent = text || "";
}

function parseJwtPayload(token) {
    try {
        const payloadPart = token.split(".")[1];
        if (!payloadPart) {
            return null;
        }

        const base64 = payloadPart.replace(/-/g, "+").replace(/_/g, "/");
        const normalized = base64.padEnd(base64.length + ((4 - base64.length % 4) % 4), "=");
        return JSON.parse(window.atob(normalized));
    } catch (_err) {
        return null;
    }
}

function initLoginPage() {
    const form = document.getElementById("login-form");
    const submitBtn = document.getElementById("submit-btn");

    if (!form || !submitBtn) {
        return;
    }

    form.addEventListener("submit", async (event) => {
        event.preventDefault();
        setLoginMessage("");
        submitBtn.disabled = true;

        const email = form.email.value.trim();
        const password = form.password.value;

        if (!email || !password) {
            setLoginMessage("Informe email e senha.");
            submitBtn.disabled = false;
            return;
        }

        try {
            const response = await fetch(`${LOGIN_AUTH_BASE_URL}/auth`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({ email, password }),
            });

            const payload = await response.json().catch(() => ({}));

            if (!response.ok || payload.status !== "success") {
                setLoginMessage(payload.message || "Falha ao autenticar usuário.");
                submitBtn.disabled = false;
                return;
            }

            const accessToken = payload.data && payload.data.access_token;
            const refreshToken = payload.data && payload.data.refresh_token;

            if (!accessToken) {
                setLoginMessage("Resposta de autenticação inválida.");
                submitBtn.disabled = false;
                return;
            }

            localStorage.setItem("user_access_token", accessToken);

            if (refreshToken) {
                localStorage.setItem("refresh_token", refreshToken);
            }

            const tokenPayload = parseJwtPayload(accessToken);
            if (tokenPayload && tokenPayload.sub) {
                localStorage.setItem("user_id", tokenPayload.sub);
            }

            window.location.href = "/";
        } catch (_err) {
            setLoginMessage("Não foi possível conectar ao serviço de autenticação.");
            submitBtn.disabled = false;
        }
    });
}
