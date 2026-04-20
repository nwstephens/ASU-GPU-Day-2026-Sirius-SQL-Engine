# Install pixi
curl -fsSL https://pixi.sh/install.sh | sh

# Download Sirius
git clone --recurse-submodules https://github.com/sirius-db/sirius.git
cd sirius

# Build
pixi shell
CMAKE_BUILD_PARALLEL_LEVEL=$(nproc) make

# Config
export SIRIUS_CONFIG_FILE=test/cpp/integration/integration.yaml

# Generate data
cd test/tpch_performance
vim pixi.toml # update cudf to 26.06.*
pixi run bash generate_tpch_data.sh 100
