import sys
import json
from instagrapi import Client

def fetch_user_id(username, password, handle):
    cl = Client()
    cl.login(username, password)
    if handle.startswith("@"):  # On enlève le @ si présent
        handle = handle[1:]
    try:
        user_id = cl.user_id_from_username(handle)
        print(json.dumps({"user_id": str(user_id)}))
    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print(json.dumps({"error": "Usage: fetch_user_id.py <username> <password> <handle>"}))
        sys.exit(1)
    username = sys.argv[1]
    password = sys.argv[2]
    handle = sys.argv[3]
    fetch_user_id(username, password, handle)
