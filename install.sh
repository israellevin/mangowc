#!/bin/bash -e
docker build . -t mango-builder --build-arg NEW_MANGO=$(date +%s)
docker run --rm --name mango-builder -dp 80:8000 mango-builder
curl localhost | tar -xC /
ldconfig
