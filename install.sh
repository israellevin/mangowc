#!/bin/bash -e
docker build . -t mango-builder --build-arg NEW_MANGO="$(date +%s)"
docker run --rm --name mango-builder -dp 80:8000 mango-builder
echo Installation requires sudo.
sudo echo Thanks
curl localhost | sudo tar -xC /
sudo ldconfig
