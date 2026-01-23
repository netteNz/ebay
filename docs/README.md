# eBay Auction Platform Documentation

This directory contains the MkDocs documentation for the eBay Auction Platform.

## Building the Documentation

### Install MkDocs and Material Theme

```bash
pip3 install mkdocs mkdocs-material
```

### Preview Locally

```bash
# From project root
mkdocs serve
```

Open browser to: `http://localhost:8000`

### Build Static Site

```bash
mkdocs build
```

Outputs to `site/` directory.

## Deploying to GitHub Pages

### Manual Deployment

```bash
mkdocs gh-deploy
```

This will:
1. Build the documentation
2. Push to `gh-pages` branch
3. GitHub Pages will serve it automatically

### Enable GitHub Pages

1. Go to repository Settings
2. Navigate to Pages section
3. Source: Deploy from branch
4. Branch: `gh-pages` / `root`
5. Save

Your docs will be available at:
```
https://nettenz.github.io/ebay/
```

### Automatic Deployment (GitHub Actions)

Create `.github/workflows/docs.yml`:

```yaml
name: Deploy Docs
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: 3.x
      - run: pip install mkdocs-material
      - run: mkdocs gh-deploy --force
```

## Documentation Structure

```
docs/
├── index.md                    # Landing page
├── getting-started.md          # Quick start guide
├── architecture.md             # System design
├── features/
│   ├── authentication.md       # Auth system
│   ├── products.md             # Product management
│   ├── bidding.md              # Bidding engine
│   └── admin.md                # Admin dashboard
├── database/
│   ├── schema.md               # Database structure
│   └── setup.md                # MySQL setup
├── api/
│   ├── servlets.md             # Servlet endpoints
│   └── filters.md              # Filter reference
├── deployment.md               # Production deployment
├── security.md                 # Security guide
└── contributing.md             # Contribution guidelines
```

## Customizing

Edit `mkdocs.yml` to:
- Change theme colors
- Add/remove pages
- Configure plugins
- Customize navigation

## Updating Documentation

1. Edit markdown files in `docs/`
2. Preview with `mkdocs serve`
3. Commit changes
4. Deploy with `mkdocs gh-deploy` or let CI/CD handle it

## Theme Customization

Material theme supports extensive customization. See:
https://squidfunk.github.io/mkdocs-material/

Examples:
- Custom colors
- Additional fonts
- Search configuration
- Social links
- Analytics integration
