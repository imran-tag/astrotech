# MySQL to PostgreSQL Migration Guide

This guide will help you migrate the AstroTech project from MySQL to PostgreSQL for deployment on Render.

## Changes Made

### 1. Database Schema
- Converted MySQL schema to PostgreSQL format
- Changed auto-increment columns to use SERIAL
- Replaced `datetime` with `TIMESTAMP`
- Added triggers for `ON UPDATE CURRENT_TIMESTAMP` functionality
- Converted foreign keys and constraints

### 2. Backend Code Changes
- Updated `package.json`: Replaced `mysql2` with `pg`
- Updated `db.js`: Converted from MySQL2 connection pool to PostgreSQL pool
- Added helper function to convert MySQL `?` placeholders to PostgreSQL `$1, $2, $3` format
- Updated all queries:
  - `result.insertId` → Use `RETURNING id` clause
  - `ON DUPLICATE KEY UPDATE` → `ON CONFLICT ... DO UPDATE`
  - `pool.query()` → `pool.execute()` for consistency

## Migration Steps

### Step 1: Install PostgreSQL Dependencies

```bash
cd back_end/technicien_api
npm install
```

This will install the new `pg` package.

### Step 2: Set Up PostgreSQL Database on Render

1. Log in to [Render](https://render.com)
2. Click "New +" → "PostgreSQL"
3. Configure your database:
   - **Name**: astro-tech-db
   - **Database**: astro_tech
   - **User**: (auto-generated)
   - **Region**: Choose closest to your users
   - **PostgreSQL Version**: 15 or later
   - **Plan**: Free or paid based on your needs
4. Click "Create Database"
5. Wait for the database to be provisioned
6. Copy the **Internal Database URL** (for connecting from Render services)

### Step 3: Create Database Schema

You have two options:

#### Option A: Using psql (Recommended)
1. From the Render dashboard, go to your PostgreSQL database
2. Click "Connect" and copy the **External Database URL**
3. Run the schema file:
```bash
psql <external-database-url> -f postgresql-schema.sql
```

#### Option B: Using Render Shell
1. From Render dashboard, click your database
2. Click "Shell" tab
3. Copy and paste the contents of `postgresql-schema.sql`

### Step 4: Configure Environment Variables

Create a `.env` file in `back_end/technicien_api/`:

```env
# Use the Internal Database URL from Render
DB_HOST=<your-render-db-host>
DB_PORT=5432
DB_USER=<your-render-db-user>
DB_PASSWORD=<your-render-db-password>
DB_NAME=astro_tech

# JWT Configuration
JWT_SECRET=<generate-a-strong-random-secret>
JWT_EXPIRES_IN=24h

# Server Configuration
PORT=3000
URI=/api/v1
```

**Note**: For Render deployment, you'll set these in the Render dashboard instead of a `.env` file.

### Step 5: Deploy Backend to Render

1. Push your code to GitHub
2. In Render dashboard, click "New +" → "Web Service"
3. Connect your GitHub repository
4. Configure the service:
   - **Name**: astro-tech-api
   - **Environment**: Node
   - **Region**: Same as your database
   - **Branch**: main (or your default branch)
   - **Root Directory**: `back_end/technicien_api`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
5. Add environment variables (click "Advanced"):
   - `DB_HOST` → Copy from database Internal Database URL
   - `DB_PORT` → 5432
   - `DB_USER` → Copy from database
   - `DB_PASSWORD` → Copy from database
   - `DB_NAME` → astro_tech
   - `JWT_SECRET` → Generate a strong random string
   - `JWT_EXPIRES_IN` → 24h
   - `PORT` → 3000
   - `URI` → /api/v1
6. Click "Create Web Service"

### Step 6: Deploy Frontend to Render

1. In Render dashboard, click "New +" → "Static Site"
2. Connect your GitHub repository
3. Configure the service:
   - **Name**: astro-tech-frontend
   - **Root Directory**: `front_end`
   - **Build Command**: `npm install && npm run build`
   - **Publish Directory**: `dist/astro-tech/browser` (adjust based on Angular output)
4. Add environment variables if needed (API URL, etc.)
5. Click "Create Static Site"

### Step 7: Update Frontend API URL

Update your Angular environment files to point to your Render backend URL:

**front_end/src/environments/environment.prod.ts**:
```typescript
export const environment = {
  production: true,
  apiUrl: 'https://astro-tech-api.onrender.com/api/v1'
};
```

### Step 8: Test the Application

1. Wait for both services to deploy
2. Visit your frontend URL: `https://astro-tech-frontend.onrender.com`
3. Test key functionality:
   - User registration and login
   - Creating/viewing technicians
   - Creating/viewing teams
   - All CRUD operations

## Troubleshooting

### Database Connection Issues
- Verify environment variables are set correctly
- Check that you're using the **Internal Database URL** for Render services
- Ensure your database is in the same region as your web service

### Query Errors
- PostgreSQL is case-sensitive for string comparisons
- Check for any remaining MySQL-specific syntax
- Review logs in Render dashboard

### Migration Errors
- Ensure the schema file ran successfully
- Check for foreign key constraint violations
- Verify all tables were created

## Key Differences: MySQL vs PostgreSQL

| Feature | MySQL | PostgreSQL |
|---------|-------|------------|
| Auto-increment | `AUTO_INCREMENT` | `SERIAL` |
| Placeholder | `?` | `$1, $2, $3` |
| Insert ID | `result.insertId` | `RETURNING id` |
| Upsert | `ON DUPLICATE KEY UPDATE` | `ON CONFLICT ... DO UPDATE` |
| Timestamp auto-update | `ON UPDATE CURRENT_TIMESTAMP` | Trigger function |
| Boolean | `TINYINT(1)` | `BOOLEAN` |
| String comparison | Case-insensitive | Case-sensitive |

## Rollback Plan

If you need to rollback to MySQL:
1. Restore your original `package.json` from git
2. Restore original `db.js`, service files, and controller files
3. Run `npm install` to reinstall MySQL packages
4. Use the original `24-12-2025.sql` file to recreate the MySQL database

## Next Steps

After successful migration:
1. Monitor application logs for any errors
2. Test all API endpoints thoroughly
3. Set up database backups in Render
4. Configure custom domains if needed
5. Set up monitoring and alerts

## Support

If you encounter issues:
- Check Render logs: Dashboard → Your Service → Logs
- Review PostgreSQL logs: Dashboard → Database → Logs
- Verify environment variables: Dashboard → Service → Environment

## Files Modified

### Backend
- ✅ `back_end/technicien_api/package.json` - Updated dependencies
- ✅ `back_end/technicien_api/db.js` - PostgreSQL connection pool
- ✅ `back_end/technicien_api/services/techniciens.services.js` - Updated queries
- ✅ `back_end/technicien_api/services/equipe_technicien.services.js` - Updated queries
- ✅ `back_end/technicien_api/controllers/_auth.controller.js` - Updated queries

### New Files
- ✅ `postgresql-schema.sql` - PostgreSQL database schema
- ✅ `back_end/technicien_api/.env.example` - Environment variables template
- ✅ `MIGRATION_GUIDE.md` - This file

## Performance Optimization

PostgreSQL performance tips:
1. Create indexes on frequently queried columns (already done in schema)
2. Use connection pooling (already configured in `db.js`)
3. Monitor slow queries using Render's database insights
4. Consider upgrading to a paid Render plan for better performance

---

**Migration completed successfully!** Your application is now ready to be deployed on Render with PostgreSQL.
