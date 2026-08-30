# Hosting Cost Comparison

**Scenario:** A small fitness website (5–50 MB total, ~100–1,000 monthly visitors, minimal API calls)  
**Timeline:** Comparison reflects 2026 pricing; verify directly before final decision.

---

## Quick Summary

| Provider | Free/Minimal Cost | Learning Value | Setup Complexity | Verdict |
|---|---|---|---|---|
| **GitHub Pages** | $0 | Low | Very Low | Best for no cost + simple setup |
| **Cloudflare Pages** | $0 | Medium | Low | Excellent for free tier with edge nodes |
| **AWS S3 + CloudFront** | ~$1–10/mo* | High | Medium | Best if AWS depth matters & costs stay low |

*Assumes: 100–500 GB/month requests, 50–500 MB storage, no data transfer charges between regions.

---

## Detailed Comparison

### 1. GitHub Pages

**Cost:**
- Free hosting on `github.io` or custom domain
- No bandwidth charges
- No storage charges
- No build minutes charged (public repos)

**Hosting Stack:**
- Static files only; Jekyll builds optional
- HTTPS included
- CDN not explicitly mentioned; performance varies by geography

**Privacy & Data:**
- GitHub logs visitor IP for security
- Public repository source code visible unless private (private repos supported on Pro)
- No control over third-party analytics by default

**Learning Value:**
- Minimal (no infrastructure control, no scaling, no deployment pipes to manage)

**Pros:**
- Literally zero cost
- Dead-simple workflow: push to repo, site deploys
- Built-in HTTPS and DNS
- Integrated with your code versioning

**Cons:**
- No control over caching, headers, redirects, or routing (limited in paid tier)
- Public source code by default (unless private repo, which needs a paid GitHub account)
- No DDoS protection, rate limiting, or geographic routing
- IP logging is a minor privacy concern if Sheldon cares

**Best for:**
- No budget, maximum simplicity, public content is fine

---

### 2. Cloudflare Pages

**Cost:**
- Free tier: unlimited static sites, 500 builds/month, 500 MB per deployment
- Paid tier: $20/mo for increased builds and preview limits
- No bandwidth charges (covered by Cloudflare's global CDN)

**Hosting Stack:**
- Deploys via Git (GitHub, GitLab, etc.)
- Global edge network; pages served from servers near the visitor
- HTTPS included
- Built-in redirects, URL rewriting, custom headers support

**Privacy & Data:**
- Cloudflare's privacy policy covers analytics (can be disabled)
- Source code stays on your Git provider (GitHub, etc.)
- No IP logging for visitor privacy (unlike GitHub Pages)

**Learning Value:**
- Medium: edge-network principles, CDN behavior, deploy pipelines, basic security headers

**Pros:**
- Free for unlimited static sites
- Global CDN included (performance advantage over GitHub)
- Git-push-to-deploy workflow
- Can set custom HTTP headers, redirects, Content-Security-Policy
- Excellent security headers support
- Better privacy than GitHub Pages (no IP logging)
- Enterprise-grade DDoS protection included

**Cons:**
- Slightly more setup than GitHub Pages (connect Git provider, configure build settings)
- Free tier has 500 builds/month (a few per day, usually enough)
- Requires a Cloudflare account

**Best for:**
- Free hosting with global performance, privacy-conscious approach, some security control

---

### 3. AWS S3 + CloudFront

**Cost (typical small site):**

| Component | Monthly Cost |
|---|---|
| S3 storage (100 MB–500 MB) | ~$0.02–0.10 |
| S3 GET requests (10k–100k/mo) | ~$0.04–0.40 |
| CloudFront data out (10 GB–100 GB/mo) | ~$0.50–5.00 |
| CloudFront HTTP requests (10k–100k/mo) | ~$0.01–0.10 |
| Route 53 DNS (optional) | $0.40 (per hosted zone) |
| **Total estimate** | **~$1–6 per month** |

AWS also offers a **free tier** for the first 12 months:
- S3: 5 GB storage, 20k GET requests free/month
- CloudFront: 50 GB data out free/month
- Route 53: No free tier, but $0.40/month if used

After free tier, real costs settle around $1–5/month for a small site.

**Hosting Stack:**
- Private S3 bucket with CloudFront distribution
- HTTPS via ACM (free certificate)
- Custom domain via Route 53 or external registrar
- Full control over caching, TTLs, headers, redirects, etc.

**Privacy & Data:**
- You control where data is stored and replicated (region selection)
- No automatic IP logging (can enable CloudFront access logs if desired)
- S3 bucket policy and IAM roles control access tightly

**Learning Value:**
- High: S3 buckets, IAM roles, CloudFront distributions, origin access controls, SSL certificates, DNS, cache invalidation, security headers, monitoring via CloudWatch
- Direct experience with AWS infrastructure; builds knowledge applicable to larger systems

**Pros:**
- Very low cost, especially in free tier (first year essentially free)
- Complete control: headers, redirects, cache behavior, origin policies
- Integrates with other AWS services (Lambda for future features, Analytics, logging, etc.)
- Highly reliable and scalable (built for enterprise use)
- Strong privacy-forward: no automatic tracking, you decide what's logged

**Cons:**
- More initial setup than GitHub Pages or Cloudflare (bucket policy, CloudFront distribution, SSL cert, DNS)
- You own the infrastructure; misconfiguration can expose the bucket or fail health checks
- Requires AWS account and basic IAM/networking knowledge
- `git push` deploy is not native; requires a CI/CD tool or custom script (GitHub Actions, CodeBuild, etc.)

**Best for:**
- Learning AWS infrastructure at production scale, cost-sensitive but willing to invest setup time, full control preference, future-proofing for more complex backend needs

---

## Recommendation

**For lowest cost with zero setup:** GitHub Pages ($0, instant setup).

**For cost + performance + some security control:** Cloudflare Pages ($0, global edge network, privacy-friendly, good defaults).

**For learning + minimal cost:** AWS S3 + CloudFront ($1–5/mo after free tier, hands-on infrastructure knowledge, maximum control, integrates with future Flask backend if needed).

---

## A Note on Learning and Future Flexibility

If you want to expand later—say, adding a Flask backend for appointment reminders, subscription management, or analytics—AWS setup pays dividends:

- S3 can serve the static site
- Lambda + API Gateway can host the Flask app (serverless, near-free for low traffic)
- DynamoDB can store minimal session data if truly required
- You already understand the region, IAM, and networking layers

GitHub Pages and Cloudflare Pages, by contrast, lock you into static sites. Moving to a custom backend requires migration to a different host.

**Recommendation:** If learning AWS is a goal and the extra $1–5/month is acceptable, use S3 + CloudFront. You'll gain real infrastructure knowledge that applies to Sheldon's site now and your career broadly. If you want to launch fast with zero hassle and cost, choose Cloudflare Pages.

---

## Deployment Workflow Sketch

### GitHub Pages
```
git push → GitHub → Automatic deploy to github.io
```

### Cloudflare Pages
```
git push → GitHub/GitLab → Cloudflare webhook detects push → Automatic deploy
```

### AWS S3 + CloudFront
```
git push → GitHub Actions (or manual) → aws s3 sync . s3://bucket/ → CloudFront invalidation
```

The AWS workflow requires a script or CI/CD action, but it's straightforward with GitHub Actions (free for public repos, included in GitHub Pro).

---

## Privacy Recap

All three are HTTPS-enabled and can use custom domains. Privacy differs slightly:

- **GitHub Pages:** Logs visitor IP addresses for security.
- **Cloudflare Pages:** Does not log visitor IPs; serves from edge; respects visitor privacy by default.
- **AWS S3 + CloudFront:** Does not automatically log IPs; logging is opt-in via CloudFront access logs; you control what's stored.

For Sheldon's fitness site, this likely doesn't matter unless you add a contact form or newsletter signup. A simple privacy notice pointing to Calendly and PayPal's policies is sufficient initially.

---

## Decision Matrix for You

| Question | Favors |
|---|---|
| "I want zero cost and instant launch" | GitHub Pages |
| "I want zero cost + good global performance + privacy defaults" | Cloudflare Pages |
| "I want to learn AWS infrastructure, don't mind $1–5/mo, and may add a backend later" | AWS S3 + CloudFront |
| "I'm in a hurry and cost is not a concern" | Any of these |

Choose Cloudflare Pages or AWS S3 + CloudFront. GitHub Pages is technically simpler, but Cloudflare's performance and AWS's learning value are worth the modest extra effort.
