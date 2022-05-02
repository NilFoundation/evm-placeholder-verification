FROM ghcr.io/nilfoundation/evm-solana-verification/environment

WORKDIR /home

COPY .. /home/app
# Disable Prompt During Packages Installation

ENTRYPOINT ["/home/app/share/state-proof-verify/docker/solana/entrypoint.sh"]