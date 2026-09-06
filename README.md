# Sheldon Fitness Website

A privacy-conscious, low-cost website for Sheldon, a fitness professional. The site will advertise services, let clients book appointments, and accept payments without storing sensitive client data in a custom application unless a future requirement makes that necessary.

## Product goals

- Present Sheldon's services, credentials, availability, and contact details.
- Let a client book a session through Calendly.
- Let a client pay through PayPal, ideally from the booking confirmation or service page.
- Keep the custom site free of health information, payment details, passwords, and unnecessary personal data.
- Keep hosting, maintenance, and operational complexity low.

## Proposed architecture

```text
Client browser
    |
    | HTTPS
    v
Static site on Amazon S3 + CloudFront (or an equivalent static host)
    |                         |
    | booking link/embed       | payment link/button
    v                         v
Calendly                     PayPal

Optional future Flask API only for a requirement that cannot be handled by a managed service.
```

### Why start static

A static site has no application server, database, login system, or custom payment code to secure. It also has very low hosting cost and little maintenance. React is not necessary for the initial site; plain HTML/CSS/JavaScript is sufficient and avoids adding a Node build dependency.

### Service boundaries

- **Calendly:** appointment availability, booking workflow, reminders, and scheduling data.
- **PayPal:** payment processing and payment data. Never collect card numbers on this site.
- **Website:** public marketing content and links to those services only.
- **Custom backend:** deliberately absent from version one.

Review Calendly and PayPal data-processing terms, retention settings, privacy controls, and business-account configuration before launch. The website privacy notice should clearly identify what each provider receives and link to their policies.

## Hosting recommendation

Start with **Amazon S3 + CloudFront** if AWS familiarity and infrastructure control matter. Use a private S3 bucket, CloudFront Origin Access Control, HTTPS-only access, a custom domain, and Route 53 DNS. This is inexpensive for a small site, but AWS setup has more moving parts than a managed static host.

A managed static host such as **Cloudflare Pages, GitHub Pages, or AWS Amplify Hosting** may be simpler. Compare current pricing, custom-domain support, build/deploy workflow, and business/privacy terms before choosing. Do not deploy EKS or a continuously running Flask container for this first version; the fixed cost and operational surface are unnecessary.

Expected infrastructure cost for a small static site is typically near the cost of the domain plus minimal request/storage charges. Calendly and PayPal fees depend on the plan, transaction volume, and product used, so verify current pricing directly before committing.

## Security and privacy baseline

- Use HTTPS everywhere and redirect HTTP to HTTPS.
- Keep the hosting bucket private; serve it through the CDN rather than public bucket URLs.
- Use least-privilege AWS IAM roles and MFA on all administrative accounts.
- Store no client health details, payment details, or appointment notes in the repository or browser local storage.
- Do not add analytics, marketing pixels, contact forms, or tracking cookies until their privacy impact and consent requirements are understood.
- Use provider-hosted booking and payment pages when possible instead of embedded third-party forms.
- Add a plain-language privacy notice, terms/cancellation policy, and contact method before launch.
- Keep secrets out of source control; for this version there should be no application secrets at all.
- Configure security headers where the chosen host supports them, including a restrictive Content-Security-Policy appropriate for Calendly/PayPal links.
- Establish a process for handling client data requests, cancellations, refunds, and account access with the providers.

This is an engineering starting point, not legal or regulatory advice. Confirm applicable privacy, tax, accessibility, and health-data obligations for Sheldon's location and clientele.

## Delivery plan

1. Confirm service offerings, prices, durations, cancellation policy, service area, brand assets, and contact details.
2. Create and configure Calendly and PayPal business accounts; keep test/sandbox and production links separate.
3. Build responsive pages: Home, Services, About, FAQ/Policies, and Book/Pay.
4. Add accessible navigation, clear calls to action, keyboard support, readable contrast, and mobile layouts.
5. Add privacy notice and provider disclosures.
6. Deploy to the selected static host with a custom domain and HTTPS.
7. Verify booking, payment, cancellation/refund, mobile, accessibility, and failure states manually.
8. Set up lightweight operational documentation and backups for content/configuration.

## Open decisions

- Business name, service area, and preferred domain.
- Which services can be booked online and whether payment is required before booking.
- Calendly plan and whether an external booking page or embedded widget is preferred.
- PayPal product/link type, currency, taxes, refunds, and cancellation handling.
- AWS static hosting versus a simpler managed static host.
- Whether a no-data contact method is enough, or whether a form is truly needed.
- Brand direction, photos, accessibility requirements, and launch date.

## Local development

Node is not required for the initial version. The site can be previewed with Python's built-in server once the first HTML files are added:

```bash
cd public
python3 -m http.server 8000
```

Open `http://localhost:8000` in a browser.
