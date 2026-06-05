# Routee - Local Setup Guide

## 📦 How to Move Project (Sharing Folder)

To move this project to another device:
- Copy the entire project folder (NOT partial)
- Use Google Drive / Flashdisk / File Transfer

> **IMPORTANT:**
> Make sure ALL folders are included.

## 📁 Required Files & Folders

Ensure these exist:

- `app/`
- `routes/`
- `resources/`
- `public/`
- `vendor/` (if available)
- `composer.json`
- `artisan`
- `.env`

## ⚙️ Setup on New Device

1. Open terminal in project folder

2. Install dependencies (if vendor folder missing):

```bash
composer install
```

3. Run the Application:

```bash
php artisan serve
```

4. View Project:
Open your browser and visit: `http://localhost:8000`

---
*Note: This project is configured to run fully without database dependencies for presentation purposes. Just ensure `php artisan serve` is running.*
