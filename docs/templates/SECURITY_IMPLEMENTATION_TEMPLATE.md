# Security Implementation Template

## 🔐 Feature/Component Security Analysis

**Feature/Component Name**: [Name]
**Date**: [Date]
**Security Lead**: [Name]

## 📊 Data Classification

### Sensitive Data Inventory
| Data Type | Classification | Storage Location | Encryption Required |
|-----------|----------------|------------------|---------------------|
| [User PII] | High | Database | Yes |
| [API Keys] | Critical | Environment | Yes |
| [Logs] | Medium | File System | No |

### Data Flow Mapping
```
[User Input] → [Validation] → [Processing] → [Storage] → [Output]
```

## 🔑 Authentication Design

### Method
- **Type**: [OAuth, JWT, Session-based, etc.]
- **Provider**: [Internal, Auth0, Firebase, etc.]
- **Multi-Factor**: Required / Optional / Not Implemented

### Token Management
- **Storage Approach**: [Where/how tokens are stored]
- **Expiration Strategy**: [Token lifetime and refresh approach]
- **Revocation Method**: [How tokens can be revoked]

### Session Handling
- **Timeout Policy**: [Idle timeout, absolute timeout]
- **Refresh Strategy**: [How sessions are refreshed]
- **Concurrent Sessions**: Allowed / Restricted

## 🛡️ Authorization Model

### Access Control
- **Model**: RBAC / ABAC / ACL
- **Roles Defined**: [List of roles]
- **Permissions Matrix**: [Link or embed permission matrix]

### API Security
- **Authentication Required**: Yes / No
- **Rate Limiting**: [Requests per minute/hour]
- **CORS Policy**: [Allowed origins]
- **Input Validation**: [Validation approach]

## 🚨 Security Considerations

### Threat Model
| Threat | Likelihood | Impact | Mitigation Strategy |
|--------|------------|--------|---------------------|
| SQL Injection | Low | High | Parameterized queries |
| XSS | Medium | Medium | Input sanitization |
| CSRF | Low | Medium | CSRF tokens |

### Vulnerability Assessment
- [ ] OWASP Top 10 reviewed
- [ ] Dependency vulnerabilities checked
- [ ] Static code analysis performed
- [ ] Dynamic testing completed

## 📋 Implementation Guidelines

### Secure Coding Practices
1. **Input Validation**
   - [ ] All inputs validated
   - [ ] Whitelist approach used
   - [ ] Length limits enforced

2. **Output Encoding**
   - [ ] HTML encoding for web output
   - [ ] JSON encoding for API responses
   - [ ] SQL parameterization for queries

3. **Error Handling**
   - [ ] Generic error messages to users
   - [ ] Detailed logs for debugging
   - [ ] No sensitive data in errors

4. **Cryptography**
   - [ ] Industry-standard algorithms
   - [ ] Secure key storage
   - [ ] Regular key rotation

### Platform-Specific Security

#### Web Application
- [ ] Content Security Policy implemented
- [ ] Secure headers configured
- [ ] HTTPS enforced
- [ ] Cookie security flags set

#### Mobile Application
- [ ] Certificate pinning implemented
- [ ] Secure storage used for sensitive data
- [ ] Obfuscation/minification applied
- [ ] Runtime protection added

#### API/Backend
- [ ] API versioning implemented
- [ ] Request signing/validation
- [ ] Audit logging enabled
- [ ] Service-to-service auth configured

## ✅ Verification Steps

### Pre-Deployment Checklist
- [ ] No hardcoded secrets in code
- [ ] All dependencies updated
- [ ] Security headers configured
- [ ] Encryption properly implemented
- [ ] Authentication flows tested
- [ ] Authorization rules verified
- [ ] Input validation complete
- [ ] Error handling reviewed
- [ ] Logging configured (no sensitive data)
- [ ] Rate limiting enabled

### Security Testing
- [ ] Unit tests for security functions
- [ ] Integration tests for auth flows
- [ ] Penetration testing scheduled
- [ ] Security scanning completed

### Compliance Verification
- [ ] GDPR requirements met
- [ ] PCI compliance verified (if applicable)
- [ ] HIPAA compliance verified (if applicable)
- [ ] Industry standards followed

## 🔍 Monitoring & Incident Response

### Security Monitoring
- **Log Collection**: [What is logged]
- **Anomaly Detection**: [Detection rules]
- **Alert Thresholds**: [When to alert]
- **Response Team**: [Who to contact]

### Incident Response Plan
1. **Detection**: [How incidents are detected]
2. **Containment**: [Immediate actions]
3. **Investigation**: [Investigation process]
4. **Remediation**: [Fix and patch process]
5. **Lessons Learned**: [Post-mortem process]

## 📚 References

### Security Standards
- [ ] OWASP Guidelines: [Relevant sections]
- [ ] Company Security Policy: [Link]
- [ ] Compliance Requirements: [List]

### Documentation
- [ ] API Security Docs: [Link]
- [ ] Security Architecture: [Link]
- [ ] Threat Model: [Link]

## 🤝 Sign-off

### Security Review
- [ ] Security team reviewed
- [ ] Penetration test passed
- [ ] Compliance verified
- [ ] Risk accepted by: [Name, Date]

### Final Approval
- **Security Lead**: [Name] - Date: [Date]
- **Technical Lead**: [Name] - Date: [Date]
- **Product Owner**: [Name] - Date: [Date]