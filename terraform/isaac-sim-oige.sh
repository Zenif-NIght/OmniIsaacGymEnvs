#!/bin/bash

# Note: Nvidia Omniverse AMI has everything already installed and preset.
# Get Isaac Sim from AWS ECR
docker pull public.ecr.aws/nvidia/isaac-sim:2022.2.1
# Clone the OIGE and Robots_for_Omniverse Github Repos
git clone https://github.com/boredengineering/OmniIsaacGymEnvs.git
git clone https://github.com/boredengineering/Robots_for_Omniverse.git

# install isaac-sim container either use NGC or ECR docker images
docker run --name isaac-sim-oige --entrypoint bash -it -d --gpus all -e "ACCEPT_EULA=Y" --network=host \
-v ${PWD}:/workspace/omniisaacgymenvs \
-v ${PWD}:/workspace/Robots_for_Omniverse \
-v ~/docker/isaac-sim/cache/ov:/root/.cache/ov:rw \
-v ~/docker/isaac-sim/cache/pip:/root/.cache/pip:rw \
-v ~/docker/isaac-sim/cache/glcache:/root/.cache/nvidia/GLCache:rw \
-v ~/docker/isaac-sim/cache/computecache:/root/.nv/ComputeCache:rw \
-v ~/docker/isaac-sim/logs:/root/.nvidia-omniverse/logs:rw \
-v ~/docker/isaac-sim/config:/root/.nvidia-omniverse/config:rw \
-v ~/docker/isaac-sim/data:/root/.local/share/ov/data:rw \
-v ~/docker/isaac-sim/documents:/root/Documents:rw \
-v ~/docker/isaac-sim/cache/kit:/isaac-sim/kit/cache/Kit:rw \
public.ecr.aws/nvidia/isaac-sim:2022.2.1

# Can also get Docker from NGC
# nvcr.io/nvidia/isaac-sim:2022.2.1

# install OIGE on the Isaac-Sim Docker container
docker exec -it isaac-sim-oige sh -c "cd /workspace/omniisaacgymenvs && /isaac-sim/python.sh -m pip install -e . && cd omniisaacgymenvs"

# Install Robots_for_Omniverse on the Isaac-Sim Docker container
# docker exec -it isaac-sim-oige sh -c "cd /workspace/omniisaacgymenvs && /isaac-sim/python.sh -m pip install -e . && cd omniisaacgymenvs"

# Access the Container in a terminal and set the workspace inside the OIGE folder omniisaacgymenvs ready to run the scripts.
docker exec -it -w /workspace/omniisaacgymenvs/omniisaacgymenvs isaac-sim-oige bash