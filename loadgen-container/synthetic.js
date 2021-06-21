import http from 'k6/http';
import { sleep, check } from 'k6';
import {parseHTML} from "k6/html";
import { addRandAgent } from './helpers.js';

export function synthetic() {
    const base = `${__ENV.TARGET_URL}`
    const res = http.get(base, addRandAgent());
    const checkRes = check(res, {
        'status is 200': (r) => r.status === 200
      });
    const doc = parseHTML(res.body);
    var products = doc.find("a").toArray()
    var product = products[Math.floor(Math.random()*products.length)] //have product URL

    //Add to Cart
    // form data
    //product_id=66VCHSJNUP&quantity=1
    //Checkout
}