from cryptography.hazmat.backends import _get_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import dsa, ec, rsa

pw = getpass.getpass()
if isinstance(pw, bytes):
    pw= pw.decode(sys.stdin.encoding)
pw = pw.encode('utf-8')

def load_key_and_certificates(data, password, backend=None):
    backend = _get_backend(backend)
    return backend.load_key_and_certificates_from_pkcs12(data, password)

with open("../terraform/creds/f5-gsa.api-creds.p12", "rb") as f:
    p12 = load_key_and_certificates(f.read(), pw)

print(p12)