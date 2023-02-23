# Copyright Ryo Ikota
ARG BASE_CONTAINER=jupyter/datascience-notebook:2023-02-20
FROM $BASE_CONTAINER

USER root
RUN apt-get update \
    && apt-get install -y less make tree latexmk
# COPY --chown=$NB_USER:$NB_GID <a file you want to copy> $HOME/ 

# install Quarto
ENV QUARTO_VERSION="1.2.335"
RUN mkdir -p /opt/quarto/${QUARTO_VERSION} \
    && curl -o quarto.tar.gz -L \
    "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz" \
    && tar -zxvf quarto.tar.gz \
    -C "/opt/quarto/${QUARTO_VERSION}" \
    --strip-components=1 \
    && rm quarto.tar.gz \
    && ln -s /opt/quarto/${QUARTO_VERSION}/bin/quarto /usr/local/bin/quarto


# install packages
USER $NB_UID
COPY requirements-conda.txt /tmp/
RUN mamba install --yes --file /tmp/requirements-conda.txt && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
RUN julia -e 'import Pkg; Pkg.update()' && \
    julia -e 'import Pkg; Pkg.add.(["DifferentialEquations", "Plots"])' && \
    fix-permissions "${JULIA_PKGDIR}" "${CONDA_DIR}/share/jupyter"
WORKDIR $HOME/work

# Uncomment the following lines 
# if you want to give the sudo permission to jovyan
#
# USER root
# ENV GRANT_SUDO=yes

# CMD ["start.sh", "jupyter", "lab", "--port=8005"]

# Uncomment the following line
# if you want to launch Jupyter without token
# 
# CMD ["start.sh", "jupyter", "lab", "--port=8005", "--LabApp.token=''"]
