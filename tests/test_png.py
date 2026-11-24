import importlib.machinery
import importlib.util
import pathlib
import struct
import unittest
import zlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
LOADER = importlib.machinery.SourceFileLoader("nagisafetch_module", str(ROOT / "nagisafetch"))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
nagisafetch = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(nagisafetch)


def chunk(kind, payload):
    crc = zlib.crc32(kind + payload) & 0xffffffff
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", crc)


def png(width, height, bit_depth, color_type, raw, corrupt_crc=False):
    ihdr = struct.pack(">IIBBBBB", width, height, bit_depth, color_type, 0, 0, 0)
    data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr)
    data += chunk(b"IDAT", zlib.compress(raw))
    data += chunk(b"IEND", b"")
    if corrupt_crc:
        data = data[:29] + bytes([data[29] ^ 1]) + data[30:]
    return data


class PngDecoderTests(unittest.TestCase):
    def test_decodes_rgba_png(self):
        decoded = nagisafetch._png_decode(png(1, 1, 8, 6, b"\x00\xff\x20\x10\xff"))
        self.assertEqual(decoded, (1, 1, [[(255, 32, 16, 255)]]))

    def test_grayscale_transparency_is_fully_transparent(self):
        decoded = nagisafetch._png_decode(png(1, 1, 8, 0, b"\x00\x7f"))
        self.assertEqual(decoded[2][0][0], (127, 127, 127, 255))

    def test_rejects_bad_signature(self):
        self.assertIsNone(nagisafetch._png_decode(b"not a png"))

    def test_rejects_truncated_chunk(self):
        self.assertIsNone(nagisafetch._png_decode(b"\x89PNG\r\n\x1a\n\x00"))

    def test_rejects_bad_crc(self):
        data = png(1, 1, 8, 6, b"\x00\xff\x20\x10\xff", corrupt_crc=True)
        self.assertIsNone(nagisafetch._png_decode(data))

    def test_rejects_excessive_dimensions(self):
        ihdr = struct.pack(">IIBBBBB", 20001, 1, 8, 6, 0, 0, 0)
        data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr)
        self.assertIsNone(nagisafetch._png_decode(data))

    def test_rejects_oversized_resize_target(self):
        with self.assertRaises(ValueError):
            nagisafetch._img_resize(1, 1, [[(0, 0, 0, 255)]], 2000, 2000)


if __name__ == "__main__":
    unittest.main()
