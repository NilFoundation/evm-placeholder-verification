FROM ghcr.io/nilfoundation/evm-solana-verification/environment

WORKDIR /home

COPY . /home/app

RUN mkdir /home/app/build

RUN apt install -y bc
RUN cd /home/app/build && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=FALSE -DBUILD_TESTS=TRUE -DBUILD_WITH_NUMA=FALSE -DBUILD_WITH_CUDA=FALSE -DBUILD_WITH_OPENCL=FALSE -DBUILD_WITH_SANITIZE=FALSE -DBUILD_WITH_DPDK=FALSE -DCRYPTO3_HASH_POSEIDON=FALSE -DBUILD_EXAMPLES=TRUE -DZK_PLACEHOLDER_PROFILING=TRUE ..
# RUN cd /home/app/build && cmake --build . -t state-proof-gen state-mock --parallel $(nproc)
RUN cd /home/app/build && cmake --build . -t  \
    blueprint_hashes_plonk_sha256_process_test blueprint_hashes_plonk_sha512_process_test blueprint_non_native_plonk_non_native_demo_test  \
    blueprint_non_native_plonk_non_native_range_test blueprint_non_native_plonk_fixed_base_mul_test blueprint_non_native_plonk_complete_addition_test  \
    blueprint_non_native_plonk_var_base_mul_per_bit_test  blueprint_non_native_plonk_variable_base_multiplication_test --parallel $(nproc)

RUN cd /home/app/build && cmake --build . -t  \
    actor_blueprint_hashes_plonk_sha256_process_test actor_blueprint_hashes_plonk_sha512_process_test actor_blueprint_non_native_plonk_non_native_demo_test  \
    actor_blueprint_non_native_plonk_non_native_range_test actor_blueprint_non_native_plonk_fixed_base_mul_test actor_blueprint_non_native_plonk_complete_addition_test \
    actor_blueprint_non_native_plonk_var_base_mul_per_bit_test actor_blueprint_non_native_plonk_variable_base_multiplication_test --parallel $(nproc)

ENTRYPOINT ["/home/app/share/state-proof-verify/docker/solana/entrypoint.sh"]
