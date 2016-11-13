#!/bin/bash

WORKING_FOLDER=${BASH_SOURCE%/*}

# Import environment values.
. <(grep = ${WORKING_FOLDER}/boot.cfg)

${WORKING_FOLDER}/cirrus-usecases/Record_from_DMIC.sh -q ${MICROPHONE_VOLUME}
${WORKING_FOLDER}/cirrus-usecases/Playback_to_Speakers.sh -q ${SPEAKER_VOLUME}