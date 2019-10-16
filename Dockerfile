FROM mawall/ubuntu16.04_base

# Dependencies
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
RUN conda install -c open3d-admin open3d && \
    conda install -c conda-forge pdal python-pdal gdal && \
    conda install -c conda-forge jupyterlab

RUN mkdir /notebooks && mkdir /data && mkdir /opt/conda/lib/python3.7/ifcopenshell
ADD ifcopenshell /opt/conda/lib/python3.7/ifcopenshell

CMD ["jupyter", "lab", "--allow-root"]