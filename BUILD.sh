#!/bin/bash

# check online platform: https://win-builder.r-project.org/upload.aspx

# Set script to exit on any errors.
set -e

# Define the package name
PACKAGE_NAME=$(basename $PWD)

# Preliminary step: document the package
echo "Writing documentation..."
Rscript -e "devtools::document()"

# Step 1: Clean previous builds
echo "Cleaning previous builds..."
rm -rf ${PACKAGE_NAME}_*.tar.gz

# Step 2: Build the package
echo "Building the package..."
R CMD build .

# Step 3: Check the package with --as-cran
echo "Checking the package with --as-cran..."
R CMD check --as-cran ${PACKAGE_NAME}_*.tar.gz

# Step 4: Install the package
echo "Installing the package..."
R CMD INSTALL ${PACKAGE_NAME}_*.tar.gz

echo "Build, check, and installation complete!"
