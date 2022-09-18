#!/bin/bash
cp "$DIR/resources/.env" "$1"
echo Executing npm CI and RUN
cd "$1"
npm ci
npm run watch &