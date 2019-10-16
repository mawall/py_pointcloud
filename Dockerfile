FROM mawall/ubuntu16.04_base

ARG OPEN3D_INSTALLATION_DIR="/opt/conda/lib/python3.7/site-packages/"

# Packages
RUN apt-get update && apt-get install -y libpcl-dev=1.7.2-14build1
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
    conda install -c conda-forge jupyterlab

# Open3D: Installing latest master
RUN curl -sL https://deb.nodesource.com/setup_10.x | /bin/bash - && \
    apt-get install nodejs
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

RUN mkdir /notebooks && mkdir /data && mkdir /opt/conda/lib/python3.7/ifcopenshell
ADD ifcopenshell /opt/conda/lib/python3.7/ifcopenshell

CMD ["jupyter", "lab", "--allow-root"]