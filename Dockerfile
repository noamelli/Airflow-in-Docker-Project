FROM apache/airflow:2.8.2
COPY requirement.txt /requirement.txt
RUN pip install --user --upgrade pip
RUN pip install --no-cache-dir --user -r /requirement.txt


