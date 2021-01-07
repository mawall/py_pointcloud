FROM mawall/ubuntu20.04_base

ARG PYTHON_MAJOR=3
ARG PYTHON_MINOR=8

# Avoid "JavaScript heap out of memory" errors during jupyter extension installation
ARG NODE_OPTIONS=--max-old-space-size=4096
ARG OPEN3D_INSTALLATION_DIR="/opt/conda/lib/python3.7/site-packages/"

# Python-PCL and pye57 dependencies
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London
RUN apt-get update && apt-get install -y libpcl-dev python3-pcl build-essential libxerces-c-dev

# Hacky way to install python3-pcl for conda python
RUN cp -r /usr/lib/python${PYTHON_MAJOR}/dist-packages/pcl /opt/conda/lib/python${PYTHON_MAJOR}.${PYTHON_MINOR}/site-packages  && \
    cp -r /usr/lib/python${PYTHON_MAJOR}/dist-packages/python_pcl-0.3.egg-info /opt/conda/lib/python${PYTHON_MAJOR}.${PYTHON_MINOR}/site-packages

# Open3D
RUN wget https://github.com/intel-isl/Open3D/releases/download/v0.10.0/open3d-0.10.0.0-cp38-cp38-manylinux1_x86_64.whl && \
    pip install open3d-0.10.0.0-cp38-cp38-manylinux1_x86_64.whl && \
    rm -rf open3d-0.10.0.0-cp38-cp38-manylinux1_x86_64.whl

# Packages
RUN pip install -U pip \
                   setuptools \
                   cython \
                   Sphinx
RUN pip install pye57
RUN conda update -n base -c defaults conda
RUN conda install -y matplotlib \
                     numpy \
                     pandas \
                     scipy \
                     scikit-learn
RUN conda install -c conda-forge pdal \
                                 python-pdal \
                                 gdal \
                                 jupyterlab=2.1.2 \
                                 nodejs && \
    conda install -c plotly plotly=4.1.0
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter labextension install jupyterlab-plotly --no-build && \
    jupyter labextension install plotlywidget --no-build && \
#    jupyter labextension install jupyterlab-chart-editor@1.2 --no-build && \
    jupyter lab build && \
    unset NODE_OPTIONS

# Configure jupyter lab for remote access
# TODO: Secure server - https://jupyter-notebook.readthedocs.io/en/stable/public_server.html
RUN jupyter notebook --generate-config && \
    echo "c.NotebookApp.ip = '*'\nc.NotebookApp.port = 9999\n" > /root/.jupyter/jupyter_notebook_config.py

RUN mkdir /notebooks && mkdir /data && mkdir /project && mkdir /opt/conda/lib/python${PYTHON_MAJOR}.${PYTHON_MINOR}/ifcopenshell
ADD ifcopenshell /opt/conda/lib/python${PYTHON_MAJOR}.${PYTHON_MINOR}/ifcopenshell

CMD ["sh", "-c", "jupyter lab --allow-root --ip=${HOST_IP} --NotebookApp.iopub_data_rate_limit=10000000000"]
