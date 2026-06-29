from theorem_dna.hash import canonical_json, hash_json, hash_text, merkle_root


def test_hash_text_is_stable():
    assert hash_text("abc") == hash_text("abc")


def test_canonical_json_sorts_keys():
    assert canonical_json({"b": 2, "a": 1}) == '{"a":1,"b":2}'


def test_hash_json_uses_canonical_representation():
    assert hash_json({"b": 2, "a": 1}) == hash_json({"a": 1, "b": 2})


def test_merkle_root_is_order_independent():
    assert merkle_root(["b", "a"]) == merkle_root(["a", "b"])


def test_merkle_root_preserves_duplicate_leaves():
    assert merkle_root(["a"]) != merkle_root(["a", "a"])
