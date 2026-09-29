FROM rocker/geospatial:4.6.0
ARG RENV_PATHS_CACHE=/root/.cache/R/renv
ENV RENV_PATHS_CACHE="${RENV_PATHS_CACHE}"
RUN apt-get update -y && \
    apt-get install -y cmake make libuv1-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(renv.config.pak.enabled = FALSE, repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" | \
    tee /usr/local/lib/R/etc/Rprofile.site | \
    tee /usr/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN R -e 'remotes::install_version("renv", version = "1.2.4")'
WORKDIR /srv/shiny-server/
COPY renv.lock renv.lock
COPY renv/activate.R renv/activate.R
COPY .Rprofile .Rprofile
RUN R -e "renv::restore(prompt = FALSE)"
COPY . /srv/shiny-server/
EXPOSE 3838
CMD R -e 'shiny::runApp("/srv/shiny-server", host="0.0.0.0", port=as.numeric(Sys.getenv("PORT", "3838")))'