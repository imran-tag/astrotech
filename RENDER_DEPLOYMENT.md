# Render Deployment Checklist

Follow these steps to deploy AstroTech to Render.

## ✅ Prerequisites
- [x] Git repository initialized
- [ ] GitHub account
- [ ] Render account (free at render.com)
- [ ] Code pushed to GitHub

---

## Step 1: Push to GitHub

Run these commands in your terminal:

```bash
# Add your GitHub repository (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/astrotech.git

# Push code to GitHub
git push -u origin main
```

**Create GitHub repo first:**
1. Go to https://github.com/new
2. Name: `astrotech`
3. Don't initialize with anything
4. Copy the repository URL and use it above

---

## Step 2: Create Render Account

1. Go to https://render.com
2. Click "Get Started" or "Sign Up"
3. Sign up with GitHub (recommended) or email
4. Verify your email

---

## Step 3: Create PostgreSQL Database

1. **In Render Dashboard:**
   - Click "New +" → "PostgreSQL"

2. **Configure:**
   - **Name**: `astrotech-db`
   - **Database**: `astro_tech`
   - **Region**: Oregon (US West) - or closest to you
   - **Instance Type**: Free

3. **Click "Create Database"** - wait ~2 minutes

4. **Get Connection Info:**
   - Once ready, go to your database
   - Click "Info" tab
   - Copy **Internal Database URL** (save for later)
   - Copy **External Connection String**

5. **Load Schema:**

   Open your terminal and run:
   ```bash
   # Install PostgreSQL client if needed
   # Mac: brew install postgresql
   # Windows: Download from postgresql.org

   # Load the schema
   cd /Users/imran/Downloads/astroTech-main
   psql "YOUR_EXTERNAL_CONNECTION_STRING" -f postgresql-schema.sql
   ```

   You should see:
   ```
   CREATE FUNCTION
   CREATE TABLE
   CREATE TRIGGER
   ...
   ```

---

## Step 4: Deploy Backend API

### A. Deploy Technicien API (Main API)

1. **In Render Dashboard:**
   - Click "New +" → "Web Service"
   - Select "Build and deploy from a Git repository"
   - Connect your GitHub account
   - Select your `astrotech` repository

2. **Configure Service:**
   ```
   Name:           astrotech-technicien-api
   Region:         Oregon (US West) - same as database
   Branch:         main
   Root Directory: back_end/technicien_api
   Runtime:        Node
   Build Command:  npm install
   Start Command:  npm start
   Instance Type:  Free
   ```

3. **Environment Variables** (Click "Advanced"):

   From your PostgreSQL **Internal Database URL**, extract the values:

   Example URL: `postgresql://user:password@host:5432/dbname`

   Add these:
   ```
   DB_HOST       = <host from internal URL>
   DB_PORT       = 5432
   DB_USER       = <user from internal URL>
   DB_PASSWORD   = <password from internal URL>
   DB_NAME       = astro_tech
   JWT_SECRET    = YOUR_SUPER_SECRET_KEY_CHANGE_THIS_32_CHARS_MIN
   JWT_EXPIRES_IN = 24h
   PORT          = 10000
   URI           = /api/v1
   ```

4. **Click "Create Web Service"**

5. **Wait for deployment** (~3-5 minutes)
   - Watch the logs for "Server running at..."
   - Copy your service URL: `https://astrotech-technicien-api.onrender.com`

6. **Test it:**
   ```bash
   curl https://astrotech-technicien-api.onrender.com/api/v1/
   ```

### B. Deploy Other APIs (Repeat for each)

If your app uses multiple APIs, repeat the process above for:

1. **Client API**
   - Root Directory: `back_end/client_api`
   - Name: `astrotech-client-api`
   - Same environment variables

2. **Affaires API**
   - Root Directory: `back_end/affaires_api`
   - Name: `astrotech-affaires-api`
   - Same environment variables

3. **Referent API**
   - Root Directory: `back_end/referent_api`
   - Name: `astrotech-referent-api`
   - Same environment variables

4. **Fichier API**
   - Root Directory: `back_end/fichier_api`
   - Name: `astrotech-fichier-api`
   - Same environment variables

---

## Step 5: Deploy Frontend

### A. Update Environment URLs

1. **Edit the file** `front_end/src/environments/environment.prod.ts`

2. **Replace the placeholder URLs** with your actual Render URLs:
   ```typescript
   export const environment = {
     production: true,
     technicienApiUrl: 'https://YOUR-ACTUAL-technicien-api.onrender.com/api/v1',
     clientApiUrl: 'https://YOUR-ACTUAL-client-api.onrender.com/api/v1',
     affairesApiUrl: 'https://YOUR-ACTUAL-affaires-api.onrender.com/api/v1',
     referentApiUrl: 'https://YOUR-ACTUAL-referent-api.onrender.com/api/v1',
     fichierApiUrl: 'https://YOUR-ACTUAL-fichier-api.onrender.com/api/v1',
     apiURL: 'https://YOUR-ACTUAL-technicien-api.onrender.com/api/v1'
   };
   ```

3. **Commit and push:**
   ```bash
   git add front_end/src/environments/environment.prod.ts
   git commit -m "Update API URLs for production"
   git push
   ```

### B. Deploy Frontend to Render

1. **In Render Dashboard:**
   - Click "New +" → "Static Site"
   - Select your GitHub repository

2. **Configure:**
   ```
   Name:            astrotech-frontend
   Branch:          main
   Root Directory:  front_end
   Build Command:   npm install && npm run build
   Publish Dir:     dist/astro-tech/browser
   ```

   **Note:** The publish directory might be different. After first build, check the logs to see where Angular outputs the files. Common paths:
   - `dist/astro-tech/browser`
   - `dist/astro-tech`
   - `dist/browser`

3. **Click "Create Static Site"**

4. **Wait for deployment** (~5-10 minutes for first build)

5. **Your frontend URL:** `https://astrotech-frontend.onrender.com`

---

## Step 6: Test Your Application

1. **Visit your frontend:**
   ```
   https://astrotech-frontend.onrender.com
   ```

2. **Test Registration:**
   - Create a new user account
   - Check if you can login

3. **Test Features:**
   - Create a technician
   - Create a team
   - Assign technicians to teams

4. **Check Backend Logs:**
   - In Render dashboard → Your service → "Logs" tab
   - Look for any errors

---

## Troubleshooting

### Database Connection Errors
- ✅ Verify `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD` are correct
- ✅ Use **Internal Database URL** for backend services, not external
- ✅ Ensure database and backend are in same region

### Frontend Can't Connect to Backend
- ✅ Check browser console for CORS errors
- ✅ Verify API URLs in `environment.prod.ts` are correct
- ✅ Ensure backend services are running (check Render dashboard)
- ✅ Test backend URLs directly in browser

### Build Failures
- ✅ Check "Logs" tab in Render dashboard
- ✅ Verify `package.json` has all dependencies
- ✅ Ensure Node version compatibility

### 404 Errors on Frontend
- ✅ Check "Publish Directory" is correct
- ✅ Look at build logs to see where files are output
- ✅ May need to add Angular routing configuration

---

## Important Notes

### Free Tier Limitations
- Services spin down after 15 minutes of inactivity
- First request after spin-down takes ~30 seconds
- Database: 90-day expiration on free tier
- 750 hours/month free tier limit shared across services

### Keeping Services Awake (Optional)
Use a service like cron-job.org to ping your backend every 14 minutes:
```
https://astrotech-technicien-api.onrender.com/api/v1/
```

### Upgrading to Paid
- $7/month per service for always-on
- $7/month for persistent database
- No credit card required for free tier

---

## Your Services Dashboard

Once deployed, you'll have:

| Service | URL | Type |
|---------|-----|------|
| Database | (internal only) | PostgreSQL |
| Technicien API | `https://astrotech-technicien-api.onrender.com` | Web Service |
| Client API | `https://astrotech-client-api.onrender.com` | Web Service |
| Affaires API | `https://astrotech-affaires-api.onrender.com` | Web Service |
| Referent API | `https://astrotech-referent-api.onrender.com` | Web Service |
| Fichier API | `https://astrotech-fichier-api.onrender.com` | Web Service |
| Frontend | `https://astrotech-frontend.onrender.com` | Static Site |

---

## Next Steps After Deployment

1. **Set up custom domain** (optional)
   - Render Dashboard → Static Site → "Settings" → "Custom Domain"

2. **Enable auto-deploy**
   - Already enabled by default
   - Every git push triggers new deployment

3. **Monitor your app**
   - Check logs regularly
   - Set up email notifications in Render

4. **Database backups**
   - Render provides automatic backups
   - Can also use `pg_dump` for manual backups

---

## Cost Summary (Free Tier)

- PostgreSQL: **Free** (90 days, then $7/month)
- Backend Services: **Free** (750 hrs/month per service)
- Frontend: **Free** (100GB bandwidth/month)

**Total: $0/month** for first 90 days (database free trial)

---

## Support

If you need help:
- Check Render docs: https://render.com/docs
- Render community: https://community.render.com
- Review MIGRATION_GUIDE.md for technical details

---

**You're all set! 🚀**

Your AstroTech application is now running on Render with PostgreSQL!
