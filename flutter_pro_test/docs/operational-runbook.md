# CareNow MVP - Operational Runbook

## Table of Contents
1. [Daily Operations](#daily-operations)
2. [Monitoring Procedures](#monitoring-procedures)
3. [Incident Response](#incident-response)
4. [Maintenance Procedures](#maintenance-procedures)
5. [Backup and Recovery](#backup-and-recovery)
6. [Performance Optimization](#performance-optimization)
7. [Security Operations](#security-operations)
8. [Emergency Procedures](#emergency-procedures)

## Daily Operations

### Morning Checklist (9:00 AM VN Time)
```bash
# 1. Check system health
curl -s https://carenow.com/health | jq '.'

# 2. Review monitoring dashboard
# Access: https://carenow.com/admin/monitoring
# Check: System status, alerts, performance metrics

# 3. Verify Firebase services
firebase projects:list
firebase use production
firebase hosting:channel:list

# 4. Check error rates
# Firebase Console > Crashlytics
# Review: New crashes, error trends, affected users

# 5. Performance review
# Firebase Console > Performance
# Check: App start time, network requests, screen rendering
```

### Daily Monitoring Tasks
- [ ] System health status verification
- [ ] Active alerts review and resolution
- [ ] Performance metrics analysis
- [ ] Security incident review
- [ ] User feedback monitoring
- [ ] Business metrics validation
- [ ] Database performance check
- [ ] CDN and hosting status verification

### Evening Checklist (6:00 PM VN Time)
```bash
# 1. Generate daily report
node scripts/generate-daily-report.js

# 2. Backup critical data
firebase firestore:export gs://carenow-backups/$(date +%Y%m%d)

# 3. Review day's incidents
# Document any issues and resolutions

# 4. Plan next day's maintenance
# Schedule any required updates or patches
```

## Monitoring Procedures

### Real-Time Monitoring
**Access Unified Monitoring Dashboard:**
```
URL: https://carenow.com/admin/monitoring
Login: admin@carenow.com
```

**Key Metrics to Monitor:**
1. **System Health**
   - Overall system status
   - Service availability
   - Response times
   - Error rates

2. **Performance Metrics**
   - Page load times (<3s)
   - API response times (<500ms)
   - Memory usage (<512MB)
   - CPU utilization (<80%)

3. **Security Monitoring**
   - Failed login attempts
   - Suspicious activities
   - Security alerts
   - Compliance status

4. **Business Metrics**
   - Active users
   - Booking conversions
   - Payment success rates
   - User satisfaction scores

### Alert Thresholds
```yaml
# Alert configuration
alerts:
  system_health:
    critical: system_down
    warning: response_time > 3s
    
  performance:
    critical: error_rate > 5%
    warning: response_time > 1s
    
  security:
    critical: security_breach
    warning: failed_logins > 10/min
    
  business:
    critical: payment_failure > 10%
    warning: conversion_rate < 5%
```

### Monitoring Tools Access
- **Firebase Console**: https://console.firebase.google.com
- **Google Analytics**: https://analytics.google.com
- **Crashlytics**: Firebase Console > Crashlytics
- **Performance Monitoring**: Firebase Console > Performance
- **Custom Dashboard**: https://carenow.com/admin/monitoring

## Incident Response

### Incident Classification
**P0 - Critical (Response: Immediate)**
- System completely down
- Data breach or security incident
- Payment system failure
- Database corruption

**P1 - High (Response: 1 hour)**
- Partial system outage
- Performance degradation >50%
- Authentication failures
- Critical feature unavailable

**P2 - Medium (Response: 4 hours)**
- Minor feature issues
- Performance degradation <50%
- Non-critical bugs
- UI/UX issues

**P3 - Low (Response: 24 hours)**
- Enhancement requests
- Minor bugs
- Documentation updates
- Cosmetic issues

### Incident Response Process
1. **Detection**
   - Automated alerts
   - User reports
   - Monitoring dashboard
   - Health checks

2. **Assessment**
   - Determine severity level
   - Identify affected systems
   - Estimate impact scope
   - Assign response team

3. **Response**
   - Implement immediate fixes
   - Communicate with stakeholders
   - Document actions taken
   - Monitor resolution progress

4. **Resolution**
   - Verify fix effectiveness
   - Restore full functionality
   - Update monitoring systems
   - Conduct post-incident review

### Emergency Contacts
```
Primary On-Call: +84-xxx-xxx-xxx
Secondary On-Call: +84-xxx-xxx-xxx
Technical Lead: tech-lead@carenow.com
Product Manager: pm@carenow.com
CEO: ceo@carenow.com
```

### Incident Communication Template
```
Subject: [P{LEVEL}] {INCIDENT_TITLE} - {STATUS}

Incident: {INCIDENT_ID}
Status: {INVESTIGATING/IDENTIFIED/MONITORING/RESOLVED}
Impact: {DESCRIPTION}
Affected Services: {LIST}
Start Time: {TIMESTAMP}
Next Update: {TIMESTAMP}

Current Actions:
- {ACTION_1}
- {ACTION_2}

Updates will be provided every 30 minutes until resolved.
```

## Maintenance Procedures

### Weekly Maintenance (Sundays 2:00 AM VN Time)
```bash
# 1. System updates
flutter pub upgrade
firebase deploy --only functions

# 2. Database maintenance
# Firestore cleanup and optimization
node scripts/database-cleanup.js

# 3. Performance optimization
# Clear caches, optimize images
node scripts/performance-optimization.js

# 4. Security updates
# Update dependencies, scan for vulnerabilities
npm audit fix
flutter pub deps --json | jq '.packages[] | select(.kind == "direct")'

# 5. Backup verification
# Test backup restoration process
node scripts/test-backup-restore.js
```

### Monthly Maintenance
- [ ] Security audit and penetration testing
- [ ] Performance benchmarking
- [ ] Dependency updates and security patches
- [ ] Database optimization and cleanup
- [ ] SSL certificate renewal check
- [ ] Disaster recovery testing
- [ ] Documentation updates
- [ ] Team training and knowledge sharing

### Quarterly Maintenance
- [ ] Full system security review
- [ ] Performance optimization analysis
- [ ] Infrastructure scaling assessment
- [ ] Business continuity plan review
- [ ] Compliance audit
- [ ] Technology stack evaluation
- [ ] Disaster recovery drill
- [ ] Team performance review

## Backup and Recovery

### Backup Schedule
**Daily Backups (3:00 AM VN Time)**
```bash
# Firestore backup
firebase firestore:export gs://carenow-backups/daily/$(date +%Y%m%d)

# User data backup
node scripts/backup-user-data.js

# Configuration backup
cp -r config/ backups/config-$(date +%Y%m%d)/
```

**Weekly Backups (Sundays 4:00 AM VN Time)**
```bash
# Full system backup
node scripts/full-system-backup.js

# Code repository backup
git bundle create carenow-$(date +%Y%m%d).bundle --all
```

### Recovery Procedures
**Database Recovery**
```bash
# Restore from backup
firebase firestore:import gs://carenow-backups/daily/20241215

# Verify data integrity
node scripts/verify-data-integrity.js

# Test application functionality
npm run test:integration
```

**Application Recovery**
```bash
# Rollback to previous version
firebase hosting:channel:deploy previous-version

# Restore configuration
cp -r backups/config-20241215/ config/

# Restart services
firebase deploy --only functions,hosting
```

### Recovery Time Objectives (RTO)
- **Database**: 30 minutes
- **Application**: 15 minutes
- **Full System**: 1 hour
- **Data Loss (RPO)**: 1 hour maximum

## Performance Optimization

### Performance Monitoring
```bash
# Check current performance
lighthouse https://carenow.com --output json

# Monitor Core Web Vitals
node scripts/monitor-web-vitals.js

# Database performance
node scripts/check-db-performance.js
```

### Optimization Procedures
**Frontend Optimization**
- Image compression and WebP conversion
- Code splitting and lazy loading
- Bundle size optimization
- CDN configuration
- Service worker caching

**Backend Optimization**
- Database query optimization
- API response caching
- Function cold start reduction
- Memory usage optimization
- Connection pooling

**Infrastructure Optimization**
- CDN configuration
- Load balancing
- Auto-scaling setup
- Resource allocation
- Network optimization

### Performance Targets
- **Page Load Time**: <3 seconds
- **First Contentful Paint**: <1.8 seconds
- **Largest Contentful Paint**: <2.5 seconds
- **First Input Delay**: <100ms
- **Cumulative Layout Shift**: <0.1

## Security Operations

### Daily Security Checks
```bash
# Check for security alerts
firebase projects:list | grep security

# Review authentication logs
node scripts/check-auth-logs.js

# Scan for vulnerabilities
npm audit
flutter pub deps --json | jq '.packages[] | select(.kind == "direct")'

# Monitor suspicious activities
node scripts/security-monitoring.js
```

### Security Incident Response
1. **Immediate Actions**
   - Isolate affected systems
   - Preserve evidence
   - Notify security team
   - Document incident

2. **Investigation**
   - Analyze logs and traces
   - Identify attack vectors
   - Assess damage scope
   - Collect forensic evidence

3. **Containment**
   - Block malicious IPs
   - Revoke compromised credentials
   - Apply security patches
   - Update security rules

4. **Recovery**
   - Restore from clean backups
   - Verify system integrity
   - Update security measures
   - Monitor for reoccurrence

### Security Compliance
- **Data Protection**: GDPR, CCPA compliance
- **Healthcare**: HIPAA compliance (if applicable)
- **Payment**: PCI DSS compliance
- **Local**: Vietnamese data protection laws

## Emergency Procedures

### System Down Emergency
1. **Immediate Response (0-5 minutes)**
   ```bash
   # Check system status
   curl -I https://carenow.com
   
   # Check Firebase status
   firebase projects:list
   
   # Activate emergency page
   firebase hosting:channel:deploy emergency
   ```

2. **Escalation (5-15 minutes)**
   - Notify on-call team
   - Activate incident response
   - Communicate with stakeholders
   - Begin troubleshooting

3. **Resolution (15+ minutes)**
   - Implement fixes
   - Monitor recovery
   - Verify functionality
   - Update stakeholders

### Data Breach Emergency
1. **Immediate Actions**
   - Isolate affected systems
   - Preserve evidence
   - Notify legal team
   - Document everything

2. **Assessment**
   - Determine breach scope
   - Identify affected data
   - Assess legal requirements
   - Plan communication

3. **Notification**
   - Notify authorities (within 72 hours)
   - Inform affected users
   - Update privacy policy
   - Provide support resources

### Contact Information
```
Emergency Hotline: +84-xxx-xxx-xxx
Technical Support: support@carenow.com
Legal Team: legal@carenow.com
PR Team: pr@carenow.com
CEO: ceo@carenow.com
```

---

**Operational Excellence Principles:**
1. **Proactive Monitoring**: Prevent issues before they occur
2. **Rapid Response**: Minimize downtime and impact
3. **Continuous Improvement**: Learn from incidents and optimize
4. **Clear Communication**: Keep stakeholders informed
5. **Documentation**: Maintain accurate operational records

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Review Schedule**: Monthly
