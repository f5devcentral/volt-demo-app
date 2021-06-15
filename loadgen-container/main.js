import { sleep } from "k6";

import { crawler } from "./crawler.js";

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
  sleep(getRandom(2, 5));
}
