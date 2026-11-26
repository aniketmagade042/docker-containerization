import os
import sys
import tempfile

os.environ["DATABASE_URL"] = "sqlite:///" + os.path.join(tempfile.mkdtemp(), "test.db")
os.environ["APP_ENV"] = "development"
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))

import app as guestbook  # noqa: E402


def client():
    guestbook.app.config["TESTING"] = True
    return guestbook.app.test_client()


def test_health():
    r = client().get("/health")
    assert r.status_code == 200 and r.get_json()["db"] == "ok"


def test_sign_and_list():
    c = client()
    c.post("/sign", data={"name": "Asha", "message": "Hello containers"})
    page = c.get("/").get_data(as_text=True)
    assert "Asha" in page and "Hello containers" in page


def test_escapes_html():
    c = client()
    c.post("/sign", data={"name": "Bob", "message": "<script>alert(1)</script>"})
    assert "<script>alert(1)</script>" not in c.get("/").get_data(as_text=True)
