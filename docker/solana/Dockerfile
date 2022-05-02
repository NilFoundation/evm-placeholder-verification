FROM ghcr.io/nilfoundation/evm-solana-verification/environment

WORKDIR /home

COPY . /home/app
# Disable Prompt During Packages Installation
RUN mkdir /home/app/build
RUN cd /home/app/build && cmake -DCMAKE_BUILD_TYPE=Release ..
RUN cd /home/app/build && cmake --build --parallel $(nproc) . -t state-proof-gen state-mock
RUN cd /home/app/build && cmake --build --parallel $(nproc) . -t blueprint_plonk_variable_base_endo_scalar_mul_test \
    blueprint_plonk_variable_base_scalar_mul_test blueprint_plonk_unified_addition_test

ENTRYPOINT ["/home/app/share/state-proof-verify/docker/solana/entrypoint.sh"]