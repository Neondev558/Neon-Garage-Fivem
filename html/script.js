const isGame = !!window.invokeNative || window.location.protocol === 'nui:';
const resourceName = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'neon-garage';
const config = typeof GarageConfig === 'object' ? GarageConfig : {};

const NEON_SECRET = 'nG4-neon$garage-7pQ2x!auth';
let neonAuthorized = !isGame;
let neonPending = [];

function neonHash(str) {
    let h = 5381;
    for (let i = 0; i < str.length; i++) {
        h = (h * 33 + str.charCodeAt(i)) % 4294967296;
    }
    return h;
}

function neonRequestAuth() {
    if (!isGame) return;
    fetch(`https://${resourceName}/neonAuth`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: '{}',
    }).catch(() => {});
}

const $ = (id) => document.getElementById(id);

const state = {
    vehicles: [],
    selected: null,
    filter: 'all',
    search: '',
    sellArmed: false,
    sellTimer: null,
    toastTimer: null,
};

const PLACEHOLDER = 'data:image/svg+xml;utf8,' + encodeURIComponent(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 328 181" fill="none" stroke="#5cc8ff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" opacity="0.75">' +
    '<path d="M22 122h18m56 0h112m56 0h42v-22c0-8-6-14-14-15l-46-7-34-30c-5-4-11-6-17-6h-66c-8 0-15 4-20 10l-22 28-38 8c-8 2-13 8-13 16v18"/>' +
    '<circle cx="68" cy="124" r="22"/><circle cx="236" cy="124" r="22"/><path d="M96 78h110l-24-22c-3-3-7-4-11-4h-48c-5 0-9 2-12 6z"/></svg>'
);

function post(endpoint, data) {
    if (!isGame) return Promise.resolve(null);
    return fetch(`https://${resourceName}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {}),
    }).then((resp) => resp.json()).catch(() => null);
}

function clampPercent(value) {
    const number = Math.round(Number(value));
    if (!isFinite(number)) return 0;
    return Math.min(100, Math.max(0, number));
}

function formatMoney(value) {
    const number = Math.floor(Number(value) || 0);
    return (config.currency || '$') + number.toLocaleString('tr-TR');
}

function imageCandidates(model) {
    const key = String(model || '').trim();
    const lower = key.toLowerCase();
    const list = [];
    const custom = (config.vehicleImages || {})[lower] || (config.vehicleImages || {})[key];
    if (custom) {
        list.push(custom);
    }
    if (lower && config.onlineImages !== false) {
        const template = config.imageUrl || 'https://docs.fivem.net/vehicles/{model}.webp';
        list.push(template.replace('{model}', encodeURIComponent(lower)));
    }
    list.push(PLACEHOLDER);
    return list;
}

function setVehicleImage(img, model) {
    const candidates = imageCandidates(model);
    let index = 0;
    img.onerror = () => {
        index++;
        if (index < candidates.length) {
            img.src = candidates[index];
        } else {
            img.onerror = null;
        }
    };
    img.src = candidates[0];
}

function isOut(vehicle) {
    if (Number(vehicle.garaj) === 1) {
        return Number(vehicle.stored) !== 1;
    }
    return vehicle.impound === true || vehicle.impound === 'true';
}

function statusLabel(vehicle) {
    if (isOut(vehicle)) return 'Dışarıda';
    return Number(vehicle.garaj) === 1 ? 'Garajda' : 'Çekilmiş';
}

function matchesFilter(vehicle) {
    if (state.filter === 'in' && isOut(vehicle)) return false;
    if (state.filter === 'out' && !isOut(vehicle)) return false;
    if (!state.search) return true;
    const haystack = `${vehicle.name} ${vehicle.brand} ${vehicle.plate} ${vehicle.model}`.toLocaleLowerCase('tr-TR');
    return haystack.includes(state.search);
}

function renderList() {
    const list = $('vehicleList');
    list.textContent = '';
    const visible = state.vehicles.filter(matchesFilter);

    visible.forEach((vehicle, i) => {
        const card = document.createElement('li');
        card.className = 'card';
        if (isOut(vehicle)) card.classList.add('is-out');
        if (state.selected && state.selected.plate === vehicle.plate) card.classList.add('is-selected');
        card.style.setProperty('--d', `${Math.min(i, 12) * 0.035}s`);
        card.dataset.plate = vehicle.plate;

        const thumb = document.createElement('div');
        thumb.className = 'card-thumb';
        const img = document.createElement('img');
        img.alt = '';
        setVehicleImage(img, vehicle.model);
        thumb.appendChild(img);

        const text = document.createElement('div');
        text.className = 'card-text';
        const brand = document.createElement('span');
        brand.className = 'card-brand';
        brand.textContent = vehicle.brand || '';
        const name = document.createElement('span');
        name.className = 'card-name';
        name.textContent = vehicle.name || vehicle.model || '';
        const plate = document.createElement('span');
        plate.className = 'card-plate';
        plate.textContent = vehicle.plate || '';
        text.appendChild(brand);
        text.appendChild(name);
        text.appendChild(plate);

        const dot = document.createElement('i');
        dot.className = 'card-dot';

        card.appendChild(thumb);
        card.appendChild(text);
        card.appendChild(dot);
        card.addEventListener('click', () => selectVehicle(vehicle));
        list.appendChild(card);
    });

    $('listEmpty').hidden = visible.length > 0;
    $('vehicleCount').textContent = String(state.vehicles.length).padStart(2, '0');
}

function setMeter(meterId, labelId, value) {
    const percent = clampPercent(value);
    const meter = $(meterId);
    meter.style.width = `${percent}%`;
    meter.classList.toggle('is-low', percent < 30);
    $(labelId).textContent = `${percent}%`;
}

function disarmSell() {
    state.sellArmed = false;
    clearTimeout(state.sellTimer);
    const button = $('sellBtn');
    button.classList.remove('is-armed');
    button.textContent = 'Sat';
}

function selectVehicle(vehicle) {
    state.selected = vehicle;
    disarmSell();

    document.querySelectorAll('.card').forEach((card) => {
        card.classList.toggle('is-selected', card.dataset.plate === vehicle.plate);
    });

    const image = $('detailImage');
    image.classList.remove('is-swapping');
    void image.offsetWidth;
    image.classList.add('is-swapping');
    setVehicleImage(image, vehicle.model);

    $('detailBrand').textContent = vehicle.brand || '';
    $('detailName').textContent = vehicle.name || vehicle.model || '';
    $('detailPlate').textContent = vehicle.plate || '';
    $('detailPrice').textContent = formatMoney(vehicle.vehicleprice);

    const out = isOut(vehicle);
    const status = $('detailStatus');
    status.classList.toggle('is-out', out);
    status.querySelector('b').textContent = statusLabel(vehicle);
    $('spawnBtn').classList.toggle('is-disabled', out);

    setMeter('meterEngine', 'statEngine', vehicle.damage);
    setMeter('meterBody', 'statBody', vehicle.body);
    setMeter('meterFuel', 'statFuel', vehicle.fuellevel);

    $('sellCard').hidden = vehicle.sellcar === false;
    $('transferCard').hidden = vehicle.transferCar === false;
}

function notify(text, type) {
    const toast = $('toast');
    toast.textContent = text;
    toast.className = 'toast';
    if (type === 'error') toast.classList.add('is-error');
    if (type === 'success') toast.classList.add('is-success');
    toast.hidden = false;
    void toast.offsetWidth;
    clearTimeout(state.toastTimer);
    state.toastTimer = setTimeout(() => {
        toast.hidden = true;
    }, 3000);
}

function resetGarage() {
    state.vehicles = [];
    state.selected = null;
    state.search = '';
    state.filter = 'all';
    $('searchInput').value = '';
    $('transferInput').value = '';
    document.querySelectorAll('.filter').forEach((button) => {
        button.classList.toggle('is-active', button.dataset.filter === 'all');
    });
    disarmSell();
    $('vehicleList').textContent = '';
}

function closeGarage() {
    $('garage').hidden = true;
    resetGarage();
    post('closepage');
}

function addVehicle(data) {
    const vehicle = {
        plate: String(data.plate || ''),
        model: String(data.model || ''),
        name: data.name,
        brand: data.brand,
        carhash: data.carhash,
        damage: data.damage,
        body: data.body,
        fuellevel: data.fuellevel,
        vehicleprice: data.vehicleprice,
        stored: data.stored,
        garaj: data.garaj,
        impound: data.impound,
        sellcar: data.sellcar,
        transferCar: data.transferCar,
    };

    const existing = state.vehicles.findIndex((v) => v.plate === vehicle.plate);
    if (existing >= 0) {
        state.vehicles[existing] = vehicle;
    } else {
        state.vehicles.push(vehicle);
    }

    $('garage').hidden = false;
    renderList();
    if (!state.selected || state.selected.plate === vehicle.plate) {
        selectVehicle(state.selected ? vehicle : state.vehicles[0]);
    }
}

window.addEventListener('message', (event) => {
    const data = event.data || {};

    if (data.action === 'auth') {
        if (!neonAuthorized
            && typeof data.key === 'string'
            && typeof data.nonce === 'string'
            && typeof data.resource === 'string'
            && data.key === String(neonHash(NEON_SECRET + data.nonce + data.resource))) {
            neonAuthorized = true;
            const queued = neonPending;
            neonPending = [];
            queued.forEach(addVehicle);
        }
        return;
    }

    if (data.action === 'open') {
        if (!neonAuthorized) {
            if (neonPending.length < 60) neonPending.push(data);
            neonRequestAuth();
            return;
        }
        addVehicle(data);
    } else if (data.action === 'notify') {
        notify(data.message, data.type);
    } else if (data.action === 'reset') {
        resetGarage();
    }
});

neonRequestAuth();

$('garageTitle').textContent = config.title || 'Garaj';
$('garageKicker').textContent = config.subtitle || '';

if (config.logo) {
    const logo = $('garageLogo');
    const src = /^(https?:)?\/\//i.test(config.logo) ? config.logo : `./${config.logo}`;
    logo.onload = () => { logo.hidden = false; };
    logo.onerror = () => { logo.hidden = true; };
    logo.src = isGame ? src : `${src}?t=${Date.now()}`;
}

$('closeBtn').addEventListener('click', closeGarage);

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !$('garage').hidden) {
        closeGarage();
    }
});

$('searchInput').addEventListener('input', (e) => {
    state.search = e.target.value.trim().toLocaleLowerCase('tr-TR');
    renderList();
});

$('filters').addEventListener('click', (e) => {
    const button = e.target.closest('.filter');
    if (!button) return;
    state.filter = button.dataset.filter;
    document.querySelectorAll('.filter').forEach((item) => {
        item.classList.toggle('is-active', item === button);
    });
    renderList();
});

$('spawnBtn').addEventListener('click', () => {
    const vehicle = state.selected;
    if (!vehicle) {
        return notify('Önce bir araç seç', 'error');
    }
    if (isOut(vehicle)) {
        return notify('Araç garajda değil', 'error');
    }
    post('spawnvehicle', { plate: vehicle.plate, model: vehicle.model });
    closeGarage();
});

$('transferBtn').addEventListener('click', () => {
    const vehicle = state.selected;
    const id = parseInt($('transferInput').value, 10);
    if (!vehicle) {
        return notify('Önce bir araç seç', 'error');
    }
    if (!id || id < 1) {
        return notify('Geçerli bir oyuncu ID gir', 'error');
    }
    post('transfervehicle', { plate: vehicle.plate, id: id });
    closeGarage();
});

$('sellBtn').addEventListener('click', () => {
    const vehicle = state.selected;
    if (!vehicle) {
        return notify('Önce bir araç seç', 'error');
    }

    if (!state.sellArmed) {
        state.sellArmed = true;
        const button = $('sellBtn');
        button.classList.add('is-armed');
        button.textContent = 'Emin misin?';
        state.sellTimer = setTimeout(disarmSell, 4000);
        return;
    }

    disarmSell();
    post('sellvehicle', {
        plate: vehicle.plate,
        hash: vehicle.carhash,
        price: vehicle.vehicleprice,
    }).then((blocked) => {
        if (blocked === true) {
            notify('Bu araç satılamaz', 'error');
        } else {
            closeGarage();
        }
    });
});

if (!isGame) {
    const demo = [
        { model: 'adder', name: 'Adder', brand: 'Truffade', plate: '42RIV421', damage: 96, body: 91, fuellevel: 78, vehicleprice: 500000, stored: 1 },
        { model: 'sultanrs', name: 'Sultan RS', brand: 'Karin', plate: 'NEON0077', damage: 74, body: 62, fuellevel: 41, vehicleprice: 47500, stored: 1 },
        { model: 'bati', name: 'Bati 801', brand: 'Pegassi', plate: '8KDT1293', damage: 100, body: 100, fuellevel: 95, vehicleprice: 12000, stored: 0 },
        { model: 'kuruma', name: 'Kuruma', brand: 'Karin', plate: 'BRT20411', damage: 22, body: 35, fuellevel: 12, vehicleprice: 31000, stored: 1 },
        { model: 'granger', name: 'Granger', brand: 'Declasse', plate: '61XPN882', damage: 88, body: 80, fuellevel: 66, vehicleprice: 22000, stored: 1 },
        { model: 'rmodmk7', name: 'R Mod Mk7', brand: 'Addon', plate: 'ADDON001', damage: 90, body: 97, fuellevel: 54, vehicleprice: 150000, stored: 1 },
        { model: 'comet2', name: 'Comet', brand: 'Pfister', plate: '5LSN7710', damage: 67, body: 71, fuellevel: 83, vehicleprice: 60000, stored: 0 },
    ];
    demo.forEach((vehicle, i) => {
        setTimeout(() => {
            window.postMessage(Object.assign({ action: 'open', garaj: 1, sellcar: true, transferCar: true, carhash: i + 1 }, vehicle), '*');
        }, 60 * i);
    });
}
