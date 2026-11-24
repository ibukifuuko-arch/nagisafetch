import importlib.machinery
import importlib.util
import pathlib
import struct
import tempfile
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
        ihdr = struct.pack(">IIBBBBB", 1, 1, 8, 0, 0, 0, 0)
        data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr)
        data += chunk(b"tRNS", struct.pack(">H", 127))
        data += chunk(b"IDAT", zlib.compress(b"\x00\x7f"))
        data += chunk(b"IEND", b"")
        decoded = nagisafetch._png_decode(data)
        self.assertEqual(decoded[2][0][0], (127, 127, 127, 0))

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


class ImageRenderTests(unittest.TestCase):
    """图片渲染的集成路径：极端宽高比不能把解码层的异常冒到调用方。"""

    def _tall_png(self):
        # 1x1000 细长图，曾令 ansi 路径 ph=37500、pw*ph=150 万而抛 ValueError。
        raw = b"".join(b"\x00\xff\x00\x00\xff" for _ in range(1000))
        data = png(1, 1000, 8, 6, raw)
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)  # 3.8 兼容：不用 3.11 才有的 enterContext
        path = pathlib.Path(tmp.name) / "tall.png"
        path.write_bytes(data)
        return str(path)

    def test_ansi_handles_tall_image_without_crash(self):
        path = self._tall_png()
        seq, rows, cols = nagisafetch.ansi_halfblock_escape(path, width=40)
        self.assertIsNotNone(seq)
        self.assertGreater(rows, 0)
        self.assertEqual(cols, 40)
        self.assertLessEqual(rows * 2 * cols, 500_000)

    def test_sixel_handles_tall_image_without_crash(self):
        path = self._tall_png()
        seq, rows, cols = nagisafetch.sixel_image_escape(path, width=40)
        self.assertIsNotNone(seq)
        self.assertGreater(rows, 0)
        self.assertGreater(cols, 0)


if __name__ == "__main__":
    unittest.main()
