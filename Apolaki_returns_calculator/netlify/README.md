# Apolaki Solar Platform - Netlify Deployment

A complete solar ROI assessment platform ready for Netlify deployment.

## 📁 Project Structure

```
netlify/                        ← Deploy this folder
├── index.html                  ← Landing page (at root)
├── netlify.toml                ← Netlify config
├── pages/                      ← Application pages
│   ├── assessment.html         ← Solar assessment with map
│   ├── marketplace.html        ← Installer marketplace
│   ├── finance.html            ← Financing options
│   ├── contracts.html          ← Smart contracts
│   ├── monitor.html            ← System monitoring
│   ├── credits.html            ← Carbon credits
│   └── about.html              ← About page
├── css/                        ← Stylesheets
├── js/                         ← JavaScript
├── config/                     ← Configuration
│   └── database.json           ← Database schema
└── netlify/functions/api/      ← Go serverless API
```

## 🚀 Deploy to Netlify

1. Go to https://app.netlify.com/drop
2. Drag the `netlify` folder onto the page
3. Done!

## ⚡ Features

- Solar assessment with NASA POWER API
- Interactive map (Leaflet)
- Mock mode toggle for testing
- Go serverless API functions
