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


def fetch_page(session: requests.Session, url: str) -> requests.Response:
    for attempt in range(3):
        response = session.get(url, timeout=30)
        if response.status_code < 500:
            break
        time.sleep(2 ** attempt)  # server error: wait 1s, 2s, 4s and retry
    response.raise_for_status()
    return response


def ingest_repos(owner: str, repo: str) -> None:
    session = requests.Session()
    session.headers.update({
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {os.environ['GITHUB_TOKEN']}",
        "X-GitHub-Api-Version": "2026-03-10",
    })
    fetched_date = datetime.now(timezone.utc).date().isoformat()
    url = f"{API}/repos/{owner}/{repo}"        
    response = fetch_page(session, url)
    envelope = {
        "meta": {
            "fetched_at": datetime.now(timezone.utc).isoformat(),
            "url": response.url,
            "status": response.status_code,

        },
        "data": response.json(),  # saved exactly as received
    }
    save_raw(
        f"repos/{owner}__{repo}/fetched={fetched_date}/repo.json",
        json.dumps(envelope),
    )
    wait_if_rate_limited(response)
    print(f"Saved {repo}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--owner", required=True)
    parser.add_argument("--repo", required=True)
    args = parser.parse_args()
    ingest_repos(args.owner, args.repo)