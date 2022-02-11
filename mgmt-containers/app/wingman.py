#wingman.py
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import json

retry_strategy = Retry(
    total=3,
    backoff_factor=1,
    status_forcelist=[429, 500, 503],
    method_whitelist=["HEAD", "GET", "OPTIONS"]
)
adapter = HTTPAdapter(max_retries=retry_strategy)
http = requests.Session()
http.mount("http://", adapter)

def isReady(wingman = 'localhost:8070') -> bool:
    url= "http://{0}/status".format(wingman)
    try:
        r = http.get(url)
        if r.status_code == 200:
            return True
        else:
            return False
    except:
        return False

def unsealSecret(encSecret, wingman = 'localhost:8070') -> str:
    url= "http://{0}/secret/unseal".format(wingman)
    payload = {
        "type": "blindfold",
        "location": encSecret
    }
    try:
        r = http.post(url, json=payload)
        return r.text
    except:
        raise Exception("Unable to unseal secret")
