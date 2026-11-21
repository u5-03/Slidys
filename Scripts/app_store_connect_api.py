#!/usr/bin/env python3
"""CLI transport for App Store Connect API; credentials stay outside the repository."""
import argparse
import json
import os
from pathlib import Path

from testflight_distribute import Client


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("method", choices=["GET", "POST", "PATCH", "DELETE"])
    parser.add_argument("path", help="API path starting with /v1/")
    parser.add_argument("body_file", nargs="?", type=Path, help="JSON request body")
    args = parser.parse_args()
    if not args.path.startswith("/v1/"):
        parser.error("path must start with /v1/")
    home = Path(os.environ.get("ASC_HOME", "~/.appstoreconnect")).expanduser()
    configured = os.environ.get("ASC_ENV_FILE")
    candidates = [Path(configured).expanduser()] if configured else [home / "slidys.env", home / "shireka.env"]
    env_file = next((path for path in candidates if path.is_file()), None)
    values = {}
    if env_file:
        for line in env_file.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.removeprefix("export ").split("=", 1)
                values[key.strip()] = value.strip().strip("\"'")
    values.update(os.environ)
    if not all(values.get(key) for key in ["ASC_KEY_ID", "ASC_ISSUER_ID"]):
        parser.error("Configure ASC_KEY_ID and ASC_ISSUER_ID (see docs/testflight.md)")
    client = Client(values["ASC_KEY_ID"], values["ASC_ISSUER_ID"],
                    str(home / "private_keys" / f"AuthKey_{values['ASC_KEY_ID']}.p8"))
    body = json.loads(args.body_file.read_text()) if args.body_file else None
    print(json.dumps(client.request(args.method, args.path, body), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
