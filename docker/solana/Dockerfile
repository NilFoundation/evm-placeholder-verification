FROM ghcr.io/nilfoundation/evm-solana-verification/environment

WORKDIR /home

COPY . /home/app
# Disable Prompt During Packages Installation
RUN mkdir /home/app/build

RUN cd /home/app/build && cmake -DCMAKE_BUILD_TYPE=Release ..
# RUN cd /home/app/build && cmake --build . -t state-proof-gen state-mock --parallel $(nproc)
RUN cd /home/app/build && cmake --build . -t blueprint_plonk_field_add_test \
    blueprint_plonk_field_mul_test blueprint_plonk_field_sub_test blueprint_plonk_non_native_range_test  \
    blueprint_plonk_complete_addition_test blueprint_plonk_var_base_mul_per_bit_test blueprint_plonk_fixed_base_mul_test --parallel $(nproc)

ENTRYPOINT ["/home/app/share/state-proof-verify/docker/solana/entrypoint.sh"]