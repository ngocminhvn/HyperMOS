#!/usr/bin/env python3
"""Small, offline regression checks for safe super.img LP extraction."""
import struct
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts import super_rw


def sample_metadata(extents=None, name="system"):
    if extents is None:
        extents = [
            {"num_sectors": 1, "target_type": 0, "target_data": 8, "target_source": 0},
            {"num_sectors": 1, "target_type": 1, "target_data": 0, "target_source": 0},
            {"num_sectors": 1, "target_type": 0, "target_data": 10, "target_source": 0},
        ]
    return {
        "block_devices": [{
            "raw_name": "super", "flags": 0, "size": 8192,
            "first_logical_sector": 8,
        }],
        "groups": [{"raw_name": "default", "flags": 0}],
        "partitions": [{
            "raw_name": name, "attributes": 0, "group_raw": "default",
            "extents": extents, "size": sum(e["num_sectors"] for e in extents) * 512,
        }],
    }


class UnpackFallbackTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.image = self.root / "super.img"
        data = bytearray(8192)
        data[4096:4608] = b"A" * 512
        data[5120:5632] = b"B" * 512
        self.image.write_bytes(data)
        self.output = self.root / "out"
        self.output.mkdir()

    def unpack(self, metadata, simulate_legacy_binary=False):
        with (
            patch.object(super_rw, "read_geometry", return_value={"metadata_slot_count": 1}),
            patch.object(super_rw, "read_metadata_slot", return_value=metadata),
        ):
            if simulate_legacy_binary:
                with patch.object(
                    super_rw, "run",
                    side_effect=super_rw.SuperRwError("invalid metadata checksum"),
                ):
                    super_rw.run_lpunpack(self.image, self.output, 0)
            else:
                super_rw.unpack_validated_metadata(self.image, self.output, 0)

    def test_linear_and_zero_extents(self):
        self.unpack(sample_metadata(), simulate_legacy_binary=True)
        self.assertEqual(
            (self.output / "system.img").read_bytes(),
            b"A" * 512 + bytes(512) + b"B" * 512,
        )

    def test_out_of_bounds_extent_fails_closed(self):
        bad = [{"num_sectors": 1, "target_type": 0, "target_data": 16, "target_source": 0}]
        with self.assertRaisesRegex(super_rw.SuperRwError, "outside super"):
            self.unpack(sample_metadata(bad))
        self.assertFalse((self.output / "system.img").exists())

    def test_unsupported_extent_fails_closed(self):
        bad = [{"num_sectors": 1, "target_type": 7, "target_data": 8, "target_source": 0}]
        with self.assertRaisesRegex(super_rw.SuperRwError, "unsupported extent"):
            self.unpack(sample_metadata(bad))
        self.assertFalse((self.output / "system.img").exists())

    def test_invalid_name_fails_closed(self):
        with self.assertRaisesRegex(super_rw.SuperRwError, "Unsafe partition"):
            self.unpack(sample_metadata(name="../system"))


class ZeroSizedPartitionMetadataTests(unittest.TestCase):
    def test_clears_placeholder_extent_without_touching_other_entries(self):
        entries = bytearray(2 * 52)
        entries[0:36] = b"inactive_b\0" + bytes(25)
        struct.pack_into("<IIII", entries, 36, 0, 0, 1, 0)
        entries[52:88] = b"active_a\0" + bytes(27)
        struct.pack_into("<IIII", entries, 88, 1, 1, 1, 0)

        super_rw.clear_partition_extents(
            entries,
            {"offset": 0, "entry_size": 52, "num_entries": 2},
            {"inactive_b"},
        )

        self.assertEqual(struct.unpack_from("<II", entries, 40), (0, 0))
        self.assertEqual(struct.unpack_from("<II", entries, 92), (1, 1))


class ErofsGrowthSafetyTests(unittest.TestCase):
    def setUp(self):
        self.product = {
            "raw_name": "product_a", "name": "product_a",
            "group_raw": "qti_dynamic_partitions_a",
            "original_partition_size": 8 * 4096,
        }

    def test_stays_original_size_when_image_fits(self):
        self.assertEqual(
            super_rw.requested_erofs_size(self.product, 7 * 4096, 4096, True),
            8 * 4096,
        )

    def test_grow_requires_explicit_opt_in(self):
        with self.assertRaisesRegex(super_rw.SuperRwError, "explicit --allow-erofs-grow"):
            super_rw.requested_erofs_size(self.product, 8 * 4096 + 1, 4096)

    def test_grow_rounds_to_logical_block_boundary(self):
        self.assertEqual(
            super_rw.requested_erofs_size(self.product, 8 * 4096 + 1, 4096, True),
            9 * 4096,
        )

    def test_refuses_group_overflow(self):
        manifest = {
            "groups": [
                {"raw_name": "qti_dynamic_partitions_a", "maximum_size": 9 * 4096}
            ],
            "partitions": [self.product],
        }
        with self.assertRaisesRegex(super_rw.SuperRwError, "lacks room"):
            super_rw.verify_group_size_budget(manifest, {"product_a": 10 * 4096})

    def test_accepts_group_growth_within_unchanged_limit(self):
        manifest = {
            "groups": [
                {"raw_name": "qti_dynamic_partitions_a", "maximum_size": 10 * 4096}
            ],
            "partitions": [self.product],
        }
        super_rw.verify_group_size_budget(manifest, {"product_a": 9 * 4096})

    def test_counts_all_partitions_in_same_group(self):
        other = {
            "raw_name": "system_a", "name": "system_a",
            "group_raw": "qti_dynamic_partitions_a",
        }
        manifest = {
            "groups": [
                {"raw_name": "qti_dynamic_partitions_a", "maximum_size": 12 * 4096}
            ],
            "partitions": [self.product, other],
        }
        with self.assertRaisesRegex(super_rw.SuperRwError, "short by"):
            super_rw.verify_group_size_budget(
                manifest, {"product_a": 9 * 4096, "system_a": 4 * 4096}
            )


if __name__ == "__main__":
    unittest.main()
