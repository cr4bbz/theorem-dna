# Ledger Signatures

Theorem DNA v0.1 signs verification and corollary-acceptance events with
Ed25519. The signature is deliberately outside the event hash:

1. Canonicalize the event without `event_hash` and `signature`.
2. Recompute and verify `event_hash`.
3. Sign the UTF-8 representation of that tagged SHA-256 hash.
4. Store the algorithm, key identifier, public-key location and fingerprint,
   signed hash, and Base64 signature in `signature`.

This keeps the append-only hash chain stable when a signature is attached.
Private keys are never committed; `.keys/` is ignored.

```bash
python tools/cli.py generate-signing-key \
  .keys/ledger-signing.pem keys/ledger-signing.pub.pem

python tools/cli.py sign-event ledger/events/event.json \
  .keys/ledger-signing.pem \
  --key-id theorem-dna-genesis-2026 \
  --public-key keys/ledger-signing.pub.pem

python tools/cli.py verify-event \
  ledger/events/event.json keys/ledger-signing.pub.pem
```

The current key is a project genesis key. Production use still requires a
documented backup, rotation, revocation, and multi-maintainer trust policy.
