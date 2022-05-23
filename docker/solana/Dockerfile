FROM ghcr.io/nilfoundation/evm-solana-verification/environment

WORKDIR /home

COPY . /home/app
# Disable Prompt During Packages Installation
RUN mkdir /home/app/build

RUN cd /home/app/build && cmake -DCMAKE_BUILD_TYPE=Release ..
# RUN cd /home/app/build && cmake --build . -t state-proof-gen state-mock --parallel $(nproc)
RUN cd /home/app/build && cmake --build . -t blueprint_plonk_field_add_test \
    blueprint_plonk_field_mul_test blueprint_plonk_field_sub_test blueprint_plonk_non_native_range_test  \
    blueprint_plonk_unified_addition_test blueprint_plonk_variable_base_scalar_mul_test \
    blueprint_non_native_complete_addition blueprint_non_native_var_base_mul_per_bit blueprint_non_native_fixed_base_mul --parallel $(nproc)

ENTRYPOINT ["/home/app/share/state-proof-verify/docker/solana/entrypoint.sh"]