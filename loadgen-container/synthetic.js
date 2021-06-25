import http from 'k6/http';
import { sleep, check } from 'k6';
import {parseHTML} from "k6/html";
import { addRandAgent } from './helpers.js';

export function synthetic() {
    const base = `${__ENV.TARGET_URL}`
    let res = http.get(base, addRandAgent());
    const doc = parseHTML(res.body);
    //Get a product
    let products = doc.find("a").toArray()
    products = products.filter(item => item.attr("href") !== "/cart")
    var product = products[Math.floor(Math.random()*products.length)]
    //Add to Cart
    let data = {
      product_id: product.attr("href").split("/").pop(),
      quantity: 1
    };
    res = http.post(base.concat("/cart"), data);
    check(res, {
      'status is 200': (r) => r.status === 200
    });
    sleep(.2);
    //Checkout
    data = {
      email: "someone@example.com",
      street_address: "1600 Amphitheatre Parkway",
      zip_code: "94043",
      city: "Mountain View",
      state: "CA",
      country: "United States",
      credit_card_number: "4432-8015-6152-0454",
      credit_card_expiration_month: 1,
      credit_card_expiration_year: 2024,
      credit_card_cvv: 789
    };
    res = http.post(base.concat("/cart/checkout"), data);
    check(res, {
      'status is 200': (r) => r.status === 200
    });
    sleep(.2)
  }