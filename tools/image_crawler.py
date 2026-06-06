"""
Rem 高清图片爬虫 v2 — 多源批量抓取
运行: python tools/image_crawler.py
依赖: pip install requests
"""
import requests
import os
import time
import re
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

OUT_DIR = Path("assets/images/rem_wallpapers")
OUT_DIR.mkdir(parents=True, exist_ok=True)

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
}
SESSION = requests.Session()
SESSION.headers.update(HEADERS)
SESSION.timeout = 20

total_new = 0


def download(url: str, filename: str = None) -> bool:
    """下载单张图片"""
    global total_new
    if filename is None:
        filename = url.split("/")[-1].split("?")[0]
    # 清理非法文件名字符
    filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
    if not filename.endswith((".jpg", ".png", ".jpeg", ".webp")):
        filename += ".jpg"

    path = OUT_DIR / filename
    if path.exists():
        return False

    try:
        r = SESSION.get(url, stream=True)
        if r.status_code == 200 and len(r.content) > 8000:
            path.write_bytes(r.content)
            total_new += 1
            size_kb = len(r.content) // 1024
            print(f"  ✓ [{total_new}] {filename[:50]} ({size_kb}KB)")
            return True
    except:
        pass
    return False


# ═══════════════════════════════════════════
# 来源 1: Wallhaven (翻页)
# ═══════════════════════════════════════════
def source_wallhaven():
    print("\n[wallhaven] 搜索 Rem 壁纸...")
    for page in range(1, 6):  # 5 页
        try:
            r = SESSION.get(
                "https://wallhaven.cc/api/v1/search",
                params={
                    "q": "Rem",
                    "categories": "010",
                    "purity": "100",
                    "sorting": "toplist",
                    "atleast": "1920x1080",
                    "page": page,
                },
            )
            data = r.json()
            items = data.get("data", [])
            print(f"  第{page}页: {len(items)} 张", end="")
            count = 0
            for item in items:
                url = item["path"]
                wid = item["id"]
                ext = item.get("file_type", "jpg")
                if download(url, f"wallhaven_{wid}.{ext}"):
                    count += 1
            print(f" → {count} 新")
            time.sleep(0.5)
        except Exception as e:
            print(f"  第{page}页失败: {e}")


# ═══════════════════════════════════════════
# 来源 2: 搜索 Ram 和 Re:Zero 通用壁纸
# ═══════════════════════════════════════════
def source_wallhaven_extra():
    print("\n[wallhaven] 搜索 Re:Zero + maid...")
    queries = ["Re:Zero", "anime maid", "Rem Ram"]
    for q in queries:
        try:
            r = SESSION.get(
                "https://wallhaven.cc/api/v1/search",
                params={
                    "q": q,
                    "categories": "010",
                    "purity": "100",
                    "sorting": "toplist",
                    "atleast": "1920x1080",
                },
            )
            data = r.json()
            items = data.get("data", [])[:15]
            print(f"  '{q}': {len(items)} 张", end="")
            count = 0
            for item in items:
                url = item["path"]
                wid = item["id"]
                if download(url, f"wallhaven_{wid}.{item.get('file_type', 'jpg')}"):
                    count += 1
            print(f" → {count} 新")
            time.sleep(0.5)
        except Exception as e:
            print(f"  '{q}' 失败: {e}")


# ═══════════════════════════════════════════
# 来源 3: Konachan (anime 图站 API)
# ═══════════════════════════════════════════
def source_konachan():
    print("\n[konachan] 搜索 Rem...")
    for page in range(1, 6):
        try:
            r = SESSION.get(
                "https://konachan.net/post.json",
                params={
                    "tags": "rem_(re:zero)",
                    "limit": 20,
                    "page": page,
                },
            )
            items = r.json()
            print(f"  第{page}页: {len(items)} 张", end="")
            count = 0
            for item in items:
                url = item.get("file_url") or item.get("jpeg_url") or item.get("sample_url", "")
                if url and not url.endswith("gif"):  # 跳过动图
                    fid = item["id"]
                    ext = url.split(".")[-1].split("?")[0]
                    if ext not in ("jpg", "jpeg", "png"):
                        ext = "jpg"
                    if download(url, f"konachan_{fid}.{ext}"):
                        count += 1
            print(f" → {count} 新")
            time.sleep(0.8)
        except Exception as e:
            print(f"  第{page}页失败: {e}")


# ═══════════════════════════════════════════
# 来源 4: Yande.re (anime 图站)
# ═══════════════════════════════════════════
def source_yandere():
    print("\n[yande.re] 搜索 Rem...")
    for page in range(1, 4):
        try:
            r = SESSION.get(
                "https://yande.re/post.json",
                params={
                    "tags": "rem_(re:zero)",
                    "limit": 20,
                    "page": page,
                },
            )
            items = r.json()
            print(f"  第{page}页: {len(items)} 张", end="")
            count = 0
            for item in items:
                url = item.get("file_url") or item.get("jpeg_url") or item.get("sample_url", "")
                if url:
                    fid = item["id"]
                    ext = url.split(".")[-1].split("?")[0]
                    if ext not in ("jpg", "jpeg", "png"):
                        ext = "jpg"
                    if download(url, f"yandere_{fid}.{ext}"):
                        count += 1
            print(f" → {count} 新")
            time.sleep(0.8)
        except Exception as e:
            print(f"  第{page}页失败: {e}")


# ═══════════════════════════════════════════
# 来源 5: Danbooru (需要 auth 但可以尝试)
# ═══════════════════════════════════════════
def source_danbooru():
    print("\n[danbooru] 搜索 Rem...")
    for page in range(1, 4):
        try:
            r = SESSION.get(
                "https://danbooru.donmai.us/posts.json",
                params={
                    "tags": "rem_(re:zero) rating:general",
                    "limit": 20,
                    "page": page,
                },
            )
            items = r.json()
            print(f"  第{page}页: {len(items)} 张", end="")
            count = 0
            for item in items:
                url = item.get("large_file_url") or item.get("file_url") or ""
                if url:
                    fid = item["id"]
                    ext = url.split(".")[-1].split("?")[0]
                    if ext not in ("jpg", "jpeg", "png"):
                        ext = "jpg"
                    if download(url, f"danbooru_{fid}.{ext}"):
                        count += 1
            print(f" → {count} 新")
            time.sleep(0.8)
        except Exception as e:
            print(f"  第{page}页失败: {e}")


# ═══════════════════════════════════════════
# 来源 6: Safebooru (不需要 auth)
# ═══════════════════════════════════════════
def source_safebooru():
    print("\n[safebooru] 搜索 Rem...")
    for page in range(0, 100, 20):
        try:
            r = SESSION.get(
                "https://safebooru.org/index.php",
                params={
                    "page": "dapi",
                    "s": "post",
                    "q": "index",
                    "tags": "rem_(re:zero)",
                    "limit": 20,
                    "pid": page,
                    "json": "1",
                },
            )
            # safebooru 返回格式特殊
            items = r.json() if r.headers.get("content-type", "").startswith("application/json") else []
            print(f"  offset {page}: {len(items)} 张", end="")
            count = 0
            for item in items:
                directory = item.get("directory", "")
                image = item.get("image", "")
                if directory and image:
                    url = f"https://safebooru.org/images/{directory}/{image}"
                    if download(url, f"safebooru_{item['id']}.jpg"):
                        count += 1
            print(f" → {count} 新")
            time.sleep(0.5)
        except Exception as e:
            print(f"  offset {page} 失败: {e}")


# ═══════════════════════════════════════════
# 来源 7: Waifu.pics
# ═══════════════════════════════════════════
def source_waifu_pics():
    print("\n[waifu.pics] 批量抓取...")
    tags = ["waifu", "maid", "uniform", "selfies", "blush", "cry", "happy", "smile", "wave", "dance"]
    count = 0
    for tag in tags:
        try:
            r = SESSION.post(f"https://api.waifu.pics/many/sfw/{tag}", json={"exclude": []})
            urls = r.json().get("files", [])[:10]
            for url in urls:
                if download(url, f"waifu_{tag}_{int(time.time()*1000)}.jpg"):
                    count += 1
        except Exception as e:
            print(f"  {tag}: {e}")
    print(f"  → {count} 新")


# ═══════════════════════════════════════════
# 来源 8: Wallhaven 直链
# ═══════════════════════════════════════════
def source_direct_urls():
    print("\n[直链] wallhaven CDN...")
    ids = [
        "o53eol", "mp8d99", "6lk5kx", "966y6x",
        "lmomqr", "961kk8", "dgyq1m", "rq213m",
        "wq7m6x", "1p3vjw", "j35gm7", "exrgow",
        "2856m6", "yxrvgw", "9d38mx", "76jgy9",
    ]
    count = 0
    for wid in ids:
        for ext in ("jpg", "png"):
            url = f"https://w.wallhaven.cc/full/{wid[:2]}/wallhaven-{wid}.{ext}"
            if download(url, f"wallhaven_direct_{wid}.{ext}"):
                count += 1
                break
    print(f"  → {count} 新")


# ═══════════════════════════════════════════
# 来源 9: 1000+ Rem 壁纸 ID 爆破
# ═══════════════════════════════════════════
def source_wallhaven_bruteforce():
    """搜索 Re:Zero 标签下更多页"""
    print("\n[wallhaven] 深度翻页 Rem+Ram+Emilia...")
    queries = [
        ("Rem", 10),
        ("Ram", 5),
        ("Re:Zero maid", 8),
        ("anime blue hair maid", 5),
    ]
    count = 0
    for query, pages in queries:
        for page in range(1, pages + 1):
            try:
                r = SESSION.get(
                    "https://wallhaven.cc/api/v1/search",
                    params={
                        "q": query,
                        "categories": "010",
                        "purity": "100",
                        "sorting": "relevance",
                        "page": page,
                    },
                )
                data = r.json()
                for item in data.get("data", [])[:20]:
                    url = item["path"]
                    wid = item["id"]
                    if download(url, f"wallhaven_{wid}.{item.get('file_type', 'jpg')}"):
                        count += 1
                time.sleep(0.3)
            except Exception as e:
                break
    print(f"  → {count} 新")


if __name__ == "__main__":
    print("=== Rem 高清图片爬虫 v2 ===\n")
    print(f"保存目录: {OUT_DIR.absolute()}\n")

    sources = [
        source_wallhaven,
        source_wallhaven_extra,
        source_wallhaven_bruteforce,
        source_konachan,
        source_yandere,
        source_danbooru,
        source_safebooru,
        source_waifu_pics,
        source_direct_urls,
    ]

    for src in sources:
        try:
            src()
        except Exception as e:
            print(f"  [中断] {src.__name__}: {e}")

    files = list(OUT_DIR.glob("*"))
    total_mb = sum(f.stat().st_size for f in files) // (1024 * 1024)
    print(f"\n{'='*50}")
    print(f"总计: {len(files)} 张图片 ({total_mb}MB)")
    print(f"本次新增: {total_new} 张")
    print(f"目录: {OUT_DIR.absolute()}")
