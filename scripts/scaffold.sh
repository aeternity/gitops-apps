#!/bin/bash

APP=${1:-Please provide application name.}

mkdir $APP
cp -r scaffold/.helmignore $APP/.helmignore
envsubst '$APP' < scaffold/values.yaml > $APP/values.yaml
envsubst '$APP' < scaffold/values-dev.yaml > $APP/values-dev.yaml
envsubst '$APP' < scaffold/values-stg.yaml > $APP/values-stg.yaml
envsubst '$APP' < scaffold/values-prd.yaml > $APP/values-prd.yaml
