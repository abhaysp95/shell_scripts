#!/usr/bin/python3

import os
import sys
import json
import hashlib
import tarfile
from datetime import datetime, timezone
import subprocess
import tempfile

def human_readable_size(size, decimal_places=2):
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size < 1024:
            return f"{size:.{decimal_places}f} {unit}"
        size /= 1024
    return f"{size:.{decimal_places}f} PB"

def sha256_checksum(file_path, block_size=65536):
    sha256 = hashlib.sha256()
    with open(file_path, 'rb') as f:
        while chunk := f.read(block_size):
            sha256.update(chunk)
    return sha256.hexdigest()

def list_tar_zst_contents(archive_path):
    """
    Uses `tar -tvf` to list contents of a .tar.zst archive.
    Assumes that the system tar supports -I zstd.
    """

    try:
        proc = subprocess.run(
            ['tar', '-tvf', archive_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
            text=True
        )
    except subprocess.CalledProcessError as e:
        print(f"Error listing archive: {e.stderr}")
        sys.exit(1)

    file_list = []
    files_count = 0
    for line in proc.stdout.strip().split('\n'):
        parts = line.split(None, 5)
        if len(parts) < 6:
            continue  # Skip malformed lines

        perms, _, size_str, _, _, filename = parts
        if perms.startswith('-'):  # Regular file
            size_bytes = int(size_str)
            file_list.append({
                "filename": filename,
                "size_bytes": size_bytes,
                "human_size": human_readable_size(size_bytes),
                "notes": None
            })
            files_count += 1

    return file_list, files_count

def generate_manifest(archive_path, storage_name, compression_algo="zstd", compression_level=None, encryption_enabled=False, encryption_method=None, key_generation_method=None):
    archive_size = os.path.getsize(archive_path)
    archive_checksum = sha256_checksum(archive_path)
    archive_name = os.path.basename(archive_path)
    creation_date = datetime.now(timezone.utc).isoformat() + "Z"

    files_info, files_count = list_tar_zst_contents(archive_path)

    manifest = {
        "archive": archive_name,
        "storage": storage_name,
        "archive_size_bytes": archive_size,
        "archive_size_human": human_readable_size(archive_size),
        "creation_date": creation_date,
        # "compression": {
        #     "algorithm": compression_algo,
        #     "level": compression_level,
        #     "lossless": True
        # },
        "encryption": {
            "key_derivation": key_generation_method,
            "enabled": encryption_enabled,
            "method": encryption_method
        },
        "enc_checksum": {
            "algorithm": "sha256",
            "value": "",
        },
        "checksum": {
            "algorithm": "sha256",
            "value": archive_checksum
        },
        "count": files_count,
        "files": files_info,
        "notes": None
    }

    return manifest

def main():
    print("Make Archive Manifest")

    if len(sys.argv) < 3:
        print("Usage: python generate_manifest_from_archive.py <archive_path.tar.zst> <storage_name> [compression_level]")
        sys.exit(1)

    archive_path = sys.argv[1]
    storage_name = sys.argv[2]
    encryption_method = sys.argv[3] if len(sys.argv) > 3 else None
    key_generation_method = sys.argv[4] if len(sys.argv) > 4 else None
    # compression_level = int(sys.argv[3]) if len(sys.argv) > 3 else None

    encryption_enabled = True if encryption_method else False

    if not os.path.isfile(archive_path):
        print(f"Error: Archive file '{archive_path}' not found.")
        sys.exit(1)

    manifest = generate_manifest(archive_path, storage_name, encryption_enabled=encryption_enabled, encryption_method=encryption_method, key_generation_method=key_generation_method)

    manifest_filename = archive_path + ".json"
    with open(manifest_filename, 'w') as f:
        json.dump(manifest, f, indent=4)

    print(f"Manifest saved to {manifest_filename}")

if __name__ == "__main__":
    main()

