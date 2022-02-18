import time
from wingman import isReady, unsealSecret

print(isReady())
test = unsealSecret("testsecret")
print(test)
time.sleep(3600)