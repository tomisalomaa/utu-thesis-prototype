#!/bin/bash
# Clean up
pkill mongod
pkill node
# Prepare artifacts if needed
echo Preparing "$ASSESSMENT_EX" artifacts to collect
echo ---------------------------------