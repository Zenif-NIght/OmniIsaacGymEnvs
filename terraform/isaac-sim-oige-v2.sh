docker pull public.ecr.aws/nvidia/isaac-sim:2022.2.1
# Clone the OIGE and Robots_for_Omniverse Github Repos
git clone https://github.com/boredengineering/OmniIsaacGymEnvs.git
cd ./OmniIsaacGymEnvs
./docker/run_docker.sh
