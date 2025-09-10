# ✅ MeBeatMe Deployment Checklist

## Pre-Deployment
- [ ] Server: Ubuntu 20.04+ with root access
- [ ] Java 17+ installed (`java -version`)
- [ ] Nginx installed (`nginx -v`)
- [ ] Certbot installed (`certbot --version`)
- [ ] DNS control for ready2race.run

## Files to Upload
- [ ] `ProductionHttpServer.java`
- [ ] `dashboard.html`
- [ ] `deploy-ready2race.sh`
- [ ] `DEPLOYMENT_GUIDE.md`
- [ ] `config.env.example`

## Deployment Steps
- [ ] Upload files to server
- [ ] Make deployment script executable: `sudo chmod +x deploy-ready2race.sh`
- [ ] Run deployment: `sudo ./deploy-ready2race.sh`
- [ ] Check service status: `sudo systemctl status mebeatme-server`

## DNS Configuration
- [ ] Add A record: `mebeatme` → `[SERVER_IP]`
- [ ] Wait for DNS propagation (5-10 minutes)
- [ ] Test DNS: `nslookup mebeatme.ready2race.run`

## SSL Certificate
- [ ] Get SSL certificate: `sudo certbot --nginx -d mebeatme.ready2race.run`
- [ ] Test HTTPS: `curl https://mebeatme.ready2race.run/health`

## Strava Integration
- [ ] Update Strava app settings:
  - [ ] Callback URL: `https://mebeatme.ready2race.run/dashboard.html`
  - [ ] Website: `https://mebeatme.ready2race.run`
- [ ] Test Strava OAuth flow

## Testing
- [ ] Health endpoint: `curl https://mebeatme.ready2race.run/health`
- [ ] Dashboard loads: `https://mebeatme.ready2race.run/`
- [ ] Manual workout entry works
- [ ] Strava import works
- [ ] Delete functionality works

## Monitoring
- [ ] Service logs: `sudo journalctl -u mebeatme-server -f`
- [ ] Nginx logs: `sudo tail -f /var/log/nginx/mebeatme.ready2race.run.*`
- [ ] Server resources: `htop` or `top`

## Post-Deployment
- [ ] Bookmark: `https://mebeatme.ready2race.run`
- [ ] Share with users
- [ ] Set up monitoring alerts
- [ ] Schedule SSL renewal: `sudo crontab -e`

---

**🎉 Deployment Complete!**
Your MeBeatMe dashboard is live at:
**https://mebeatme.ready2race.run**
