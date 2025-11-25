#!/usr/bin/env bash

for i in *.voc; do ffmpeg -i "$i" "${i%.voc}.wav"; done
