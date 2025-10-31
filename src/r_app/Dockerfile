FROM r-base:4.3.2

# Set working directory
WORKDIR /app

# Copy R scripts
COPY install_packages.R /app/install_packages.R
COPY main.R /app/main.R

# Install required R packages
RUN Rscript install_packages.R

# Default command: run the R script
CMD ["Rscript", "main.R"]
