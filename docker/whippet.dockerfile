FROM julia:1.6-buster

ENV PATH="/code/whippet/bin:${PATH}"

RUN apt update -y && \
    apt install -y git

RUN git clone https://github.com/timbitz/Whippet.jl.git /code/whippet && \
    cd /code/whippet && \
    julia --project -e 'using Pkg; Pkg.instantiate()'
