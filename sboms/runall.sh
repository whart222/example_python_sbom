#!/bin/sh
#
# Generate the SBOMs in this directory
#
\rm -f *.json
. "$HOME/miniconda3/etc/profile.d/conda.sh"

conda create -n generate_sboms -y python=3.10 pipx numpy scipy pytest
conda activate generate_sboms
pip install platformdirs
pip install sbom4python
pip install cyclonedx-bom

echo "Install examplepythonsbom with pip"
cd ..
pip install -e .
cd sboms

# Generate SBOM from environment
cyclonedx-py environment -o cyclonedx_env_sbom.json

# Generate SBOM from installed package
sbom4python --module examplepythonsbom --sbom cyclonedx --format json -o sbom4python_module_sbom.json

pip uninstall -y examplepythonsbom

echo "Install examplepythonsbom with poetry"
cd ..
rm -f poetry.lock
poetry install
cd sboms

# Generate SBOM from poetry configuration
cd ..
cyclonedx-py poetry -o sboms/cyclonedx_poetry_sbom.json
cd sboms

conda deactivate
conda env remove -n generate_sboms
rm ../poetry.lock
