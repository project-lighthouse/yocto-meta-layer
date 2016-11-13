#!/bin/bash

SCRIPTS_FOLDER=${BASH_SOURCE%/*}

# Import environment values.
. <(grep = ${SCRIPTS_FOLDER}/boot.cfg)

${SCRIPTS_FOLDER}/cirrus-usecases/Record_from_DMIC.sh -q ${MICROPHONE_VOLUME}
${SCRIPTS_FOLDER}/cirrus-usecases/Playback_to_Speakers.sh -q ${SPEAKER_VOLUME}