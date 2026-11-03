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


def get_pr_numbers(owner: str, repo: str, all_folders: bool) -> list[int]:
    """Read PR numbers from the saved pull request files."""
    pr_dir = OUTPUT_DIR / "pull_requests" / f"{owner}__{repo}"
    files = sorted(pr_dir.glob("fetched=*/page_*.json"))
    if not files:
        raise SystemExit("No PR files found, run github_pull_requests.py first.")
    if not all_folders:
        latest_folder = files[-1].parent  # fetched=YYYY-MM-DD sorts oldest to newest
        files = [f for f in files if f.parent == latest_folder]

    numbers = set()  # a set, because the same PR can appear in several files
    for file in files:
        for pr in json.loads(file.read_text())["data"]:
            numbers.add(pr["number"])
    return sorted(numbers)


def ingest_reviews(owner: str, repo: str, all_folders: bool) -> None:
    session = requests.Session()
    session.headers.update({
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {os.environ['GITHUB_TOKEN']}",
        "X-GitHub-Api-Version": "2026-03-10",
    })
    fetched_date = datetime.now(timezone.utc).date().isoformat()
    numbers = get_pr_numbers(owner, repo, all_folders)
    print(f"Fetching reviews for {len(numbers)} PRs")

    for i, number in enumerate(numbers, start=1):
        url = f"{API}/repos/{owner}/{repo}/pulls/{number}/reviews"
        params = {"per_page": 100}
        page = 1
        while url:
            response = fetch_page(session, url, params)
            envelope = {
                "meta": {
                    "fetched_at": datetime.now(timezone.utc).isoformat(),
                    "url": response.url,
                    "status": response.status_code,
                    "pr_number": number,
                    "page": page,
                },
                "data": response.json(),  # saved exactly as received
            }
            save_raw(
                f"reviews/{owner}__{repo}/fetched={fetched_date}/pr_{number:06d}_page_{page:04d}.json",
                json.dumps(envelope),
            )
            wait_if_rate_limited(response)
            url = response.links.get("next", {}).get("url")  # the Link header
            params = None  # the next URL already carries its query string
            page += 1
        if i % 50 == 0:
            print(f"{i}/{len(numbers)} PRs done")
    print(f"Saved reviews for {len(numbers)} PRs")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--owner", required=True)
    parser.add_argument("--repo", required=True)
    parser.add_argument("--all", action="store_true", help="read every PR folder, not just the latest")
    args = parser.parse_args()
    ingest_reviews(args.owner, args.repo, args.all)
