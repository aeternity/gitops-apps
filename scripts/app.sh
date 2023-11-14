#!/bin/bash
set -euo pipefail

APP_DOMAIN=${APP_DOMAIN:-"aepps.com"}

function usage {
    echo "Usage:"
    echo "$0 update-version <app path> - Update application version"
    echo "$0 delete-version <app path> - Delete application version"
    echo "$0 update-tag <app path> - Update application tag"
    echo "$0 delete-host <app path> - Update application host"
    echo "$0 update-host <app path> - Update application versioned host"
}

function delete-version {
    APP="${1:?Please provide application path}"
    : "${APP_ENV:?Please provide application environment}"
    : "${APP_VERSION:?Please provide application version}"

    CONFIG_FILE=${APP}/values-${APP_ENV}.yaml
    yq -i 'del( .app.versions[] | select(.version == env(APP_VERSION)) )' $CONFIG_FILE
}

function update-version {
    APP="${1:?Please provide application path}"
    : "${APP_ENV:?Please provide application environment}"
    : "${APP_VERSION:?Please provide application version}"
    : "${APP_VERSION_SHA:?Please provide application version SHA}"

    delete-version $APP
    update-host $APP

    CONFIG_FILE=${APP}/values-${APP_ENV}.yaml
    yq -i '.app.versions += [{"version": strenv(APP_VERSION), "gitSha": strenv(APP_VERSION_SHA)}] | .. style="double"' $CONFIG_FILE
}

function update-tag {
    APP="${1:?Please provide application path}"
    : "${APP_ENV:?Please provide application environment}"
    : "${APP_VERSION:?Please provide application version}"

    CONFIG_FILE=${APP}/values-${APP_ENV}.yaml
    yq -i '.app.image.tag = env(APP_VERSION)' $CONFIG_FILE
}

function delete-host {
    APP="${1:?Please provide application path}"
    : "${APP_ENV:?Please provide application environment}"
    : "${APP_VERSION:?Please provide application version}"

    APP_SUBDOMAIN=${APP_SUBDOMAIN-$APP}
    APP_HOST_PREFIX=${APP_HOST_PREFIX-"${APP_VERSION}-"}
    export APP_HOST="${APP_HOST_PREFIX}${APP_SUBDOMAIN}.${APP_ENV}.${APP_DOMAIN}"

    CONFIG_FILE=${APP}/values-${APP_ENV}.yaml
    yq -i 'del( .app.ingress.hosts[] | select(.host == env(APP_HOST)) )' $CONFIG_FILE
}

function update-host {
    APP="${1:?Please provide application path}"
    : "${APP_ENV:?Please provide application environment}"
    : "${APP_VERSION:?Please provide application version}"

    APP_SUBDOMAIN=${APP_SUBDOMAIN-$APP}
    APP_HOST_PREFIX=${APP_HOST_PREFIX-"${APP_VERSION}-"}
    export APP_HOST="${APP_HOST_PREFIX}${APP_SUBDOMAIN}.${APP_ENV}.${APP_DOMAIN}"

    delete-host $APP

    CONFIG_FILE=${APP}/values-${APP_ENV}.yaml
    yq -i '.app.ingress.hosts += [{"host": strenv(APP_HOST), "paths": [{"path": "/", "version": strenv(APP_VERSION)}]}]' $CONFIG_FILE
}

"${@-usage}"
