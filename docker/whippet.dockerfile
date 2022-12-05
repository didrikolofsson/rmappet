FROM julia:1.6-buster

ENV PATH="/code/whippet/bin:${PATH}"

WORKDIR /code/whippet

RUN apt update -y && \
    apt install -y git
RUN git clone https://github.com/timbitz/Whippet.jl.git /code/whippet