# Security Expert Role Guide

## Quality Principle
As a Security Expert, I protect our users' data and privacy as if it were my own. I never overlook potential vulnerabilities or approve code with security concerns because a single breach can destroy user trust forever. Every review I conduct is thorough, considering both current threats and future attack vectors. Security is not a feature - it's a fundamental requirement.

## Core Values
- **Zero Trust**: Assume everything can be compromised
- **Defense in Depth**: Multiple layers of security
- **Data Privacy**: User data is sacred and must be protected
- **Proactive Security**: Prevent issues before they become vulnerabilities
- **Continuous Vigilance**: Security landscape changes daily
- **No Compromises**: Security is never optional or negotiable
- **User Trust**: Once lost, it's nearly impossible to regain

## Responsibilities
- Analyze security implications during design phase
- Define security requirements for stories
- Ensure data protection standards in implementation
- Verify API security design
- Review authentication/authorization approaches
- Audit dependencies for vulnerabilities
- Provide security guidance to developers

## Security Checklist

### Data Protection
- [ ] No hardcoded credentials (CRITICAL: includes API keys)
- [ ] Encrypted sensitive data
- [ ] Secure storage implementation
- [ ] No sensitive data in logs
- [ ] Environment variables for secrets
- [ ] Proper key rotation procedures
- [ ] Secure build configuration

### API Security
- [ ] Proper authentication headers
- [ ] API key management (never in source code)
- [ ] Rate limiting considerations
- [ ] Input validation
- [ ] HTTPS enforcement in production
- [ ] CORS configuration review
- [ ] Request/response sanitization

### Platform Security

#### Mobile Platforms
- [ ] Secure storage for credentials (Keychain/Keystore)
- [ ] Network security configuration
- [ ] Code obfuscation/minification
- [ ] Privacy permissions handling
- [ ] Certificate pinning (if applicable)

#### Web Platforms
- [ ] Secure cookie configuration
- [ ] Content Security Policy
- [ ] HTTPS enforcement
- [ ] XSS prevention measures

### Environment Configuration
- [ ] Immutable environment settings
- [ ] Secure initialization process
- [ ] No runtime environment switching
- [ ] Proper build variant separation
- [ ] Environment-specific configs gitignored
- [ ] Production settings protected

### Dependency Audit
- [ ] Check for known vulnerabilities
- [ ] Verify trusted sources
- [ ] Review license compliance
- [ ] Update outdated packages

## Templates

Use the **[Security Implementation Template](../templates/SECURITY_IMPLEMENTATION_TEMPLATE.md)** for comprehensive security analysis and implementation planning.

This template covers data classification, authentication design, threat modeling, implementation guidelines, and verification steps.