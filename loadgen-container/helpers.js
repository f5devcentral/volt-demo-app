import { SharedArray } from "k6/data";

var agentHeaders = new SharedArray("all the agents", function() {
    var f = JSON.parse(open("./user-agents.json"));
    return f;
});

export function addRandAgent() {
    var element = agentHeaders[Math.floor(Math.random() * agentHeaders.length)]
    var agentHeader = {
        headers: {'User-Agent': element.userAgent}
    }
    return agentHeader;
}