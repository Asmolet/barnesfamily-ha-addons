#!/usr/bin/with-contenv bashio

set -u

NEST_HUB="$(bashio::config 'nest_hub')"
DASHBOARD_URL="$(bashio::config 'dashboard_url')"
INTERVAL="$(bashio::config 'interval')"

bashio::log.info "=========================================="
bashio::log.info "        CATT Watchdog"
bashio::log.info "=========================================="
bashio::log.info "Nest Hub      : ${NEST_HUB}"
bashio::log.info "Dashboard     : ${DASHBOARD_URL}"
bashio::log.info "Intervalle    : ${INTERVAL} secondes"
bashio::log.info "=========================================="

# ------------------------------------------------------------
# Attente du réseau
# ------------------------------------------------------------

bashio::log.info "Attente de la disponibilité du réseau..."

sleep 15

# ------------------------------------------------------------
# Boucle principale
# ------------------------------------------------------------

while true
do

    bashio::log.info "------------------------------------------"
    bashio::log.info "Tentative de Cast vers : ${NEST_HUB}"

    # Vérification de la présence du Nest Hub
    if catt -d "${NEST_HUB}" info >/tmp/catt_info.txt 2>&1; then

        bashio::log.info "Nest Hub détecté."

        # Envoi du dashboard
        if catt -d "${NEST_HUB}" cast_site "${DASHBOARD_URL}"; then

            bashio::log.info "Dashboard envoyé avec succès."

        else

            bashio::log.warning \
                "Échec de l'envoi du dashboard."

        fi

    else

        bashio::log.warning \
            "Nest Hub introuvable."

        bashio::log.warning \
            "Nouvelle tentative dans ${INTERVAL} secondes."

    fi

    bashio::log.info \
        "Prochaine vérification dans ${INTERVAL} secondes."

    sleep "${INTERVAL}"

done
