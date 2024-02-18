#!/usr/bin/env bash

current_branch=$(git branch --show-current)
date_now=$(date '+%Y%m%d')
version="v1"

# Build Docker Image
docker build -t "edwardallen/ecom-web:${version}" . 

# Push to Docker Hub
docker push "edwardallen/ecom-web:${version}"