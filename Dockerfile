FROM mawall/ubuntu16.04_base

# Avoid "JavaScript heap out of memory" errors during jupyter extension installation
ARG NODE_OPTIONS=--max-old-space-size=4096
ARG OPEN3D_INSTALLATION_DIR="/opt/conda/lib/python3.7/site-packages/"

# Python-PCL dependency - must be installed first
RUN apt-get update && apt-get install -y libpcl-dev=1.7.2-14build1

# Open3D
RUN wget https://github.com/intel-isl/Open3D/releases/download/v0.9.0/open3d-0.9.0.0-cp37-cp37m-manylinux1_x86_64.whl && \
    pip install open3d-0.9.0.0-cp37-cp37m-manylinux1_x86_64.whl && \
    rm -rf open3d-0.9.0.0-cp37-cp37m-manylinux1_x86_64.whl 

# Packages
RUN pip install -U pip \
                   setuptools \
                   Sphinx
RUN pip install python-pcl \
                pye57
RUN conda update -n base -c defaults conda
RUN conda install -y matplotlib \
                     numpy \
                     pandas \
                     scipy \
                     scikit-learn
RUN conda install -c conda-forge pdal \
                                 python-pdal \
                                 gdal \
                                 jupyterlab>=2.1.2 \
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

RUN mkdir /notebooks && mkdir /data && mkdir /project && mkdir /opt/conda/lib/python3.7/ifcopenshell
ADD ifcopenshell /opt/conda/lib/python3.7/ifcopenshell

CMD ["sh", "-c", "jupyter lab --allow-root --ip=${HOST_IP} --NotebookApp.iopub_data_rate_limit=10000000000"]
