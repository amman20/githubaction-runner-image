#!/bin/sh
export RUNNER_ALLOW_RUNASROOT="0" && ./config.sh --url $REPO_URL --token $TOKEN --unattended

supervisord -c /etc/supervisor/conf.d/supervisord.conf