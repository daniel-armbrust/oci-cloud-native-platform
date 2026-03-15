let currentPizza = null;
let pizzasById = {};

function buildPizzaApiUrl(apiHost) {
    const trimmedHost = (apiHost || "").replace(/\/$/, "");
    return trimmedHost ? `${trimmedHost}/pizzas` : "/api/pizzas";
}

function resolvePizzaImageUrl(imageUrl) {
    if (!imageUrl) {
        return "";
    }

    if (/^https?:\/\//i.test(imageUrl)) {
        return imageUrl;
    }

    const trimmedBase = (pizzaImageBaseUrl || "").replace(/\/$/, "");
    if (!trimmedBase) {
        return imageUrl;
    }

    return `${trimmedBase}/${encodeURIComponent(imageUrl)}`;
}

function normalizePizza(pizza) {
    return {
        ...pizza,
        image_url: resolvePizzaImageUrl(pizza.image_url),
    };
}

function formatPrice(value) {
    return new Intl.NumberFormat("pt-BR", {
        style: "currency",
        currency: "BRL",
    }).format(value || 0);
}

function getStartingPrice(pizza) {
    const sizes = Array.isArray(pizza.sizes) ? pizza.sizes : [];
    const prices = sizes
        .map((size) => Number(size.price))
        .filter((price) => !Number.isNaN(price));

    return prices.length ? Math.min(...prices) : 0;
}

function renderPizzaCard(pizza) {
    const startingPrice = getStartingPrice(pizza);

    return `
        <article class="pizza-card">
            <img class="pizza-image" src="${pizza.image_url}" alt="${pizza.name}" loading="lazy">
            <div class="pizza-body">
                <div class="d-flex justify-content-between align-items-start gap-3 mb-3">
                    <span class="pizza-category">${pizza.category}</span>
                    <span class="price-line">A partir de ${formatPrice(startingPrice)}</span>
                </div>
                <h2 class="h4 text-capitalize fw-bold">${pizza.name}</h2>
                <p class="pizza-description mb-4">${pizza.description || ""}</p>
                <button class="btn-pizza w-100" type="button" onclick="openPizzaDetailsById('${pizza.id}')">
                    Ver detalhes
                </button>
            </div>
        </article>
    `;
}

async function listOfPizzas(apiHost) {
    hideFlashMessage();

    try {
        const response = await fetch(buildPizzaApiUrl(apiHost));
        const payload = await response.json();

        if (!response.ok || payload.status !== "success") {
            throw new Error(payload.message || "Falha ao carregar pizzas.");
        }

        const pizzas = (payload.data || []).map(normalizePizza);
        pizzasById = Object.fromEntries(pizzas.map((pizza) => [pizza.id, pizza]));
        const appNode = document.getElementById("app");

        appNode.innerHTML = `
            <div class="pizza-grid">
                ${pizzas.map(renderPizzaCard).join("")}
            </div>
        `;
    } catch (error) {
        showFlashMessage(error.message || "Falha ao carregar pizzas.");
        document.getElementById("app").innerHTML = "";
    }
}

function openPizzaDetailsById(pizzaId) {
    const pizza = pizzasById[pizzaId];
    if (!pizza) {
        return;
    }

    currentPizza = pizza;

    document.getElementById("id_modal_pizza_details_title").textContent = pizza.name || "";
    document.getElementById("id_modal_pizza_details_description").textContent = pizza.description || "";

    const imageNode = document.getElementById("id_modal_pizza_details_image");
    imageNode.src = pizza.image_url || "";
    imageNode.alt = pizza.name || "";
    imageNode.title = pizza.name || "";

    document.getElementById("id_modal_pizza_details_id").value = pizza.id || "";
    document.getElementById("id_modal_pizza_details_price").textContent =
        `A partir de ${formatPrice(getStartingPrice(pizza))}`;

    const modalElement = document.getElementById("id_modal_pizza_details");
    const modal = bootstrap.Modal.getOrCreateInstance(modalElement);
    modal.show();
}

function addPizzaCart() {
    if (!currentPizza) {
        return;
    }

    showFlashMessage(`Pizza "${currentPizza.name}" pronta para ser integrada ao carrinho.`);
    const modalElement = document.getElementById("id_modal_pizza_details");
    const modal = bootstrap.Modal.getOrCreateInstance(modalElement);
    modal.hide();
}
