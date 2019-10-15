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
    conda install -c conda-forge jupyterlab

RUN mkdir /notebooks && mkdir /data

CMD ["jupyter", "lab", "--allow-root"]