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
    // Post form data for product: product_id=66VCHSJNUP&quantity=1
    //Checkout 
    // Post to /cart/checkout
    /*
    email=someone%40example.com&street_address=1600+Amphitheatre+Parkway&zip_code=94043&city=Mountain+View&state=CA&country=United+States&credit_card_number=4432-8015-6152-0454&credit_card_expiration_month=1&credit_card_expiration_year=2022&credit_card_cvv=672
    */
  }