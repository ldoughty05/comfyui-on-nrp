import requests
import time
import os

HUB_URL = "https://carson-jh.nrp-nautilus.io/"  # update if your hub URL differs
TOKEN = os.environ["JUPYTERHUB_API_TOKEN"]
HEADERS = {"Authorization": f"token {TOKEN}"}

STUDENTS = [
    # Add your students' JupyterHub usernames here, e.g.:
    "ldoughty2@huskers.unl.edu",
]

print(f"Pre-spawning {len(STUDENTS)} student servers...")

success, skipped, failed = 0, 0, 0

for user in STUDENTS:
    try:
        resp = requests.post(
            f"{HUB_URL}/hub/api/users/{user}/server",
            headers=HEADERS,
            timeout=10
        )
        if resp.status_code == 201:
            print(f"[STARTED]  {user}")
            success += 1
        elif resp.status_code == 400:
            print(f"[ALREADY RUNNING] {user}")
            skipped += 1
        else:
            print(f"[UNEXPECTED {resp.status_code}] {user}: {resp.text}")
            failed += 1
    except Exception as e:
        print(f"[ERROR] {user}: {e}")
        failed += 1
    time.sleep(3)  # avoid hammering the spawner

print(f"\nDone. Started: {success}, Already running: {skipped}, Failed: {failed}")