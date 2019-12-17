FROM mawall/ubuntu16.04_base

# Avoid "JavaScript heap out of memory" errors during jupyter extension installation
ARG NODE_OPTIONS=--max-old-space-size=4096
ARG OPEN3D_INSTALLATION_DIR="/opt/conda/lib/python3.7/site-packages/"

# Python-PCL dependency - must be installed first
RUN apt-get update && apt-get install -y libpcl-dev=1.7.2-14build1

# Open3D: Installing latest master
RUN curl -sL https://deb.nodesource.com/setup_12.x | /bin/bash - && \
    apt-get -y install nodejs
RUN (apt-get -y install xorg-dev libglu1-mesa-dev libgl1-mesa-glx || true) && \
    (apt-get install -y libglew-dev || true) && \
    (apt-get install -y libglfw3-dev || true) && \
    (apt-get install -y libjsoncpp-dev || true) && \
    (apt-get install -y libeigen3-dev || true) && \
    (apt-get install -y libpng-dev || true) && \
    (apt-get install -y libpng16-dev || true) && \
    (apt-get install -y python-dev python-tk || true) && \
    (apt-get install -y python3-dev python3-tk || true) && \
    (apt-get install -y cmake)
RUN cd /opt && \
    git clone --recursive https://github.com/intel-isl/Open3D && \
    mkdir /opt/Open3D/build && cd /opt/Open3D/build && \
    cmake -DCMAKE_INSTALL_PREFIX=$OPEN3D_INSTALLATION_DIR .. && \
    make -j$(nproc) && \
    make install-pip-package && \
    cd / && rm -rf /opt/Open3D

# Packages
RUN pip install -U setuptools && \
    pip install         \
        python-pcl      \
        pye57
RUN conda install -y    \
        matplotlib      \
        numpy           \
        pandas          \
        scipy           \
        scikit-learn
RUN conda install -c conda-forge pdal python-pdal gdal && \
    conda install -c plotly plotly=4.1.0 && \
    conda install -c conda-forge jupyterlab
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager@1.0 --no-build && \
    jupyter labextension install jupyterlab-plotly@1.1.0 --no-build && \
    jupyter labextension install plotlywidget@1.1.0 --no-build && \
#    jupyter labextension install jupyterlab-chart-editor@1.2 --no-build && \
    jupyter lab build && \
    unset NODE_OPTIONS

# Configure jupyter lab for remote access
# TODO: Secure server - https://jupyter-notebook.readthedocs.io/en/stable/public_server.html
RUN jupyter notebook --generate-config && \
    echo "c.NotebookApp.ip = '*'\nc.NotebookApp.port = 9999\n" > /root/.jupyter/jupyter_notebook_config.py

RUN mkdir /notebooks && mkdir /data && mkdir /project && mkdir /opt/conda/lib/python3.7/ifcopenshell
ADD ifcopenshell /opt/conda/lib/python3.7/ifcopenshell

CMD ["sh", "-c", "jupyter lab --allow-root --ip ${HOST_IP}"]