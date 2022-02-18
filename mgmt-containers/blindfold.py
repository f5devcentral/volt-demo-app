import getpass
import sys
import cryptography.hazmat.primitives.serialization.pkcs12 as pkcs12

#pw = getpass.getpass()
pw = 'CredPassW0rd!'
if isinstance(pw, bytes):
    pw= pw.decode(sys.stdin.encoding)
pw = pw.encode('utf-8')

with open("../terraform/creds/f5-gsa.api-creds.p12", "rb") as f:
    test = pkcs12.load_key_and_certificates(f.read(), pw)
    key = pkcs12.serialize_key_and_certificates("test", test[0], test[1], None, None)


print(key)