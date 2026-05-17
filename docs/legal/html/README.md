# FocusForge Legal — Ready to Host

Two standalone HTML files that are the production legal pages for
FocusForge. Self-contained (inline CSS), responsive, adaptive to the
visitor's OS dark/light preference. Drop them onto any web host.

## Files

| File | Final URL |
|---|---|
| `privacy.html` | `https://kristenmartino.ai/focusforge/privacy` |
| `terms.html` | `https://kristenmartino.ai/focusforge/terms` |

## Deployment options (pick whichever matches your portfolio setup)

### Option 1: Static host with automatic clean URLs (Vercel, Netlify, Cloudflare Pages)

Most modern static hosts strip `.html` extensions automatically. If
kristenmartino.ai is deployed via one of these:

1. Copy these two files into your portfolio's `public/` (or `static/`)
   directory under a `focusforge/` folder:
   ```
   public/
     focusforge/
       privacy.html
       terms.html
   ```
2. Deploy as you normally would.
3. Visit `https://kristenmartino.ai/focusforge/privacy` — should resolve.

If your host requires the `.html` extension in the URL, the URLs become:
- `https://kristenmartino.ai/focusforge/privacy.html`
- `https://kristenmartino.ai/focusforge/terms.html`

Update the App Store Connect form to use whichever URL shape your host
gives you.

### Option 2: Static host requiring directory + index.html (GitHub Pages, some Apache configs)

Rename and reorganize:
```
focusforge/
  privacy/
    index.html   ← privacy.html renamed
  terms/
    index.html   ← terms.html renamed
```

Then URLs work without `.html` extensions.

### Option 3: Next.js / Astro / SvelteKit / similar framework

If your portfolio uses a JS framework, the simplest path:

1. Create new pages at the framework's route paths:
   - `app/focusforge/privacy/page.tsx` (Next.js App Router)
   - `pages/focusforge/privacy.tsx` (Next.js Pages Router)
   - `src/pages/focusforge/privacy.astro` (Astro)
2. Paste the contents of `privacy.html` (between `<body>` tags) into
   the page component.
3. Apply your portfolio's global styles, which will override the
   inline CSS in these files. Either way, the content reads fine.
4. Repeat for terms.

If you want to keep the inline-styled version (which matches FocusForge
brand more than your portfolio's default styles), serve the raw HTML
from a `public/` directory as in Option 1 above.

### Option 4: WordPress / Squarespace / no-code

1. Create a new page titled "Privacy Policy" with URL slug `privacy`
   under a parent page `/focusforge`
2. Paste the body content (everything between `<body>` and `</body>`)
   into the page's HTML/raw editor
3. The inline CSS will be ignored by most no-code platforms — your site
   theme will style it instead, which is fine
4. Repeat for Terms

## After deployment — verify

Visit each URL and check:
- [ ] Page loads at the expected URL (no 404)
- [ ] Both light and dark mode work (toggle your OS appearance)
- [ ] Nav bar at top links between Privacy ↔ Terms correctly
- [ ] Email links work (`mailto:privacy@kristenmartino.ai`,
      `mailto:legal@kristenmartino.ai`)
- [ ] GitHub repo links open (the AI Coach engine + main app)
- [ ] Mobile view renders cleanly (test on phone or DevTools narrow)
- [ ] Footer "Made with care" line appears

## Email setup

The Privacy + Terms reference these email addresses:

- `privacy@kristenmartino.ai`
- `legal@kristenmartino.ai`

You'll need either:
1. **Mail forwarding rules** on the kristenmartino.ai domain (most
   domain registrars / hosts offer free forwarding). Forward both
   addresses to your real inbox.
2. **A dedicated mailbox** for each (only if you expect volume —
   probably overkill for an indie app).

App Store Connect won't validate the URLs against the email — Apple
just checks that the URLs resolve. But if a user emails one of these
addresses and gets a bounce, that's a real privacy commitment failure.
Set up forwarding before submission.

## After App Store submission

These pages can stay as-is until v1.1 ships. When they need updates:

1. Edit the source markdown at `docs/legal/privacy-policy.md` or
   `docs/legal/terms-of-use.md`
2. Re-generate the HTML by editing this directory directly (the
   markdown → HTML conversion was done by hand the first time —
   keeping in sync is also manual; future iteration may automate via
   a markdown processor)
3. Update the "Last updated" date in both the HTML and the markdown
4. If changes are material per §15 of Terms or the equivalent in
   Privacy, announce the change in the in-app About screen and
   give 30 days' notice before they take effect

## What's inside the HTML — design notes

- **Adaptive color scheme**: respects the visitor's
  `prefers-color-scheme` OS preference. Light mode by default; dark
  mode if the OS is set to dark. No JavaScript needed.
- **Brand-aligned**: FFTheme purple (`#7b5fd4` light / `#b07dcb` dark)
  for links and accent borders. Matches the in-app About screen.
- **System font stack**: `-apple-system, BlinkMacSystemFont, ...` — no
  custom font load, no FOIT/FOUT, instant render.
- **Max-width 720px**: comfortable reading width. Centered on wider
  screens.
- **Mobile responsive**: shrinks gracefully at 600px breakpoint.
- **Print friendly**: light background + adequate contrast means it
  prints legibly without rules (some users will print legal documents).
- **No external dependencies**: no Google Fonts, no CDN, no analytics.
  These pages don't have analytics on purpose — they're privacy pages.

## Future migration to portfolio framework

If you later move from the deployed HTML to a templated version inside
your portfolio framework (Next.js, etc.), the markdown sources at
`docs/legal/*.md` remain the canonical truth. Regenerate from those.
