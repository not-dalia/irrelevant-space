---
title: "One Worker to Track Them All: Injecting Analytics Scripts into Multiple Websites with Cloudflare Workers"
type: note
topics:
  - Web development
  - JavaScript
  - Cloudflare
created_at: 2023-12-17T03:01:00+00:00
---
For a while now, I've been creating mini web tools to test out ideas or as tiny helpers for myself. I usually publish them on individual subdomains, which might not be the best idea, but I like the concept of a short, easy-to-remember URL. Recently, I discovered that some of these tools actually have a few users, which made me consider adding analytics to them. After a bit of research, I settled on [umami](https://umami.is/). It's a great little privacy-conscious tool with exactly what I need and nothing more.

The issue with having so many subdomains is that you'd have to add a different tracking script to each one of them, treating them as individual websites. Modifying each project to add the script sounds a bit tedious. If only there was a way to map each subdomain to its script.

## The Solution
Except that there is. [Cloudflare](https://cloudflare.com/) is pretty great for free SSL certificates and DNS management, but they also offer a free Workers plan. A [Cloudflare worker](https://developers.cloudflare.com/workers/) is basically JavaScript code that runs on Cloudflare's edge network and handles HTTP traffic. You can do a lot with workers, including modifying/rewriting HTML responses. You can probably see where this is going: If a worker can modify HTML responses, then it can inject the umami script into every HTML response.

I modified one of the existing workers examples, and it worked on the first attempt. Initially, the first version of the worker had a dictionary mapping each hostname to the relevant Umami ID and injected that accordingly. I've changed that since to use environment variables. This way, adding a new subdomain is as simple as adding the hostname and the Umami ID to the worker's environment variables, which you can do from Cloudflare's dashboard.

## The Execution
Getting started with Cloudflare workers is pretty simple. You can follow the [get started guide](https://developers.cloudflare.com/workers/get-started/guide/) to get a basic worker up and running. The worker I ended up with is pretty simple. When a request comes in, the worker checks if the response is HTML. If it is, it looks up the hostname in the environment variables and uses [`HTTPRewriter`](https://developers.cloudflare.com/workers/runtime-apis/html-rewriter/) to rewrite the `<head>` tag and inject the umami script. If the response is not HTML or the hostname is not found in the environment variables, the worker just passes the response through.

```javascript
export default {
  async fetch(request, env) {
    const BASE_UMAMI_URL = "https://eu.umami.is/script.js";
    const hostname = new URL(request.url).hostname;
    // get the umami id from the environment variables
    const umamiId = env[hostname];

    class ScriptInjector {
      element(element) {
        element.append(`<script async data-website-id="${umamiId}" src="${BASE_UMAMI_URL}"></script>`, {
          html: true, // html: true rewrites the string as HTML, otherwise it's escaped as text
        });
      }
    }

    const response = await fetch(request);

    try {
      const contentType = response.headers.get("content-type");
      const isHtml = contentType && contentType.includes("text/html");

      // if the response is html and we have an umami id for the hostname, transform the <head> tag
      if (umamiId && isHtml) {
        return new HTMLRewriter().on("head", new ScriptInjector()).transform(response);
      } else {
        return response;
      }
    } catch (e) {
      return response;
    }
  }
}
```

After creating the worker, the [environment variables can be set from the dashboard or using Wrangler](https://developers.cloudflare.com/workers/configuration/environment-variables/). Once the worker is deployed, it can be added to a route. I added it to the `*.<domain>.com/*` route, which means that it will run on all subdomains of `<domain>.com`. You don't have to stick to one domain only. You can add multiple domains to the same worker and have it inject the script into all of them.

> [!info]
> Instead of using environment variables, you should be able to use [KV](https://developers.cloudflare.com/kv/) to store the hostname-Umami ID mapping. I haven't tried this yet, but I plan to do so soon.

## A Word of Caution
This solution ended up working almost perfectly. However, one project had the script vanish mysteriously right after the page loads. This specific project uses VueJS, so I'm guessing Vue is the culprit behind this disappearing act. Investigating this is a task for [[Future Me]], so I'll leave it at that for now.