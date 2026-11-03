import argparse
import json
import os
import time
from datetime import datetime, timezone
from pathlib import Path

import requests

API = "https://api.github.com"
OUTPUT_DIR = Path(os.environ.get("RAW_OUTPUT_DIR", "data/raw"))

def save_raw(relative_path: str, text: str) -> None:
    """Write one raw file. Swap this function later to write to cloud storage."""
    path = OUTPUT_DIR / relative_path
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def wait_if_rate_limited(response: requests.Response) -> None:
    remaining = int(response.headers.get("X-RateLimit-Remaining", 1))
    reset_at = int(response.headers.get("X-RateLimit-Reset", 0))
    if remaining < 5:
        sleep_for = max(reset_at - time.time(), 0) + 1
        print(f"Rate limit nearly used up, sleeping {sleep_for:.0f}s")
        time.sleep(sleep_for)


def fetch_page(session: requests.Session, url: str, params: dict | None) -> requests.Response:
    for attempt in range(3):
        response = session.get(url, params=params, timeout=30)
        if response.status_code < 500:
            break
        time.sleep(2 ** attempt)  # server error: wait 1s, 2s, 4s and retry
    response.raise_for_status()
    return response


def ingest_commits(owner: str, repo: str, since: str | None) -> None:
    session = requests.Session()
    session.headers.update({
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {os.environ['GITHUB_TOKEN']}",
        "X-GitHub-Api-Version": "2026-03-10",
    })
    fetched_date = datetime.now(timezone.utc).date().isoformat()
    url = f"{API}/repos/{owner}/{repo}/commits"
    params = {"per_page": 100}
    if since:
        params["since"] = since

    page = 1
    while url:
        response = fetch_page(session, url, params)
        envelope = {
            "meta": {
                "fetched_at": datetime.now(timezone.utc).isoformat(),
                "url": response.url,
                "status": response.status_code,
                "page": page,
            },
            "data": response.json(),  # saved exactly as received
        }
        save_raw(
            f"commits/{owner}__{repo}/fetched={fetched_date}/page_{page:04d}.json",
            json.dumps(envelope),
        )
        wait_if_rate_limited(response)
        url = response.links.get("next", {}).get("url")  # the Link header
        params = None  # the next URL already carries its query string
        page += 1
    print(f"Saved {page - 1} pages")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--owner", required=True)
    parser.add_argument("--repo", required=True)
    parser.add_argument("--since", help="ISO 8601, e.g. 2026-10-23T00:00:00Z")
    args = parser.parse_args()
    ingest_commits(args.owner, args.repo, args.since)