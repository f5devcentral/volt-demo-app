import http from 'k6/http';
import { sleep, check } from 'k6';
import {parseHTML} from "k6/html";

export function addRandAgent() {
    var agentHeaders = [
        {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'},
        {'User-Agent': 'Mozilla/5.0 CK={} (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko'},
        {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Brave Chrome/83.0.4103.116 Safari/537.36'}
    ]
    var agentHeader = {
        headers: agentHeaders[Math.floor(Math.random()*agentHeaders.length)]
    }
    return agentHeader;
}

export function crawler() {
    const base = `${__ENV.TARGET_URL}`
    const res = http.get(base, addRandAgent());
    const checkRes = check(res, {
        'status is 200': (r) => r.status === 200
      });
    const doc = parseHTML(res.body);
    doc.find("a").toArray().forEach(function (item) {
        if (item.attr("href").startsWith('http')) {
            var childRes = http.get(item.attr("href"), addRandAgent());
        } else {
            var childRes = http.get(base + item.attr("href"), addRandAgent());
        }
        if ( typeof childRes !== 'undefined') {
            const checkRes = check(childRes, {
                'status is 200': (r) => r.status === 200
              });
        }
     });
     sleep(.2);
}