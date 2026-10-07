# Official PS4 firmware inventory

Updated: 2026-10-07

The user supplied an official PS4 **5.00 system-update PUP**. The original remains at `C:\Users\Syf\Desktop\BS4\PS4UPDATE.PUP`; an unchanged working copy is at `firmware\official\PS4UPDATE-5.00-system.PUP`. Both are local-only and ignored by Git.

- Length: `374,669,312` bytes
- SHA-256: `089168A7CC702FD45B65E8C8271FDFA0386BD1969509A06DC2FE94B03B978501`
- Header bytes: `SLB2`
- Status: encrypted/signed; not a direct Orbital runtime file
- Identification: matches the published 5.00 system-PUP size. Local checks did not independently verify a Sony signature.

No PUP was downloaded in this work. Do not install it on a physical console as part of this project. The official Sony system software page is the source named by the user: https://www.playstation.com/en-us/support/hardware/ps4/system-software/.

The pinned Orbital HDD README says matching normal/recovery PUP processing can provide `eap.img`, `system.img`, and `system_ex.img`; its documented workflow decrypts the package on the user's PS4 with `ps4-pup_decrypt` and unpacks the resulting decrypted fragments on a computer with `ps4-pup_unpack`. The supplied system-update PUP does not satisfy recovery-PUP files or console-dump inputs by itself. Exact classification is in `research/ORBITAL_500_RUNTIME_LAYOUT.md` and `docs/FIRMWARE_REQUIREMENTS.md`.

No proprietary Sony firmware, keys, or decrypted binaries were added to Git.
