import http from 'k6/http';
import { sleep, check } from 'k6';
import {parseHTML} from "k6/html";
import { addRandAgent } from './helpers.js';

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