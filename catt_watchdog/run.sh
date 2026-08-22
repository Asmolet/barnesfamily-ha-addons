#!/usr/bin/with-contenv bashio

set -u

NEST_HUB="$(bashio::config 'nest_hub')"
DASHBOARD_PATH="$(bashio::config 'dashboard_path')"
VIEW_PATH="$(bashio::config 'view_path')"
INTERVAL="$(bashio::config 'interval')"
HA_URL="$(bashio::config 'ha_url')"
HA_TOKEN="$(bashio::config 'ha_token')"

ENTITY_ID="media_player.nest_hub"

bashio::log.info "=========================================="
bashio::log.info "       CATT Watchdog V2"
bashio::log.info "=========================================="
bashio::log.info "Nest Hub       : ${NEST_HUB}"
bashio::log.info "Entity         : ${ENTITY_ID}"
bashio::log.info "Dashboard      : ${DASHBOARD_PATH}"
bashio::log.info "Vue            : ${VIEW_PATH}"
bashio::log.info "Intervalle     : ${INTERVAL} secondes"
bashio::log.info "Home Assistant : ${HA_URL}"
bashio::log.info "=========================================="

if [ -z "${HA_TOKEN}" ]; then
    bashio::log.error "Le token Home Assistant n'est pas configuré."
    exit 1
fi

sleep 15

while true
do

    bashio::log.info "------------------------------------------"
    bashio::log.info "Vérification du Nest Hub..."

    # --------------------------------------------------------
    # Vérification du Chromecast avec CATT
    # --------------------------------------------------------

    if catt -d "${NEST_HUB}" status >/tmp/catt_status.txt 2>&1; then

        bashio::log.info "Nest Hub détecté."

        # ----------------------------------------------------
        # Appel Home Assistant
        # ----------------------------------------------------

        bashio::log.info \
            "Demande de réaffichage du dashboard via Home Assistant Cast..."

        RESPONSE=$(curl -s \
            -o /tmp/ha_response.txt \
            -w "%{http_code}" \
            -X POST \
            "${HA_URL}/api/services/cast/show_lovelace_view" \
            -H "Authorization: Bearer ${HA_TOKEN}" \
            -H "Content-Type: application/json" \
            --data "{
                \"entity_id\": \"${ENTITY_ID}\",
                \"dashboard_path\": \"${DASHBOARD_PATH}\",
                \"view_path\": \"${VIEW_PATH}\"
            }"
        )

        if [ "${RESPONSE}" = "200" ]; then

            bashio::log.info \
                "Dashboard envoyé via Home Assistant Cast avec succès."

        else

            bashio::log.error \
                "Erreur Home Assistant Cast. HTTP ${RESPONSE}"

            if [ -s /tmp/ha_response.txt ]; then
                bashio::log.error \
                    "$(cat /tmp/ha_response.txt)"
            fi

        fi

    else

        bashio::log.warning \
            "Nest Hub introuvable avec CATT."

        bashio::log.warning \
            "Aucun Cast envoyé cette fois."

    fi

    bashio::log.info \
        "Prochaine vérification dans ${INTERVAL} secondes."

    sleep "${INTERVAL}"

done
