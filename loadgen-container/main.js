import { sleep } from "k6";

import { crawler } from "./crawler.js";
import { exploit } from "./exploit.js";
import { synthetic } from "./synthetic.js";

export const options = {
    stages: [
      { target: 20, duration: `${__ENV.DURATION}` }
    ]
  };

const vars = [];

const isDebug = false;

function getRandom(min, max) {
    return Math.random() * (max - min) + min;
  }

export default function main() {
  crawler();
  exploit();
  synthetic();
  sleep(getRandom(2, 5));
}
