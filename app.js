#!/usr/bin/env node
const puppeteer = require("puppeteer");

async function run() {
    const browser = await puppeteer.launch({
      headless: true,
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
    });
    const page = await browser.newPage();

    await page.goto(
        "https://www.laundryalert.com/cgi-bin/ucla6023/LMRoom?CallingPage=LMPage&Halls=8");

    let machines = await page.evaluate(() => {
        let machines = [];

        for (let i = 2; i < 42; i++) {
            let tr = document.querySelector(
                `#tablea > tbody > tr:nth-child(1) > td:nth-child(4) > form `+
                `> table:nth-child(4) > tbody > tr:nth-child(${i})`);
            let tds = tr.children;

            let index  = tds[2].children[0].children[0].children[0].innerHTML.trim();
            let type   = tds[3].children[0].children[0].innerHTML.trim();
            let status = tds[4].children[0].children[0].innerHTML.trim();
            let eta    = tds[5];

            // clean up status
            status = status.replace("<br>", "-").replace(/<(?:.|\n)*?>/gm, "");

            // clean up eta
            if (eta.innerHTML.trim().startsWith("<font"))
                eta = eta.children[0].innerHTML.trim();
            else
                eta = eta.innerHTML.trim();
            if (eta == "&nbsp;")
                eta = "";

            machines.push({index, type, status, eta});
        }

        return machines;
    });

    console.log("# " + (new Date()).toLocaleString());
    console.log("index,type,status,eta");
    for (let m of machines) {
        console.log(`${m.index},${m.type},${m.status},${m.eta}`);
    }

    browser.close();
}

run();
